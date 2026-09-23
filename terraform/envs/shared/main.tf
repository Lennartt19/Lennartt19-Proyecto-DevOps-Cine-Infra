# main.tf — SOLO data sources y llamadas a módulos (la lógica vive en modules/).
# Root shared: infraestructura COMPARTIDA (ACR + AKS). State: shared.tfstate.
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

module "platform" {
  source              = "../../modules/platform"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  subscription_id     = var.subscription_id
  acr_name            = var.acr_name
  aks_name            = var.aks_name
  node_count          = var.node_count
  vm_size             = var.vm_size
  tags                = local.common_tags
}
