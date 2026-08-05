#!/usr/bin/env bash
# prints the two cluster env vars backstage's kubernetes plugin wants.
set -euo pipefail

SA=backstage-viewer
NS=default

if ! kubectl get serviceaccount "$SA" -n "$NS" >/dev/null 2>&1; then
  cat >&2 <<EOF
serviceaccount $SA not found in namespace $NS.

it comes from the cluster-rbac argocd app - check that it synced:
  kubectl -n argocd get app cluster-rbac
EOF
  exit 1
fi

TOKEN=$(kubectl create token "$SA" -n "$NS" --duration=87600h)
URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

cat <<EOF
# paste into backstage-idp/.env  (gitignored - keep it that way, the repo is public)
KUBERNETES_CLUSTER_URL=$URL
KUBERNETES_SA_TOKEN=$TOKEN
EOF
