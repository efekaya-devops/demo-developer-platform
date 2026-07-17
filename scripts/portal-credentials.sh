#!/usr/bin/env bash
# Read-only ServiceAccount for the Backstage kubernetes plugin; prints the env
# vars backstage-idp expects.
set -euo pipefail
kubectl create serviceaccount portal-reader -n default --dry-run=client -o yaml | kubectl apply -f -
kubectl create clusterrolebinding portal-reader --clusterrole=view --serviceaccount=default:portal-reader \
  --dry-run=client -o yaml | kubectl apply -f -
TOKEN=$(kubectl create token portal-reader -n default --duration=48h)
URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo "export KUBERNETES_CLUSTER_URL=$URL"
echo "export KUBERNETES_SA_TOKEN=$TOKEN"
