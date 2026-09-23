# locals.tf — identidad del entorno (lo único que cambia entre dev/qa/prod).
# prod con quota MAYOR: más carga real y margen para picos.
locals {
  environment = "prod"
  namespace   = "parky-prod"

  quota_cpu    = "6"
  quota_memory = "12Gi"
  quota_pods   = "40"
}
