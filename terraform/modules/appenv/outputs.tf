output "namespace" {
  value = kubernetes_namespace.env.metadata[0].name
}
