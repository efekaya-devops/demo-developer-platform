# requested through the portal, don't hand-edit - raise a new request instead
module "demo-cluster" {
  source = "git::https://github.com/efekaya-devops/terraform-modules.git//modules/aws-eks?ref=main"

  name               = "demo-cluster"
  kubernetes_version = "1.30"
  node_instance_type = "t3.medium"
  node_count         = 2

  tags = {
    Team        = "team-alpha"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
