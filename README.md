# Proyecto-DevOps-Cine-infra — IaC de ParkyFilms en Azure

Repo **separado** del de la aplicación. Aquí vive todo lo de infraestructura:
Terraform (1 AKS compartido + namespaces dev/qa/prod), pipelines de
`terraform plan/apply` y scripts de bootstrap/limpieza. La app
(`Proyecto-DevOps-Cine`) solo construye imágenes y despliega con Helm;
**jamás** crea infraestructura.

## Arquitectura

```
GitHub (este repo, main) ──terraform.yml──▶ Azure (sub b497fd69-… "AZURE 02")
  PR ──▶ plan shared/dev/qa/prod (comenta diff)
  push main ──▶ apply dev (auto, único automático)
  dispatch manual ──▶ apply shared / qa / prod (tu elección; shared y prod con aprobador)

  rg-parkyfilms                       rg-parkyfilms-tfstate (bootstrap)
  ├── acrparkyfilms (ACR Basic)        └── stparkyfilmstf/tfstate/
  ├── aks-parkyfilms (1 cluster)           shared|dev|qa|prod.tfstate
  │    ├── parky-dev  (quota 4cpu/8Gi)
  │    ├── parky-qa   (quota 4cpu/8Gi)
  │    └── parky-prod (quota 6cpu/12Gi)
  └── id-parkyfilms-{dev,qa,prod} (OIDC por entorno, sin secretos)
```

Auth 100% OIDC federado: subjects
`repo:<owner>/<repo>:environment:azure-{dev,qa,prod}`. No hay
`clientSecret` en ningún lado.

## Puesta en marcha (orden)

1. **Crear el repo en GitHub** con este contenido + Environments
   `azure-dev`, `azure-qa`, `azure-prod` (`azure-prod` con revisor obligatorio).
2. **Bootstrap (una vez, crea gasto real)**:
   `./scripts/bootstrap.sh <OWNER> <REPO_INFRA>` → imprime los `ARM_*`
   por entorno. Cargar en cada Environment:
   `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` +
   `TF_VAR_postgres_password`, `TF_VAR_jwt_secret`, `TF_VAR_session_secret`.
3. **Abrir PR** → `terraform plan` automático de los 4 roots.
4. **Merge a main** → apply `dev` (único automático).
5. **Dispatch manual (tu elección)** → `shared` (primera vez: crea ACR+AKS,
   ~10 min, con aprobador), luego `qa` y `prod` cuando tú decidas
   (`prod` también con aprobador).

## Uso local

```bash
cp terraform/envs/dev/terraform.tfvars.example terraform/envs/dev/terraform.tfvars
export TF_VAR_postgres_password=... TF_VAR_jwt_secret=... TF_VAR_session_secret=...
cd terraform/envs/dev
terraform init \
  -backend-config="resource_group_name=rg-parkyfilms-tfstate" \
  -backend-config="storage_account_name=stparkyfilmstf" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev.tfstate"
terraform plan && terraform apply
```

## Costos (suscripción estudiante)

1 AKS (2× Standard_B2s) + ACR Basic + Storage LRS = consumo moderado.
Destruir con `./scripts/destroy.sh` o `az group delete -n rg-parkyfilms`.

## Limpieza

`./scripts/destroy.sh` (prod→qa→dev→shared, luego RGs). Los namespaces
sobreviven al `helm uninstall` de la app: la BD en el cluster persiste
en sus PVC salvo que se destruya el root del entorno.
