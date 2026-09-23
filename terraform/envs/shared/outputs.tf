# outputs.tf — SOLO salidas (alimentan el CD y observabilidad).
output "acr_login_server" {
  description = "Host del ACR (el CD lo usa para pushear/taggear imágenes)."
  value       = module.platform.acr_login_server
}

output "aks_name" {
  description = "Nombre del clúster (los roots dev/qa/prod lo consumen como cluster_name)."
  value       = module.platform.aks_name
}

output "aks_oidc_issuer_url" {
  description = "Issuer OIDC del clúster (workload identity futura)."
  value       = module.platform.aks_oidc_issuer_url
}
