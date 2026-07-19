# idp-gitops

The runtime side of the platform: a local kind cluster, ArgoCD, monitoring,
Crossplane, and the discovery rules that deploy new services without anyone
editing this repo by hand.

Companion repos:
[backstage-idp](https://github.com/efekaya-devops/backstage-idp) (the portal) ·
[terraform-modules](https://github.com/efekaya-devops/terraform-modules) ·
[crossplane-modules](https://github.com/efekaya-devops/crossplane-modules)

## setup

```bash
export GITHUB_TOKEN=ghp_...   # optional, only for pulling private ghcr images
scripts/bootstrap.sh
```

That makes the kind cluster, installs ArgoCD, and applies the app-of-apps.
Everything else ArgoCD pulls in itself from `apps/`.

Going the other way:

```bash
scripts/teardown.sh reset   # drop the demo's claims + services, keep the platform
scripts/teardown.sh all     # delete the cluster
```

`reset` is the one you want between demo runs. Note that a scaffolded service
comes back within 60s unless you delete its github repo too — the repo is the
source of truth, so that's the platform behaving correctly, not the script
failing.

| app | wave | does what |
|---|---|---|
| `root` | – | app-of-apps, argocd manages its own config from this repo |
| `crossplane` | 0 | the crossplane control plane (helm) |
| `crossplane-runtime` | 1 | the azure provider + the patch-and-transform function |
| `platform-apis` | 2 | XRD + Composition, pulled straight from the crossplane-modules repo |
| `infra-team-alpha` | 3 | the claims in the team-alpha repo, requested via the portal |
| `monitoring` | – | kube-prometheus-stack; grafana's sidecar auto-loads dashboard configmaps |
| `monitoring-rules` | – | alert rules for golden-path services |
| `metrics-server` | – | kind doesn't ship one, and backstage's kubernetes tab wants it |
| `cluster-rbac` | – | the read-only service account backstage uses |
| `services` (ApplicationSet) | – | deploys any org repo that has a `k8s/` folder |

The waves matter: crossplane's CRDs have to exist before a Provider applies,
the provider's CRDs before the Composition, and the Composition before a claim.

- ArgoCD: **https**://localhost:8081 (self-signed cert, click through)
  `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`
- Grafana: http://localhost:3001 (`admin` / `demo`)

## what lives where

```
apps/         one ArgoCD Application per thing above
bootstrap/    kind cluster definition (3 nodes, port mappings for argocd + grafana)
cluster/      service accounts / rbac the platform needs
crossplane/   the Provider and Function CRs
scripts/      bootstrap + teardown
monitoring/   helm values + alert rules
```

Requested infrastructure does **not** live here. It lives in the team's own
repo — [team-alpha](https://github.com/efekaya-devex-platform/team-alpha) — and
this repo just points an ArgoCD Application at it (`apps/infra-team-alpha.yaml`).
The platform owns the cluster; a product team owns the things it asked for, and
can review and merge its own infrastructure without commit access here. Adding
team-beta is a copy of that one file.

The split inside a team repo still matters: Crossplane claims in `claims/` are
continuously reconciled by ArgoCD, the Terraform in `infra/` is validated by CI
but nothing applies it. Adding an apply step (Atlantis, TFC, a CI job with
credentials) is the gap between this and a real setup.

## secrets you need in the cluster

Neither is created by the bootstrap script, because they're yours:

```bash
# 1. so argocd can read this repo (only needed while it's private)
kubectl -n argocd create secret generic idp-gitops-repo \
  --from-literal=type=git \
  --from-literal=url=https://github.com/efekaya-devops/idp-gitops \
  --from-literal=username=<you> --from-literal=password=<token>
kubectl -n argocd label secret idp-gitops-repo argocd.argoproj.io/secret-type=repository

# 2. so the ApplicationSet can list repos in the org
kubectl -n argocd create secret generic github-token --from-literal=token=<token>
```

The portal also needs a token for the cluster - mint one from the service
account `cluster-rbac` creates and put it in `backstage-idp/.env`:

```bash
kubectl create token backstage-viewer -n default --duration=87600h
```

## discovery, and the two things that trip it up

The ApplicationSet in `apps/services.yaml` watches the org for any repo with a
`k8s/` folder and deploys it. The golden path scaffolds that folder, so new
services go live on their own; delete the repo (or the folder) and it
un-deploys the same way.

Two things that will waste an afternoon otherwise:

- the SCM generator only scans a github **org**, never a personal account
- it needs `cloneProtocol: https`, or it goes looking for ssh keys and fails
  with `SSH_AUTH_SOCK not-specified`

It also polls every 60s (`requeueAfterSeconds`) rather than the 30 minute
default, because waiting half an hour mid-demo is not a demo.
