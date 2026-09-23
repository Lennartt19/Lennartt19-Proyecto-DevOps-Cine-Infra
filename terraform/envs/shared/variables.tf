# variables.tf — SOLO declaraciones (sin lógica ni recursos).
# Valores: terraform.tfvars (no secretos) o TF_VAR_* / GitHub Environments.

variable "subscription_id" {
  description = "ID de suscripción. TF_VAR_subscription_id. Ej. b497fd69-266c-46a9-b55b-8be0cd579667"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id debe ser un GUID válido."
  }
}

variable "resource_group_name" {
  description = "RG existente creado por scripts/bootstrap.sh (no se crea aquí)."
  type        = string
  default     = "rg-parkyfilms"
}

variable "acr_name" {
  description = "Nombre del ACR. Globalmente único, minúsculas y números."
  type        = string
  default     = "acrparkyfilms"

  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name: 5-50 caracteres, solo minúsculas y números (regla Azure)."
  }
}

variable "aks_name" {
  description = "Nombre del clúster AKS compartido."
  type        = string
  default     = "aks-parkyfilms"
}

variable "node_count" {
  description = "Nodos del pool system (sin autoscaling)."
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "node_count debe estar entre 1 y 10."
  }
}

variable "vm_size" {
  description = "SKU de VM de los nodos."
  type        = string
  default     = "Standard_B2s"
}
