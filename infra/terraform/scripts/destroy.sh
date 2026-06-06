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
Usage: $(basename "$0") <environment>

Environments: dev, staging, prod

This script destroys all infrastructure for the given environment.
Production environments require additional confirmation.

Examples:
  $(basename "$0") dev
  $(basename "$0") staging
  $(basename "$0") prod
EOF
  exit 1
}

cleanup() {
  if [ -f "${ENV_DIR}/destroy.plan" ]; then
    rm -f "${ENV_DIR}/destroy.plan"
  fi
}
trap cleanup EXIT

if [ $# -lt 1 ]; then
  usage
fi

ENVIRONMENT="$1"

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
  log_error "Invalid environment '$ENVIRONMENT'. Must be dev, staging, or prod."
  exit 1
fi

ENV_DIR="${TERRAFORM_DIR}/environments/${ENVIRONMENT}"

if [ ! -d "$ENV_DIR" ]; then
  log_error "Environment directory not found: $ENV_DIR"
  exit 1
fi

echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                    DESTRUCTION WARNING                          ║${NC}"
echo -e "${RED}║  This will DESTROY all infrastructure for:                      ║${NC}"
echo -e "${RED}║  Environment: ${YELLOW}${ENVIRONMENT}${RED}                                       ║${NC}"
if [ "$ENVIRONMENT" == "prod" ]; then
  echo -e "${RED}║  ⚠  PRODUCTION ENVIRONMENT - EXTREME CAUTION REQUIRED          ║${NC}"
fi
echo -e "${RED}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$ENVIRONMENT" == "prod" ]; then
  echo -e "${RED}╔══════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  PRODUCTION SAFETY CHECK                                        ║${NC}"
  echo -e "${RED}║  You must type the environment name to proceed.                 ║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  read -r -p "Type 'prod' to confirm destruction of PRODUCTION: " PROD_CONFIRM
  if [ "$PROD_CONFIRM" != "prod" ]; then
    log_error "Production destruction cancelled. Input did not match 'prod'."
    exit 1
  fi

  read -r -p "Are you absolutely sure? This will destroy ALL production resources. Type 'yes': " FINAL_CONFIRM
  if [ "$FINAL_CONFIRM" != "yes" ]; then
    log_error "Production destruction cancelled."
    exit 1
  fi
else
  read -r -p "Type the environment name '${ENVIRONMENT}' to confirm destruction: " ENV_CONFIRM
  if [ "$ENV_CONFIRM" != "$ENVIRONMENT" ]; then
    log_error "Destruction cancelled. Input did not match environment name."
    exit 1
  fi
fi

log_info "Proceeding with destruction of '${ENVIRONMENT}'..."
cd "$ENV_DIR"

log_info "Initializing Terraform..."
terraform init -upgrade -reconfigure

log_info "Selecting workspace '${ENVIRONMENT}'..."
if terraform workspace list 2>/dev/null | grep -q "^\\s*${ENVIRONMENT}\\s*$"; then
  terraform workspace select "$ENVIRONMENT"
else
  log_warn "Workspace '${ENVIRONMENT}' does not exist. Nothing to destroy."
  exit 0
fi

log_info "Generating destroy plan..."
terraform plan -destroy -out="destroy.plan"

echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  FINAL CONFIRMATION                                             ║${NC}"
echo -e "${RED}║  Review the destroy plan above.                                 ║${NC}"
echo -e "${RED}║  This operation CANNOT be undone.                               ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

read -r -p "Apply destroy plan? Type 'destroy': " DESTROY_CONFIRM
if [ "$DESTROY_CONFIRM" != "destroy" ]; then
  log_info "Destroy cancelled."
  exit 0
fi

log_warn "Destroying infrastructure for '${ENVIRONMENT}'..."

log_info "Step 1: Removing WAF web ACL association and ALB..."
terraform destroy -target="module.popcut.module.load_balancer" -auto-approve

log_info "Step 2: Removing compute resources (ASGs, EC2)..."
terraform destroy -target="module.popcut.module.compute" -auto-approve

log_info "Step 3: Removing cache resources..."
terraform destroy -target="module.popcut.module.cache" -auto-approve

log_info "Step 4: Removing database resources..."
terraform destroy -target="module.popcut.module.database" -auto-approve

log_info "Step 5: Removing security resources (IAM, KMS, Secrets Manager)..."
terraform destroy -target="module.popcut.module.security" -auto-approve

log_info "Step 6: Removing remaining resources (VPC, networking)..."
terraform destroy -auto-approve

log_info "Cleanup: Removing SSM parameters..."
aws ssm delete-parameters \
  --names \
    "/popcut/${ENVIRONMENT}/database/host" \
    "/popcut/${ENVIRONMENT}/database/port" \
    "/popcut/${ENVIRONMENT}/database/name" \
    "/popcut/${ENVIRONMENT}/redis/host" \
    "/popcut/${ENVIRONMENT}/redis/port" \
    "/popcut/${ENVIRONMENT}/load-balancer/dns" \
  2>/dev/null || true

log_info "Destruction of '${ENVIRONMENT}' completed successfully."
