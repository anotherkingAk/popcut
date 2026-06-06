#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") <environment> [plan|apply]

Environments: dev, staging, prod

Examples:
  $(basename "$0") dev plan
  $(basename "$0") staging apply
  $(basename "$0") prod apply
EOF
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

ENVIRONMENT="$1"
ACTION="${2:-plan}"

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
  log_error "Invalid environment '$ENVIRONMENT'. Must be dev, staging, or prod."
  exit 1
fi

if [[ ! "$ACTION" =~ ^(plan|apply)$ ]]; then
  log_error "Invalid action '$ACTION'. Must be plan or apply."
  exit 1
fi

ENV_DIR="${TERRAFORM_DIR}/environments/${ENVIRONMENT}"

if [ ! -d "$ENV_DIR" ]; then
  log_error "Environment directory not found: $ENV_DIR"
  exit 1
fi

log_info "Running Terraform for environment: ${ENVIRONMENT}"
log_info "Environment directory: ${ENV_DIR}"

cd "$ENV_DIR"

log_info "Initializing Terraform..."
terraform init -upgrade -reconfigure

log_info "Selecting workspace '${ENVIRONMENT}'..."
if terraform workspace list 2>/dev/null | grep -q "^\\s*${ENVIRONMENT}\\s*$"; then
  terraform workspace select "$ENVIRONMENT"
else
  terraform workspace new "$ENVIRONMENT"
fi

log_info "Validating Terraform configuration..."
terraform fmt -check -recursive "$TERRAFORM_DIR"
log_info "Terraform formatting check passed."

log_info "Generating Terraform plan..."
terraform plan -out="${ENVIRONMENT}.tfplan" -detailed-exitcode
PLAN_EXIT_CODE=$?

if [ $PLAN_EXIT_CODE -eq 0 ]; then
  log_info "No changes required. Infrastructure is up to date."
  exit 0
elif [ $PLAN_EXIT_CODE -eq 1 ]; then
  log_error "Terraform plan failed. Check the output above."
  exit 1
fi

if [ "$ACTION" == "plan" ]; then
  log_info "Plan generated successfully. Review the plan above."
  exit 0
fi

log_warn "You are about to apply changes to the '${ENVIRONMENT}' environment."
if [ "$ENVIRONMENT" == "prod" ]; then
  echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  PRODUCTION DEPLOYMENT - Confirm with 'yes'        ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
fi

read -r -p "Apply this plan? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  log_info "Deployment cancelled."
  exit 0
fi

log_info "Applying Terraform plan..."
terraform apply "${ENVIRONMENT}.tfplan"

log_info "Updating SSM parameters with infrastructure outputs..."
terraform output -json > /tmp/popcut-${ENVIRONMENT}-outputs.json

DB_ENDPOINT=$(echo "$(terraform output -raw rds_endpoint)" | cut -d: -f1)
DB_PORT=$(echo "$(terraform output -raw rds_endpoint)" | cut -d: -f2)
REDIS_PRIMARY=$(terraform output -raw redis_primary_endpoint)
REDIS_PORT=6379

aws ssm put-parameter \
  --name "/popcut/${ENVIRONMENT}/database/host" \
  --value "$DB_ENDPOINT" \
  --type SecureString \
  --overwrite \
  --region us-east-1

aws ssm put-parameter \
  --name "/popcut/${ENVIRONMENT}/database/port" \
  --value "${DB_PORT:-5432}" \
  --type String \
  --overwrite \
  --region us-east-1

aws ssm put-parameter \
  --name "/popcut/${ENVIRONMENT}/database/name" \
  --value "popcut_${ENVIRONMENT}" \
  --type String \
  --overwrite \
  --region us-east-1

aws ssm put-parameter \
  --name "/popcut/${ENVIRONMENT}/redis/host" \
  --value "$REDIS_PRIMARY" \
  --type SecureString \
  --overwrite \
  --region us-east-1

aws ssm put-parameter \
  --name "/popcut/${ENVIRONMENT}/redis/port" \
  --value "$REDIS_PORT" \
  --type String \
  --overwrite \
  --region us-east-1

ALB_DNS=$(terraform output -raw alb_dns_name)
aws ssm put-parameter \
  --name "/popcut/${ENVIRONMENT}/load-balancer/dns" \
  --value "$ALB_DNS" \
  --type String \
  --overwrite \
  --region us-east-1

log_info "SSM parameters updated successfully."

rm -f "${ENVIRONMENT}.tfplan"
log_info "Deployment to '${ENVIRONMENT}' completed successfully."
