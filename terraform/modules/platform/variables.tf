# Módulo platform: infraestructura COMPARTIDA (1 por suscripción).
# El Resource Group ya existe (lo crea scripts/bootstrap.sh) y se referencia
# por nombre. Crea: ACR + AKS + rol AcrPull para el kubelet.

variable "resource_group_name" {
  description = "RG existente (bootstrap). No se crea aquí."
  type        = string
}

variable "location" {
  description = "Región Azure, ej. chilecentral"
  type        = string
}

variable "subscription_id" {
  description = "ID de suscripción (b497fd69-...). Se fija explícito para no depender del default de az login."
  type        = string
}

variable "acr_name" {
  description = "Nombre globalmente único, solo minúsculas y números."
  type        = string
}

variable "aks_name" {
  description = "Nombre del clúster AKS."
  type        = string
  default     = "aks-parkyfilms"
}

variable "dns_prefix" {
  description = "Prefijo DNS del clúster."
  type        = string
  default     = "parkyfilms"
}

variable "node_count" {
  description = "Nodos del pool system (sin autoscaling)."
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Tamaño de VM de los nodos."
  type        = string
  default     = "Standard_B2s"
}

variable "enable_autoscaling" {
  description = "Activa cluster autoscaler en el pool system."
  type        = bool
  default     = false
}

variable "min_count" {
  type        = number
  default     = 1
  description = "Mínimo de nodos si hay autoscaling."
}

variable "max_count" {
  type        = number
  default     = 3
  description = "Máximo de nodos si hay autoscaling."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags comunes."
}
