# variables.tf — SOLO declaraciones. Secretos SOLO por TF_VAR_* (nunca tfvars).
variable "subscription_id" {
  description = "ID de suscripción. TF_VAR_subscription_id."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id debe ser un GUID válido."
  }
}

variable "resource_group_name" {
  description = "RG donde vive el AKS compartido."
  type        = string
  default     = "rg-parkyfilms"
}

variable "cluster_name" {
  description = "Nombre del clúster AKS compartido (output aks_name del root shared)."
  type        = string
  default     = "aks-parkyfilms"
}

variable "postgres_password" {
  description = "TF_VAR_postgres_password (GitHub Environment azure-qa)."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.postgres_password) >= 12
    error_message = "postgres_password: mínimo 12 caracteres."
  }
}

variable "jwt_secret" {
  description = "TF_VAR_jwt_secret. El backend exige mínimo 32 chars en producción."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "jwt_secret: mínimo 32 caracteres."
  }
}

variable "session_secret" {
  description = "TF_VAR_session_secret."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.session_secret) >= 32
    error_message = "session_secret: mínimo 32 caracteres."
  }
}
