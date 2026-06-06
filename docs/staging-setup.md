# Staging Deployment Setup

## Prerequisites

- **AWS Account** with permissions to create VPC, EC2, RDS, ElastiCache, ALB, KMS, Secrets Manager, WAF, IAM, S3, CloudWatch, SSM
- **Terraform** >= 1.6 (local or Terraform Cloud)
- **AWS CLI** configured with credentials
- **S3 backend** bucket `popcut-terraform-state` with DynamoDB table `popcut-terraform-locks` (must exist before first apply)
- **ACM Certificate** for `staging.popcut.ai` (or the actual staging domain) in `us-east-1`

### GitHub Repository Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | IAM role ARN for GitHub Actions OIDC to assume |
| `AWS_REGION` | AWS region (e.g. `us-east-1`) |
| `HOST` | SSH host for the EC2 instance running Docker Compose |
| `USERNAME` | SSH username (e.g. `ec2-user`) |
| `SSH_KEY` | Private SSH key for connecting to the host |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook for deployment notifications |

## Infrastructure Provisioned

| Module | Resources |
|--------|-----------|
| **networking** | VPC (`10.1.0.0/16`), public/private/database subnets across 2 AZs, IGW, NAT gateways, route tables, VPC Flow Logs |
| **security** | KMS keys (EBS, RDS, S3, Redis), Secrets Manager secrets (DB credentials, JWT, API key), IAM roles/policies, WAF ACL (rate limiting, SQLi, common rules) |
| **database** | RDS PostgreSQL 17 (`db.t3.medium`, 100GB gp3, automated backups, Performance Insights, enhanced monitoring) |
| **cache** | ElastiCache Redis 7 (cluster mode, 1 shard × 1 replica, encryption at rest/transit, KMS) |
| **load_balancer** | ALB (HTTP→HTTPS redirect), target groups (web:80, backend:4001, ai:8000), S3 access logs, security groups |
| **compute** | ASGs with launch templates (AL2023, encrypted EBS, detailed monitoring), CloudWatch alarms, CPU-based scaling policies |

> **Note**: The current Terraform provisions EC2 Auto Scaling Groups, but the GitHub Actions workflow deploys via SSH to a single host running Docker Compose. These are two different deployment models and need alignment.

## Steps

### 1. Bootstrap the S3 Backend

```bash
aws s3api create-bucket \
  --bucket popcut-terraform-state \
  --region us-east-1

aws dynamodb create-table \
  --table-name popcut-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 2. Terraform Initialize & Apply

```bash
# Using the deploy script:
bash infra/terraform/scripts/deploy.sh staging apply

# Or manually:
cd infra/terraform/environments/staging
terraform init
terraform workspace new staging 2>/dev/null || terraform workspace select staging
terraform plan -out=staging.tfplan
terraform apply staging.tfplan
```

The deploy script will also populate SSM parameters with the infrastructure outputs (DB host/port, Redis host/port, ALB DNS).

### 3. Configure the Staging Domain & Certificate

Update `infra/terraform/environments/staging/terraform.tfvars`:

```hcl
domain_name     = "staging.popcut.ai"    # or your actual domain
certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT_ID"  # REQUIRED
```

### 4. Build & Push Docker Images

Deploy via GitHub Actions (push to `develop` branch) triggers `deploy-staging.yml` automatically:
- Builds `auth-service`, `web`, and `ai-service` images
- Pushes to `ghcr.io` tagged with commit SHA (e.g. `staging-abc123`)
- Deploys via SSH to the staging host using `docker compose up -d`

Manual build:

```bash
docker build -f docker/Dockerfile.auth-service -t ghcr.io/ORG/auth-service:staging-latest .
docker build -f docker/Dockerfile.web -t ghcr.io/ORG/web:staging-latest .
docker build -f docker/Dockerfile.ai-service -t ghcr.io/ORG/ai-service:staging-latest .
docker push ghcr.io/ORG/auth-service:staging-latest
docker push ghcr.io/ORG/web:staging-latest
docker push ghcr.io/ORG/ai-service:staging-latest
```

## Environment Variables

### auth-service

| Variable | Source | Description |
|----------|--------|-------------|
| `PORT` | Hardcoded/`.env` | Service port (4001) |
| `DATABASE_URL` | SSM `/popcut/staging/database/host` + Secrets Manager | PostgreSQL connection string |
| `JWT_SECRET` | Secrets Manager (`popcut-staging-jwt-secret`) | JWT signing key |
| `JWT_EXPIRES_IN` | Hardcoded | Token expiry (15m) |
| `CORS_ORIGIN` | Hardcoded | Allowed CORS origin |

### web

| Variable | Source | Description |
|----------|--------|-------------|
| `NEXT_PUBLIC_API_URL` | Build-time | Backend API URL |
| `NEXT_PUBLIC_AI_API_URL` | Build-time | AI service API URL |

### admin-web

| Variable | Source | Description |
|----------|--------|-------------|
| `NEXT_PUBLIC_API_URL` | Build-time | Backend API URL |

## Verification

### Health Checks

```bash
# ALB / Load Balancer
ALB_DNS=$(aws ssm get-parameter --name "/popcut/staging/load-balancer/dns" --query Parameter.Value --output text)
curl -k https://$ALB_DNS/api/health

# Direct checks (after SSH deploy)
curl --fail https://staging.popcut.app/api/health
curl --fail https://staging.popcut.app
```

### CloudWatch

- **Log groups**: `/popcut/staging/application`, `/popcut/staging/syslog`
- **Metrics**: Custom `PopCut` namespace metrics from ASG instances
- **Alarms**: CPU high/low for web, backend, and ASG services; RDS connections, CPU, storage

### Verification Checklist

- [ ] ALB DNS resolves and returns 200 for health endpoints
- [ ] RDS is reachable and accepting connections
- [ ] Redis is reachable
- [ ] ASGs have desired number of instances in service
- [ ] Docker containers are running on the target host
- [ ] WAF is blocking malicious requests

## Known Issues & Gaps

1. **Architecture mismatch**: Terraform provisions Auto Scaling Groups but the deploy workflow uses SSH to a single host with Docker Compose. Consider using ECS + Fargate or keeping a consistent model.
2. **Missing `certificate_arn`**: Staging tfvars has an empty string — must be set before HTTPS listener works.
3. **Domain mismatch**: tfvars uses `staging.popcut.ai` but the workflow health checks use `staging.popcut.app` — align these.
4. **No Terraform step in CI**: The deploy workflow does not run `terraform apply` — add a step to ensure infrastructure matches the latest config.
5. **No `latest` Docker tag**: Staging images only use commit SHA tags; adding a `staging-latest` tag simplifies rollbacks.
6. **SSH host assumption**: Single-host Docker Compose — not scalable. Replace with ASG instance refresh or switch to ECS.
