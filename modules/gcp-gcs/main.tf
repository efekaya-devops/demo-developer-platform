# the gcp equivalent of aws-s3. uniform access + versioning on, public off.

resource "google_storage_bucket" "this" {
  name     = var.name
  project  = var.project_id
  location = var.location

  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy

  versioning {
    enabled = var.versioning
  }

  labels = var.labels
}
