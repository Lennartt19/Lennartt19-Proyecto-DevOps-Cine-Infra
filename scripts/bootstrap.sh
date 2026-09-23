#!/usr/bin/env bash
# Bootstrap UNA SOLA VEZ: crea lo que Terraform necesita para existir
# (RG + Storage de states + 3 identities OIDC + federated credentials + roles).
# NO crea ACR/AKS/namespaces: eso lo hace Terraform.
#
# Uso: ./scripts/bootstrap.sh <GITHUB_OWNER> <REPO_INFRA> [LOCATION]
# Ej.: ./scripts/bootstrap.sh Lennartt19 Proyecto-DevOps-Cine-infra chilecentral
set -euo pipefail

OWNER="${1:?Uso: $0 <GITHUB_OWNER> <REPO_INFRA> [LOCATION]}"
REPO="${2:?Uso: $0 <GITHUB_OWNER> <REPO_INFRA> [LOCATION]}"
LOCATION="${3:-chilecentral}"

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-b497fd69-266c-46a9-b55b-8be0cd579667}"
RG="${RG:-rg-parkyfilms}"
STATE_RG="${STATE_RG:-rg-parkyfilms-tfstate}"
STATE_ST="${STATE_ST:-stparkyfilmstf}"
STATE_CONTAINER="${STATE_CONTAINER:-tfstate}"
ISSUER="https://token.actions.githubusercontent.com"
AUDIENCE="api://AzureADTokenExchange"

echo "==> Suscripción objetivo"
az account set --subscription "$SUBSCRIPTION_ID"
TENANT_ID="$(az account show --query tenantId -o tsv)"
echo "    sub=$SUBSCRIPTION_ID tenant=$TENANT_ID"

echo "==> RG de trabajo: $RG ($LOCATION)"
az group create --name "$RG" --location "$LOCATION" -o none

echo "==> RG + Storage de states: $STATE_RG / $STATE_ST"
az group create --name "$STATE_RG" --location "$LOCATION" -o none
if [ "$(az storage account check-name --name "$STATE_ST" --query nameAvailable -o tsv)" = "true" ]; then
  az storage account create --name "$STATE_ST" --resource-group "$STATE_RG" \
    --location "$LOCATION" --sku Standard_LRS --kind StorageV2 \
    --allow-blob-public-access false -o none
else
  echo "    Storage $STATE_ST ya existe (o nombre ocupado), se reutiliza."
fi
az storage container create --name "$STATE_CONTAINER" \
  --account-name "$STATE_ST" --auth-mode login -o none

for ENV in dev qa prod; do
  ID_NAME="id-parkyfilms-$ENV"
  echo "==> Identity $ID_NAME"
  if ! az identity show --name "$ID_NAME" --resource-group "$RG" &>/dev/null; then
    az identity create --name "$ID_NAME" --resource-group "$RG" --location "$LOCATION" -o none
  fi
  CLIENT_ID="$(az identity show --name "$ID_NAME" --resource-group "$RG" --query clientId -o tsv)"
  PRINCIPAL_ID="$(az identity show --name "$ID_NAME" --resource-group "$RG" --query principalId -o tsv)"

  if [ -z "$(az role assignment list --assignee "$PRINCIPAL_ID" --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG" --query "[?roleDefinitionName=='Contributor'].id" -o tsv)" ]; then
    az role assignment create --assignee-object-id "$PRINCIPAL_ID" --assignee-principal-type ServicePrincipal \
      --role Contributor --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG" -o none
  else
    echo "    Rol Contributor ya asignado."
  fi

  SUBJECT="repo:$OWNER/$REPO:environment:azure-$ENV"
  CRED_NAME="gha-$ENV"
  if az ad app federated-credential list --id "$CLIENT_ID" --query "[?name=='$CRED_NAME'].name" -o tsv | grep -q "$CRED_NAME"; then
    echo "    Federated credential $CRED_NAME ya existe."
  else
    APP_ID="$(az identity show --name "$ID_NAME" --resource-group "$RG" --query clientId -o tsv)"
    az ad app federated-credential create --id "$APP_ID" --parameters \
      "{\"name\":\"$CRED_NAME\",\"issuer\":\"$ISSUER\",\"subject\":\"$SUBJECT\",\"audiences\":[\"$AUDIENCE\"]}" -o none
  fi

  echo "---- Secrets para GitHub Environment azure-$ENV ----"
  echo "  ARM_CLIENT_ID=$CLIENT_ID"
  echo "  ARM_TENANT_ID=$TENANT_ID"
  echo "  ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
done

echo
echo "==> Bootstrap OK. Siguiente:"
echo "  1. Crear Environments azure-dev/qa/prod en GitHub (prod con revisor obligatorio)."
echo "  2. Cargar en cada uno ARM_CLIENT_ID/_TENANT_ID/_SUBSCRIPTION_ID + TF_VAR_postgres_password/_jwt_secret/_session_secret."
echo "  3. terraform init/plan por root (ver README) o abrir PR para plan automático."
