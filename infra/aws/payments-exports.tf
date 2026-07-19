# requested through the portal, don't hand-edit - raise a new request instead
module "payments-exports" {
  source = "git::https://github.com/efekaya-devops/terraform-modules.git//modules/aws-s3?ref=main"

  name       = "payments-exports"
  versioning = true

  tags = {
    Team        = "team-alpha"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
