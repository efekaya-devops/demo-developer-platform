# example wiring, not meant to apply as-is - needs your own aws account + bucket name

module "bucket" {
  source = "../../modules/aws-s3"
  name   = "idp-demo-changeme"
}

module "eks" {
  source = "../../modules/aws-eks"
  name   = "idp-demo"
}
