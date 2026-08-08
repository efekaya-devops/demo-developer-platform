#!/usr/bin/env bash
# Builds TechDocs for every entity that declares one, before anybody asks for
# them.
#
# Not just a speed-up. With `techdocs.builder: local` docs are generated on
# demand, so on a fresh deployment there are none when the search indexer makes
# its first pass. It collates zero techdocs documents, Lunr skips creating the
# index entirely, and from then on every query the TechDocs tab fires comes back
# 500 MissingIndexError - which surfaces in the browser as a JSON parse error on
# the entity page. Generating the docs first, then letting the indexer run,
# breaks that cycle.
#
#   deploy/warm-techdocs.sh [backend-url]     # default http://127.0.0.1:7007
#
# Failures here are reported but never fatal: missing docs make a tab look
# empty, they don't justify failing a deploy.
set -uo pipefail

BACKEND="${1:-http://127.0.0.1:7007}"

token=$(curl -s -X POST "$BACKEND/api/auth/guest/refresh" -H 'Content-Type: application/json' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["backstageIdentity"]["token"])' 2>/dev/null)

if [ -z "$token" ]; then
  echo "    warm-techdocs: could not get a guest token, skipping" >&2
  exit 0
fi

# The catalog is the source of truth for who has docs - no list to keep in sync.
entities=$(curl -s -H "Authorization: Bearer $token" "$BACKEND/api/catalog/entities?limit=500" \
  | python3 -c '
import sys, json
for e in json.load(sys.stdin):
    m = e.get("metadata", {})
    if "backstage.io/techdocs-ref" in (m.get("annotations") or {}):
        ns = m.get("namespace", "default")
        print("%s/%s/%s" % (ns, e["kind"].lower(), m["name"]))
' 2>/dev/null)

if [ -z "$entities" ]; then
  echo "    warm-techdocs: no entities declare techdocs-ref"
  exit 0
fi

failed=0
for ref in $entities; do
  printf '    %-40s ' "$ref"
  # /sync streams progress as server-sent events and ends with a finish event;
  # the generator runs mkdocs in a container, so give it room.
  out=$(curl -s -N --max-time 600 -H "Authorization: Bearer $token" \
    "$BACKEND/api/techdocs/sync/$ref" 2>/dev/null | grep -E '^data' | tail -1)
  case "$out" in
    *'"updated"'*) echo "ok" ;;
    *)             echo "failed (${out:-no response})"; failed=$((failed + 1)) ;;
  esac
done

[ "$failed" -gt 0 ] && echo "    warm-techdocs: $failed entity/entities did not build" >&2
exit 0
