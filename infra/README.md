# infra

Terraform requested through the portal. One file per resource, each one just
calls a module from the `terraform-modules` repo.

Nothing applies this automatically — CI checks the Terraform is valid and a
human reviews the PR. Wiring up an apply step (Atlantis, Terraform Cloud, a
CI job with credentials) is the missing piece between this and a real setup.

Crossplane claims live in `../claims/` instead, and those *are* applied
automatically by ArgoCD.
