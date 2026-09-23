# outputs.tf — SOLO salidas.
output "namespace" {
  description = "Namespace del entorno (lo usa el CD para helm upgrade -n)."
  value       = module.appenv.namespace
}
