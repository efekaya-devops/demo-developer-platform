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
| `services` (ApplicationSet) | deploys any org repo that has a `k8s/` folder |

- argocd: http://localhost:8081
- grafana: http://localhost:3001 (admin / demo)

## why the folder-based discovery thing

the ApplicationSet in `apps/services.yaml` watches the org for any repo with
a `k8s/` folder and deploys what's in it. the golden path scaffolds that
folder (and tags the repo `idp-service` too, handy for eyeballing the org on
github). so a new service goes live without anyone editing this repo - delete
the repo (or the k8s/ folder) and it un-deploys the same way.

heads up: the SCM generator only works against a github *org*, not a personal
account, and it needs `cloneProtocol: https` so it uses the token secret
instead of looking for ssh keys.

before using this for real: replace `GITHUB_ORG` in `apps/*.yaml` with your
own github username/org (`grep -rl GITHUB_ORG apps/` to find them all).
