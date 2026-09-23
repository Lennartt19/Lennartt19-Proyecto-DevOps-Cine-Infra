output "acr_login_server" {
  description = "Host del ACR (lo usa el CD para pushear/taggear imágenes)."
  value       = azurerm_container_registry.main.login_server
}

output "acr_id" {
  value = azurerm_container_registry.main.id
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "aks_oidc_issuer_url" {
  description = "Issuer OIDC del clúster (workload identity futura)."
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "resource_group_name" {
  description = "RG creado por este módulo (los roots dev/qa/prod lo usan como default)."
  value       = azurerm_resource_group.main.name
}
