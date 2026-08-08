#!/usr/bin/env bash
# spins up the cluster + argocd + the app-of-apps. argocd takes it from
# there and pulls in the rest (monitoring, service discovery) on its own
#
# LEAN=1 runs the profile built for a single small cloud VM: one kind node
# instead of three, and no monitoring stack. Everything that makes the demo a
# demo - the portal, crossplane, the claims - is identical.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "${LEAN:-}" = "1" ]; then
  CLUSTER_CONFIG=bootstrap/kind-cluster-lean.yaml
  ROOT_APP=bootstrap/root-lean.yaml
  echo "### lean profile: 1 node, no monitoring"
else
  CLUSTER_CONFIG=bootstrap/kind-cluster.yaml
  ROOT_APP=apps/root.yaml
fi

command -v kind >/dev/null    || { echo "kind not found (https://kind.sigs.k8s.io)"; exit 1; }
command -v kubectl >/dev/null || { echo "kubectl not found"; exit 1; }

echo "=== 1/4 kind cluster ==="
kind get clusters | grep -qx idp || kind create cluster --config "$CLUSTER_CONFIG"

echo "=== 2/4 ArgoCD ==="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.13.2/manifests/install.yaml
kubectl -n argocd patch svc argocd-server -p '{"spec":{"type":"NodePort","ports":[{"port":80,"nodePort":30080,"name":"http"}]}}'
kubectl -n argocd rollout status deployment argocd-server --timeout=180s

echo "=== 3/4 ghcr pull secret ==="
# the golden path pushes private images to ghcr, so the default ns needs
# creds to pull them. set GITHUB_TOKEN (a PAT with read:packages) first.
if [ -n "${GITHUB_TOKEN:-}" ]; then
  kubectl create secret docker-registry ghcr \
    --docker-server=ghcr.io \
    --docker-username="${GITHUB_USER:-x}" \
    --docker-password="${GITHUB_TOKEN}" \
    -n default --dry-run=client -o yaml | kubectl apply -f -
  kubectl patch serviceaccount default -n default \
    -p '{"imagePullSecrets":[{"name":"ghcr"}]}'
else
  echo "  (skipped - set GITHUB_TOKEN to enable private ghcr pulls)"
fi

echo "=== 4/4 app-of-apps ==="
kubectl apply -f "$ROOT_APP"

echo "=== done ==="
echo "ArgoCD  http://localhost:8081  (admin / \$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d))"
[ "${LEAN:-}" = "1" ] \
  || echo "Grafana http://localhost:3001  (admin / demo) - once the monitoring app finishes syncing"
