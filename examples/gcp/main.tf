# same idea, gcp side - fill in your project id before applying

module "bucket" {
  source     = "../../modules/gcp-gcs"
  name       = "idp-demo-changeme"
  project_id = var.project_id
}

module "gke" {
  source     = "../../modules/gcp-gke"
  name       = "idp-demo"
  project_id = var.project_id
}

variable "project_id" {
  type = string
}
