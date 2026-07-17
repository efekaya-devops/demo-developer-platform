# idp-gitops

The runtime half of the IDP demo: a **local kind cluster**, **ArgoCD**
(app-of-apps, self-managed), the **monitoring stack** (kube-prometheus-stack:
Prometheus + Grafana), and **automatic service discovery** — every repo the
portal scaffolds is deployed and dashboarded without a single manual step here.

Companion repos: [backstage-idp](../backstage-idp) (the portal),
[terraform-modules](../terraform-modules) (infra modules),
[platform-docs](../platform-docs) (architecture & journey).

## One command

```bash
scripts/bootstrap.sh
```

Creates the 3-node kind cluster, installs ArgoCD, applies the app-of-apps.
ArgoCD then pulls in everything under `apps/`:

| App | What it does |
|---|---|
| `root` | app-of-apps — ArgoCD manages its own config from this repo |
| `monitoring` | kube-prometheus-stack; Grafana sidecar hot-loads any ConfigMap labeled `grafana_dashboard=1` |
| `services` (ApplicationSet) | SCM-provider generator: every org repo with topic **`idp-service`** gets an Application syncing its `k8s/` dir |

- ArgoCD UI → http://localhost:8081
- Grafana → http://localhost:3001 (admin / demo)

## Why the discovery model matters

The golden path tags each scaffolded repo `idp-service`. The ApplicationSet
turns that tag into a deployment; the dashboard ConfigMap in the service's own
repo turns it into observability. **The platform scales by convention, not by
tickets** — nobody edits this repo when a team ships a new service, and
removing the tag (or the repo) un-deploys it just as declaratively.

Before first use, replace `GITHUB_ORG` in `apps/*.yaml` with your GitHub
org/username (`grep -rl GITHUB_ORG apps/`).
