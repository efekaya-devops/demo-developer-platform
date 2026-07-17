# terraform-modules

Reusable infrastructure modules for the Internal Developer Platform demo.
Same interface, two targets — the demo runs free on a laptop, and the cloud
path is a `source =` swap away:

| Module | Target | Use |
|---|---|---|
| `modules/kind-local` | kind (local Docker) | The demo cluster — zero cloud cost |
| `modules/aks-cluster` | Azure AKS | The like-for-like production path (OIDC issuer + workload identity enabled) |

## Quick start (local)

```bash
cd examples/local
terraform init && terraform apply
```

You get the same 3-node cluster `idp-gitops/scripts/bootstrap.sh` creates —
use whichever entrypoint fits the audience; both feed the same GitOps
bootstrap.

## Design notes

- **Modules own the "what", environments own the "how big".** Sizing (node
  count, VM size, SKU tier) is variables with safe defaults, so a demo
  environment and a production environment differ in a `.tfvars` file, not in
  forked code.
- **No state or credentials in this repo.** Backends are configured by the
  consuming environment; CI only ever runs `fmt`/`validate` (see
  `.github/workflows/validate.yaml`).

Companion repos: [backstage-idp](../backstage-idp) ·
[idp-gitops](../idp-gitops) · [platform-docs](../platform-docs)
