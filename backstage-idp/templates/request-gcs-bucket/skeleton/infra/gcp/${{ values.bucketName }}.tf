# requested through the portal, don't hand-edit - raise a new request instead
module "${{ values.bucketName }}" {
  source = "git::https://github.com/efekaya-devops/terraform-modules.git//modules/gcp-gcs?ref=main"

  name          = "${{ values.bucketName }}"
  project_id    = "${{ values.projectId }}"
  storage_class = "${{ values.storageClass }}"

  # gcp label keys/values have to be lowercase
  labels = {
    team        = "${{ values.team }}"
    environment = "${{ values.environment }}"
    managed_by  = "terraform"
  }
}
