# idp-gitops

The runtime side of the demo - local kind cluster, argocd, monitoring
(prometheus + grafana), and service discovery so new repos get deployed
without touching this repo by hand.

Companion repos: [backstage-idp](../backstage-idp) (the portal),
[terraform-modules](../terraform-modules) (infra modules),
[platform-docs](../platform-docs) (docs).

## setup

```bash
scripts/bootstrap.sh
```

makes the kind cluster, installs argocd, applies the app-of-apps. from there
argocd pulls in everything under `apps/` on its own:

| app | does what |
|---|---|
| `root` | app-of-apps, argocd manages its own config from this repo |
| `monitoring` | prometheus + grafana, grafana's sidecar auto-loads dashboard configmaps |
| `services` (ApplicationSet) | deploys any org repo tagged `idp-service` |

- argocd: http://localhost:8081
- grafana: http://localhost:3001 (admin / demo)

## why the tag-based discovery thing

the golden path template tags every repo it creates with `idp-service`. the
ApplicationSet in `apps/services.yaml` watches for that tag and deploys
whatever it finds. so a new service goes live without anyone editing this
repo - remove the tag (or delete the repo) and it un-deploys the same way.

before using this for real: replace `GITHUB_ORG` in `apps/*.yaml` with your
own github username/org (`grep -rl GITHUB_ORG apps/` to find them all).
