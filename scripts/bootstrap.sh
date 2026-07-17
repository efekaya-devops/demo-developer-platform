#!/usr/bin/env bash
# One command to a running platform: kind cluster + ArgoCD + the app-of-apps.
# From there ArgoCD pulls everything else (monitoring, service discovery).
set -euo pipefail
cd "$(dirname "$0")/.."

command -v kind >/dev/null    || { echo "kind not found (https://kind.sigs.k8s.io)"; exit 1; }
command -v kubectl >/dev/null || { echo "kubectl not found"; exit 1; }

echo "=== 1/4 kind cluster ==="
kind get clusters | grep -qx idp || kind create cluster --config bootstrap/kind-cluster.yaml

echo "=== 2/4 ArgoCD ==="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.13.2/manifests/install.yaml
kubectl -n argocd patch svc argocd-server -p '{"spec":{"type":"NodePort","ports":[{"port":80,"nodePort":30080,"name":"http"}]}}'
kubectl -n argocd rollout status deployment argocd-server --timeout=180s

echo "=== 3/4 app-of-apps ==="
kubectl apply -f apps/root.yaml

echo "=== 4/4 done ==="
echo "ArgoCD  http://localhost:8081  (admin / \$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d))"
echo "Grafana http://localhost:3001  (admin / demo) — after the monitoring app syncs"
