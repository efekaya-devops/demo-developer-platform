# terraform-modules

Infra modules for the IDP demo. Local (free) and cloud versions of the same
thing, so swapping `source =` is basically the whole migration.

| Module | Target | Notes |
|---|---|---|
| `modules/kind-local` | kind | the demo cluster, no cloud account needed |
| `modules/aks-cluster` | Azure AKS | oidc + workload identity on |
| `modules/aws-eks` | AWS EKS | uses the default vpc, keep it that way for demos |
| `modules/aws-s3` | AWS S3 | bucket w/ versioning + encryption on by default |
| `modules/gcp-gke` | GCP GKE | zonal, not regional - cheaper |
| `modules/gcp-gcs` | GCP GCS | same idea as the s3 one |

## quick start (local)

```bash
cd examples/local
terraform init && terraform apply
```

Same cluster `idp-gitops/scripts/bootstrap.sh` gives you, just via terraform
instead of the script. Pick whichever.

`examples/aws` and `examples/gcp` show how the cloud modules wire together -
not meant to be applied blind, put in your own bucket name / project id first.

## notes to self

- sizing (node count, instance type, sku) is all variables w/ defaults, so
  demo vs "real" env is a tfvars difference, not a forked module
- no backend/state config in here on purpose, that's the consuming env's job
- CI just runs fmt + validate, nothing fancy

other repos: [backstage-idp](https://github.com/efekaya-devops/backstage-idp) ·
[idp-gitops](https://github.com/efekaya-devops/idp-gitops) · [platform-docs](https://github.com/efekaya-devops/platform-docs)
