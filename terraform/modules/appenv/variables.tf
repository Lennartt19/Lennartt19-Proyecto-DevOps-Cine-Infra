# Módulo appenv: recursos POR ENTORNO dentro del clúster compartido.
# Crea: Namespace + ResourceQuota + LimitRange + Secret base de la app.
# Los secretos reales llegan por TF_VAR_* (GitHub Environments), nunca en archivos.

variable "environment" {
  description = "dev | qa | prod"
  type        = string
}

variable "namespace" {
  description = "Nombre del namespace, ej. parky-dev"
  type        = string
}

variable "quota_cpu" {
  description = "Límite total de CPU del namespace."
  type        = string
  default     = "4"
}

variable "quota_memory" {
  description = "Límite total de RAM del namespace."
  type        = string
  default     = "8Gi"
}

variable "quota_pods" {
  description = "Máximo de pods del namespace."
  type        = string
  default     = "20"
}

variable "default_cpu_request" {
  type        = string
  default     = "100m"
  description = "CPU por defecto si un pod no declara requests."
}

variable "default_memory_request" {
  type        = string
  default     = "128Mi"
  description = "RAM por defecto si un pod no declara requests."
}

variable "postgres_password" {
  type        = string
  sensitive   = true
  description = "TF_VAR_postgres_password. Sin default a propósito."
}

variable "jwt_secret" {
  type        = string
  sensitive   = true
  description = "TF_VAR_jwt_secret. Mínimo 32 caracteres."
}

variable "session_secret" {
  type        = string
  sensitive   = true
  description = "TF_VAR_session_secret. Mínimo 32 caracteres."
}
