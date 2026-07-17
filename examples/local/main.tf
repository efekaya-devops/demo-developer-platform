# The demo environment: `terraform init && terraform apply` gives you the same
# cluster idp-gitops/scripts/bootstrap.sh creates — pick whichever entrypoint
# fits the audience (script for speed, Terraform to show the IaC path).
module "cluster" {
  source = "../../modules/kind-local"
  name   = "idp"
}

output "endpoint" {
  value = module.cluster.endpoint
}
