# zonal (not regional) cluster to keep cost down for a demo. default node
# pool gets removed and replaced with a real one - standard gke pattern,
# terraform can't manage the default pool's node config well

resource "google_container_cluster" "this" {
  name     = var.name
  project  = var.project_id
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "default" {
  name     = "default"
  project  = var.project_id
  location = var.zone
  cluster  = google_container_cluster.this.name

  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
