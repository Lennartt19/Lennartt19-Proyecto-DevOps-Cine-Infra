# locals.tf — identidad del entorno (lo único que cambia entre dev/qa/prod).
locals {
  environment = "dev"
  namespace   = "parky-dev"

  quota_cpu    = "4"
  quota_memory = "8Gi"
  quota_pods   = "20"
}
