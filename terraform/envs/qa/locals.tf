# locals.tf — identidad del entorno (lo único que cambia entre dev/qa/prod).
locals {
  environment = "qa"
  namespace   = "parky-qa"

  quota_cpu    = "4"
  quota_memory = "8Gi"
  quota_pods   = "20"
}
