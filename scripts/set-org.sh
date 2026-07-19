#!/usr/bin/env bash
# Repoint the whole platform at different GitHub orgs.
#
# The org names are baked into ~50 places across six repos - ArgoCD manifests,
# Backstage scaffolder templates, service deployments, catalog entities. They
# live in three different templating engines that share no runtime variable, so
# the honest "single global variable" is this: one config file
# (platform-orgs.env) plus this script, which rewrites every occurrence in one
# pass. Reversible - it's all under git, so `git diff` shows you everything and
# `git checkout` undoes it.
#
# Usage:
#   scripts/set-org.sh                          # show current values, do nothing
#   scripts/set-org.sh <platform-org> <teams-org>
#
# Run it from a checkout that sits next to the other repos, e.g.
#   some-dir/
#     idp-gitops/       <- you are here
#     backstage-idp/
#     team-alpha/
#     terraform-modules/  crossplane-modules/  platform-docs/
#     payments-api/  inventory-api/  ...        <- services, if cloned
set -euo pipefail
cd "$(dirname "$0")"
CONF="platform-orgs.env"
# shellcheck disable=SC1090
source "./$CONF"

OLD_PLATFORM="$PLATFORM_ORG"
OLD_TEAMS="$TEAMS_ORG"

if [ $# -eq 0 ]; then
  echo "current orgs:"
  echo "  PLATFORM_ORG = $OLD_PLATFORM"
  echo "  TEAMS_ORG    = $OLD_TEAMS"
  echo
  echo "to change: scripts/set-org.sh <platform-org> <teams-org>"
  exit 0
fi

if [ $# -ne 2 ]; then
  echo "need exactly two args: <platform-org> <teams-org>" >&2
  exit 2
fi

NEW_PLATFORM="$1"
NEW_TEAMS="$2"

# the parent dir that holds all the repos as siblings
ROOT="$(cd ../.. && pwd)"
echo "rewriting under $ROOT"
echo "  $OLD_PLATFORM -> $NEW_PLATFORM"
echo "  $OLD_TEAMS -> $NEW_TEAMS"
echo

changed=0
# only text we own - skip vendored code, git internals, and the local catalog db
while IFS= read -r -d '' f; do
  if grep -qE "$OLD_PLATFORM|$OLD_TEAMS" "$f"; then
    # TEAMS first: it's the longer string, and PLATFORM is not a substring of
    # it, so order is not strictly required - but doing the longer one first is
    # a good habit if the names ever overlap
    sed -i.bak \
      -e "s|$OLD_TEAMS|$NEW_TEAMS|g" \
      -e "s|$OLD_PLATFORM|$NEW_PLATFORM|g" \
      "$f"
    rm -f "$f.bak"
    echo "  $(echo "$f" | sed "s|$ROOT/||")"
    changed=$((changed + 1))
  fi
done < <(find "$ROOT" \
  -type d \( -name node_modules -o -name .git -o -name .data -o -name dist -o -name .terraform \) -prune -o \
  -type f \( -name '*.yaml' -o -name '*.yml' -o -name '*.sh' -o -name '*.tf' \
             -o -name '*.ts' -o -name '*.tsx' -o -name '*.json' -o -name '*.md' \
             -o -name '*.html' -o -name '*.env' \) -print0)

# record the new values so this file stays the source of truth
sed -i.bak \
  -e "s|^PLATFORM_ORG=.*|PLATFORM_ORG=$NEW_PLATFORM|" \
  -e "s|^TEAMS_ORG=.*|TEAMS_ORG=$NEW_TEAMS|" \
  "$CONF"
rm -f "$CONF.bak"

echo
echo "done - $changed files changed. review with 'git diff' in each repo, then"
echo "commit and push. the platform reads these from git, so nothing takes"
echo "effect until it's pushed and re-synced."
