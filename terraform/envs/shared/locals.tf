# locals.tf — valores derivados y etiquetas comunes (sin inputs).
locals {
  common_tags = {
    project   = "parkyfilms"
    managedBy = "terraform"
    root      = "shared"
  }
}
