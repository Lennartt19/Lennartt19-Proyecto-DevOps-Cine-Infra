# main.tf — SOLO data sources y llamadas a módulos (la lógica vive en modules/).
# Root shared: infraestructura COMPARTIDA (RG + ACR + AKS). State: shared.tfstate.
# Es el PRIMER apply: crea el RG que luego usan dev/qa/prod.
module "platform" {
  source              = "../../modules/platform"
  resource_group_name = var.resource_group_name
  location            = var.location
  subscription_id     = var.subscription_id
  acr_name            = var.acr_name
  aks_name            = var.aks_name
  node_count          = var.node_count
  vm_size             = var.vm_size
  tags                = local.common_tags
}
