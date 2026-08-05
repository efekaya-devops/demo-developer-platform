output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.platform.name
}

output "aks_resource_group" {
  value = azurerm_resource_group.aks.name
}

output "aks_oidc_issuer_url" {
  description = "Used to configure Workload Identity federation"
  value       = azurerm_kubernetes_cluster.platform.oidc_issuer_url
}

output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${azurerm_kubernetes_cluster.platform.name}"
}
