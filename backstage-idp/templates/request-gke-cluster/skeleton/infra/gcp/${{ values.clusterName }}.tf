# requested through the portal, don't hand-edit - raise a new request instead
module "${{ values.clusterName }}" {
  source = "git::https://github.com/efekaya-devops/terraform-modules.git//modules/gcp-gke?ref=main"

  name         = "${{ values.clusterName }}"
  project_id   = "${{ values.projectId }}"
  zone         = "${{ values.zone }}"
  machine_type = "${{ values.machineType }}"
  node_count   = ${{ values.nodeCount }}

  # gcp label keys/values have to be lowercase
  labels = {
    team        = "${{ values.team }}"
    environment = "${{ values.environment }}"
    managed_by  = "terraform"
  }
}
