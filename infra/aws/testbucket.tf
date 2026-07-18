# requested through the portal, don't hand-edit - raise a new request instead
module "testbucket" {
  source = "git::https://github.com/efekaya-devops/terraform-modules.git//modules/aws-s3?ref=main"

  name       = "testbucket"
  versioning = true

  tags = {
    Team        = "team-alpha"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
