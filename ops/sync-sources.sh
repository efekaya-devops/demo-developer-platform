#!/usr/bin/env bash
# This repo is a mirror. Every top-level folder is a `git subtree` copy of a
# repo that also lives on its own, and the standalone repo is the original in
# every case.
#
# So: edit the standalone checkout, push that, then run this to bring the copy
# forward. Editing a folder here instead works right up until the next sync
# quietly overwrites it — and the change never reaches the repo anyone actually
# clones.
#
#   ops/sync-sources.sh          # pull every source
#   ops/sync-sources.sh backstage-idp idp-gitops   # or just these
set -euo pipefail

cd "$(dirname "$0")/.."

# folder | remote | branch
SOURCES=(
  "backstage-idp|https://github.com/efekaya-devops/backstage-idp.git|main"
  "idp-gitops|https://github.com/efekaya-devops/idp-gitops.git|main"
  "crossplane-modules|https://github.com/efekaya-devops/crossplane-modules.git|main"
  "terraform-modules|https://github.com/efekaya-devops/terraform-modules.git|main"
  "team-alpha|https://github.com/efekaya-devex-platform/team-alpha.git|main"
)

# subtree merges into the working tree, so anything uncommitted here would get
# tangled up in the merge commit.
if [ -n "$(git status --porcelain)" ]; then
  echo "working tree is dirty — commit or stash first" >&2
  exit 1
fi

wanted=("$@")
for entry in "${SOURCES[@]}"; do
  IFS='|' read -r prefix url branch <<<"$entry"

  if [ ${#wanted[@]} -gt 0 ]; then
    match=0
    for w in "${wanted[@]}"; do [ "$w" = "$prefix" ] && match=1; done
    [ "$match" = 1 ] || continue
  fi

  echo "### $prefix"
  git subtree pull --prefix "$prefix" "$url" "$branch" -m "Sync $prefix from upstream"
done

echo
echo "synced — review with 'git log --oneline -5', then: git push"
