# main.tf — SOLO data sources y llamada al módulo (tamaños en locals.tf).
# Root dev. State: dev.tfstate.
data "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

module "appenv" {
  source            = "../../modules/appenv"
  environment       = local.environment
  namespace         = local.namespace
  quota_cpu         = local.quota_cpu
  quota_memory      = local.quota_memory
  quota_pods        = local.quota_pods
  postgres_password = var.postgres_password
  jwt_secret        = var.jwt_secret
  session_secret    = var.session_secret
}
