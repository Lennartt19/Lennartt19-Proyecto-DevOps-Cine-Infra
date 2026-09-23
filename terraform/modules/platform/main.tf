data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false # sin credenciales admin: AKS tira por identidad (AcrPull)
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.dns_prefix

  oidc_issuer_enabled       = true
  workload_identity_enabled = true # futura mejora: pods sin secretos

  default_node_pool {
    name                 = "system"
    node_count           = var.enable_autoscaling ? null : var.node_count
    vm_size              = var.vm_size
    os_sku               = "AzureLinux"
    auto_scaling_enabled = var.enable_autoscaling
    min_count            = var.enable_autoscaling ? var.min_count : null
    max_count            = var.enable_autoscaling ? var.max_count : null
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# El kubelet del AKS puede hacer pull del ACR sin secretos
resource "azurerm_role_assignment" "acrpull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
