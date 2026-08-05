# team-alpha

The point of this repo existing separately from
[idp-gitops](https://github.com/efekaya-devops/idp-gitops): the platform team
owns the cluster, ArgoCD, monitoring and the blueprints; a product team owns
the things it requested. Splitting them means a team can review and merge its
own infrastructure without commit access to the platform, and the platform
can't lose track of who asked for what.

```
claims/       crossplane claims - argocd applies these, continuously reconciled
infra/aws/    terraform (s3, eks) - CI validates, nothing applies it
infra/gcp/    same for gcp (gcs, gke)
catalog/      one Resource entity per thing above; backstage scans this folder
```

## how a thing gets here

1. Someone opens the portal and fills in a form (Request a Database, an S3
   bucket, whatever)
2. The portal opens a **pull request on this repo** — never provisions
   anything directly, and never holds cloud credentials
3. CI validates it, a human reviews it, someone merges
4. ArgoCD applies the claim; Backstage discovers `catalog/<name>.yaml` and the
   resource shows up in the catalog with its owner

Deleting works the same way: `git rm` the claim, ArgoCD prunes it, Crossplane
garbage-collects the managed resources. There's no delete button and there
doesn't need to be.

## the terraform is not applied

`claims/` is live — ArgoCD reconciles it into the cluster. `infra/` is checked
and reviewed but nothing runs `terraform apply`.
