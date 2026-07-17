locals {
  tags = {
    Project     = var.name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "azurerm_resource_group" "platform" {
  name     = "rg-${var.name}-shared"
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-${var.name}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_kubernetes_cluster" "platform" {
  name                = "aks-${var.name}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "aks-${var.name}"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  sku_tier = var.sku_tier

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size

    # Required so AKS can change the default node pool's vm_size in place:
    # it rotates through a temporary pool of this name, then swaps back.
    temporary_name_for_rotation = "systmp"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

# CI/CD deploy access: let the Azure DevOps pipeline SP fetch cluster credentials
# (az aks get-credentials -> listClusterUserCredential). Cluster-scoped,
# least-privilege. Previously granted manually on the WRONG resource group
# (rg-platform, not rg-aks), which broke the CI "Deploy to AKS" step.
