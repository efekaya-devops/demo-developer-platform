variable "name" {
  description = "Platform name; prefixes the cluster and resource-group names."
  type        = string
  default     = "platform"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name used for tagging"
  type        = string
  default     = "production"
}

variable "node_count" {
  description = "Number of AKS system nodes"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for AKS system nodes"
  type        = string
  default     = "Standard_B2ms"
}

variable "sku_tier" {
  description = "AKS control-plane tier. Free has no uptime SLA (fine for non-prod); Standard adds one."
  type        = string
  default     = "Free"
}

