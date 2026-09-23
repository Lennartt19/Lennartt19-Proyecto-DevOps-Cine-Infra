# versions.tf — versiones de Terraform/providers + backend remoto (parcial).
# El workflow completa el backend con -backend-config (state RG/storage/container/key).
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {}
}
