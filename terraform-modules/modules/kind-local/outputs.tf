output "kubeconfig" {
  value     = kind_cluster.platform.kubeconfig
  sensitive = true
}

output "endpoint" {
  value = kind_cluster.platform.endpoint
}
