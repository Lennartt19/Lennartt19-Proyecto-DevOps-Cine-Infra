# providers.tf — configuración de providers (sin recursos ni variables).
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
