resource "kubernetes_namespace" "env" {
  metadata {
    name = var.namespace
    labels = {
      "parkyfilms.io/environment" = var.environment
      "parkyfilms.io/managed-by"  = "terraform"
    }
  }
}

# Evita que un entorno se coma el clúster compartido
resource "kubernetes_resource_quota" "env" {
  metadata {
    name      = "${var.namespace}-quota"
    namespace = kubernetes_namespace.env.metadata[0].name
  }
  spec {
    hard = {
      cpu    = var.quota_cpu
      memory = var.quota_memory
      pods   = var.quota_pods
    }
  }
}

# Defaults sanos si un Deployment no declara requests
resource "kubernetes_limit_range" "env" {
  metadata {
    name      = "${var.namespace}-limits"
    namespace = kubernetes_namespace.env.metadata[0].name
  }
  spec {
    limit {
      type = "Container"
      default_request = {
        cpu    = var.default_cpu_request
        memory = var.default_memory_request
      }
    }
  }
}

# Secret base de la app (el chart Helm/ backend lo consume por env vars).
# Valores SOLO por TF_VAR_* desde GitHub Environments.
resource "kubernetes_secret" "app" {
  metadata {
    name      = "parky-app-secrets"
    namespace = kubernetes_namespace.env.metadata[0].name
  }
  data = {
    POSTGRES_PASSWORD = var.postgres_password
    JWT_SECRET        = var.jwt_secret
    SESSION_SECRET    = var.session_secret
  }
  type = "Opaque"
}
