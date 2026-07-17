# Local variant of the platform cluster: identical interface, zero cloud cost.
# The demo runs here; the aks-cluster module is the like-for-like cloud path.
terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.6"
    }
  }
}

resource "kind_cluster" "platform" {
  name           = var.name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      extra_port_mappings {
        container_port = 30080
        host_port      = 8081
      }
      extra_port_mappings {
        container_port = 30030
        host_port      = 3001
      }
    }
    node { role = "worker" }
    node { role = "worker" }
  }
}
