#!/usr/bin/env bash
# undo a demo run. two modes, because on the day you almost never want the
# slow one:
#
#   teardown.sh reset    remove what the demo created, leave the cluster up
#   teardown.sh all      delete the kind cluster entirely
#
# neither touches github. repos the golden path created are deleted by hand
# (or with the gh line this prints at the end) - doing that automatically felt
# like a bad idea for a script people run half-awake before a presentation.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-}"
case "$MODE" in
  reset|all) ;;
  *) echo "usage: $0 {reset|all}"; exit 1 ;;
esac

if [ "$MODE" = "all" ]; then
  echo "=== deleting kind cluster 'idp' ==="
  kind delete cluster --name idp
  echo
  echo "gone. 'scripts/bootstrap.sh' builds it again (~5 min, mostly image pulls)."
  exit 0
fi

# --- reset ------------------------------------------------------------------
# the order matters: drop the claims before the services, otherwise argocd
# re-syncs a claim you just deleted because the app is still there.

echo "=== 1/4 crossplane claims ==="
# delete the claim, not the composed resource - crossplane garbage collects
# the managed resource itself. deleting the managed resource directly just
# gets it recreated.
if kubectl get resourcegroups.platform.example.org >/dev/null 2>&1; then
  kubectl delete resourcegroups.platform.example.org --all --ignore-not-found --timeout=60s || {
    echo "  claim didn't delete cleanly - see the finalizer note in the README"
  }
else
  echo "  (no claims)"
fi

echo "=== 2/4 demo services ==="
# select by ownerReference, not by name. anything the ApplicationSet generated
# is owned by it; the platform's own apps aren't. matching on names instead
# would spare a service unlucky enough to be called "monitoring-api".
GENERATED=$(kubectl -n argocd get applications \
  -o jsonpath='{range .items[?(@.metadata.ownerReferences[0].kind=="ApplicationSet")]}{.metadata.name}{"\n"}{end}' 2>/dev/null)

if [ -z "$GENERATED" ]; then
  echo "  (none)"
else
  # worth being blunt about this: deleting a generated Application achieves
  # nothing on its own. the ApplicationSet re-creates it within requeueAfter
  # (60s) for as long as the repo still exists in the org with a k8s/ folder.
  # that's the platform working correctly, not a bug in this script. the repo
  # is the source of truth, so the repo is what has to go.
  echo "$GENERATED" | sed 's/^/  /'
  echo
  echo "  ^ these come back in ~60s unless their github repos are gone."
  echo "    delete the repos first, then re-run; or use 'all' to bin the cluster."
  echo "$GENERATED" | while read -r a; do
    [ -n "$a" ] && kubectl -n argocd delete application "$a" --ignore-not-found >/dev/null
  done
fi

echo "=== 3/4 leftover workloads in default ==="
# belt and braces: if an app was deleted without prune the pods hang around
kubectl -n default delete deploy,svc,servicemonitor,configmap \
  -l app.kubernetes.io/managed-by=Helm --ignore-not-found >/dev/null 2>&1 || true

echo "=== 4/4 argocd state ==="
kubectl -n argocd delete secret -l argocd.argoproj.io/secret-type=repository --ignore-not-found >/dev/null 2>&1 || true

echo
echo "=== done ==="
kubectl -n argocd get applications 2>/dev/null || true
cat <<'EOF'

still there on purpose: the cluster, argocd, crossplane, monitoring.
the platform is up and empty - which is exactly the state you want to demo from.

two things this does NOT do:

  1. delete github repos the golden path made. to list them:
       gh repo list <your-org> --limit 50
     and once you're sure:
       gh repo delete <org>/<name> --yes

  2. remove the claims/*.yaml files from git. if you merged an infra PR, the
     claim is still committed - argocd will put it back on the next sync.
     git rm it, which is the deprovisioning story anyway.
EOF
