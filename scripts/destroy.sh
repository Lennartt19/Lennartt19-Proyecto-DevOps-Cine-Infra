#!/usr/bin/env bash
# Limpieza ordenada: destruye en orden inverso (prod -> qa -> dev -> shared)
# y opcionalmente borra los RGs. Pide confirmación antes de cada paso.
# Uso: ./scripts/destroy.sh  (ejecutar desde la raíz del repo)
set -euo pipefail

confirm() {
  read -r -p "$1 [escribe SI para continuar]: " ans
  [ "$ans" = "SI" ] || { echo "Cancelado."; exit 1; }
}

export TF_STATE_RG="${TF_STATE_RG:-rg-parkyfilms-tfstate}"
export TF_STATE_ST="${TF_STATE_ST:-stparkyfilmstf}"
export TF_STATE_CONTAINER="${TF_STATE_CONTAINER:-tfstate}"

destroy_root() {
  local root="$1"
  echo "==> terraform destroy: $root"
  ( cd "terraform/envs/$root" && \
    terraform init \
      -backend-config="resource_group_name=$TF_STATE_RG" \
      -backend-config="storage_account_name=$TF_STATE_ST" \
      -backend-config="container_name=$TF_STATE_CONTAINER" \
      -backend-config="key=$root.tfstate" && \
    terraform destroy )
}

confirm "¿Destruir namespaces prod, qa y dev (terraform)?"
destroy_root prod
destroy_root qa
destroy_root dev

confirm "¿Destruir infraestructura compartida RG+ACR+AKS (terraform)?"
destroy_root shared

# El destroy de shared ya borra rg-parkyfilms (gestionado por Terraform);
# esto solo cubre restos si el destroy falló a medias.
confirm "¿Borrar los resource groups rg-parkyfilms y $TF_STATE_RG (pierdes states)?"
az group delete --name rg-parkyfilms --yes --no-wait 2>/dev/null || echo "rg-parkyfilms ya no existe (lo borró Terraform)."
az group delete --name "$TF_STATE_RG" --yes --no-wait
echo "Limpieza lanzada."
