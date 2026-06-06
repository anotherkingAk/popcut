# AWS Production Architecture — PopCut

> **Project:** PopCut — AI-powered professional video editing platform
> **Environment:** Multi-account (dev / staging / prod) with infrastructure-as-code via Terraform
> **Last updated:** 2026-06-06

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Network Layout](#2-network-layout)
3. [Compute](#3-compute)
4. [Database](#4-database)
5. [Caching](#5-caching)
6. [Storage](#6-storage)
7. [DNS & CDN](#7-dns--cdn)
8. [Security](#8-security)
9. [Monitoring](#9-monitoring)
10. [Cost Optimization](#10-cost-optimization)
11. [Deployment Strategy](#11-deployment-strategy)
12. [Disaster Recovery](#12-disaster-recovery)
13. [Architecture Diagram](#13-architecture-diagram)

---

## 1. Architecture Overview

### 1.1 Multi-Environment Strategy

| Environment | AWS Account | Purpose | DB Size | Compute Size |
|-------------|-------------|---------|---------|--------------|
| **dev** | Shared sandbox | Feature development, PR previews | `db.t3.medium` | `t3.medium` |
| **staging** | Shared sandbox | Integration testing, QA, load tests | `db.t3.medium` | `t3.medium` |
| **prod** | Isolated prod account | Production traffic | `db.r6g.large` | `t3.large` |

Environments share a single AWS account for dev/staging; production uses a separate account with strict IAM boundaries. Terraform workspaces (`dev`, `staging`, `prod`) manage the state separation.

### 1.2 Service Inventory

| Service | Framework | Port | Docker Image | Scaling |
|---------|-----------|------|-------------|---------|
| **Web App** | Next.js 16 (SSR) | 3000 | `ghcr.io/popcut/web` | Auto-scaling (CPU) |
| **Admin Web** | Next.js 16 (SSR) | 3001 | `ghcr.io/popcut/admin-web` | Auto-scaling (CPU) |
| **Auth Service** | NestJS 11 | 4001 | `ghcr.io/popcut/auth-service` | Auto-scaling (CPU) |
| **AI Service** | FastAPI (Python 3.12) | 8000 | `ghcr.io/popcut/ai-service` | Auto-scaling (CPU/memory) |
| **Export Service** | NestJS (planned) | 4002 | `ghcr.io/popcut/export-service` | Queue-based |
| **Media Service** | NestJS (planned) | 4003 | `ghcr.io/popcut/media-service` | Auto-scaling (CPU) |
| **Project Service** | NestJS (planned) | 4004 | `ghcr.io/popcut/project-service` | Auto-scaling (CPU) |
| **Template Service** | NestJS (planned) | 4005 | `ghcr.io/popcut/template-service` | Auto-scaling (CPU) |

### 1.3 High Availability

- **Multi-AZ:** All infrastructure deployed across 3 Availability Zones (us-east-1a, us-east-1b, us-east-1c)
- **RDS Multi-AZ:** Synchronous standby replica in a different AZ
- **ElastiCache Multi-AZ:** Replication group with automatic failover
- **ALB:** Regional, cross-zone load balancing
- **Auto Scaling Groups:** Spread across AZs, min 2 / max 10 per service
- **SLA Target:** 99.95% uptime for production

---

## 2. Network Layout

### 2.1 VPC Design

```
10.0.0.0/16  ──  Production VPC (us-east-1)
│
├── 10.0.0.0/19   ──  Public Subnets (AZ-a, AZ-b, AZ-c)
│   ├── 10.0.0.0/24     ──  Public AZ-a
│   ├── 10.0.32.0/24    ──  Public AZ-b
│   └── 10.0.64.0/24    ──  Public AZ-c
│
├── 10.0.128.0/19 ──  Private Subnets — Application (AZ-a, AZ-b, AZ-c)
│   ├── 10.0.128.0/24   ──  App AZ-a
│   ├── 10.0.160.0/24   ──  App AZ-b
│   └── 10.0.192.0/24   ──  App AZ-c
│
├── 10.0.144.0/20 ──  Private Subnets — Data (AZ-a, AZ-b, AZ-c)
│   ├── 10.0.144.0/24   ──  Data AZ-a (RDS, Redis, EFS)
│   ├── 10.0.160.0/24   ──  Data AZ-b
│   └── 10.0.176.0/24   ──  Data AZ-c
│
└── 10.0.240.0/20 ──  Isolated Subnets — AI/GPU (AZ-a, AZ-b, AZ-c)
    ├── 10.0.240.0/24   ──  AI AZ-a
    ├── 10.0.244.0/24   ──  AI AZ-b
    └── 10.0.248.0/24   ──  AI AZ-c
```

### 2.2 Subnet Layout per Environment

| Environment | VPC CIDR | Public Subnets | Private App Subnets | Private Data Subnets | AZ Count |
|-------------|----------|----------------|---------------------|----------------------|----------|
| dev | `10.1.0.0/16` | 2 | 2 | 2 | 2 |
| staging | `10.2.0.0/16` | 2 | 2 | 2 | 2 |
| prod | `10.0.0.0/16` | 3 | 3 | 3 | 3 |

### 2.3 NAT Gateways

| Environment | NAT Gateway Type | Quantity | Cost |
|-------------|-----------------|----------|------|
| dev | Single shared NAT | 1 | $32.85/mo |
| staging | Single shared NAT | 1 | $32.85/mo |
| prod | One per AZ | 3 | $98.55/mo |

Production uses one NAT Gateway per AZ for resilience — if one AZ fails, the other AZs retain outbound connectivity.

### 2.4 Load Balancers

| Load Balancer | Type | Target Group | Listeners |
|--------------|------|-------------|-----------|
| `web-alb` | Application | Next.js web (port 3000) | 443 → 3000 |
| `admin-alb` | Application | Next.js admin (port 3001) | 443 → 3001 |
| `api-alb` | Application | Auth service (4001), AI service (8000), ... | 443 → path-based routing |
| `internal-alb` | Application (internal) | Inter-service communication | 80 → internal |

**ALB configuration:**
- Idle timeout: 60s
- Deletion protection: enabled
- Cross-zone load balancing: enabled
- Drop invalid headers: enabled
- Desync mitigation mode: `defensive`
- WAF ACL: attached to all public ALBs

**Path-based routing on `api-alb`:**
```
/api/auth/*     → auth-service:4001
/api/ai/*       → ai-service:8000
/api/projects/* → project-service:4004
/api/media/*    → media-service:4003
/api/export/*   → export-service:4002
/api/templates/*→ template-service:4005
```

### 2.5 Security Groups

| Security Group | Inbound Rules | Outbound Rules |
|---------------|---------------|----------------|
| `sg-web` | 443 from 0.0.0.0/0 (CloudFront only), 80 from 0.0.0.0/0 (redirect) | All |
| `sg-api` | 443 from `sg-web`, from CloudFront | All |
| `sg-app` | From `sg-api` (service ports) | All |
| `sg-db` | 5432 from `sg-app` | All |
| `sg-redis` | 6379 from `sg-app` | All |
| `sg-efs` | 2049 from `sg-app` | All |
| `sg-bastion` | 22 from corporate CIDR / VPN | All |

---

## 3. Compute

### 3.1 EC2 Instance Types

| Service | Instance Type (Staging) | Instance Type (Prod) | AMI |
|---------|------------------------|----------------------|-----|
| Web Next.js | `t3.medium` (2 vCPU, 4 GiB) | `t3.large` (2 vCPU, 8 GiB) | Amazon Linux 2023 |
| Admin Next.js | `t3.medium` (2 vCPU, 4 GiB) | `t3.large` (2 vCPU, 8 GiB) | Amazon Linux 2023 |
| Auth Service | `t3.medium` (2 vCPU, 4 GiB) | `t3.large` (2 vCPU, 8 GiB) | Amazon Linux 2023 |
| AI Service | `t3.medium` (2 vCPU, 4 GiB) | `t3.large` (2 vCPU, 8 GiB) | Amazon Linux 2023 |
| Export Service | `t3.small` (2 vCPU, 2 GiB) | `t3.medium` (2 vCPU, 4 GiB) | Amazon Linux 2023 |
| Media Service | `t3.medium` (2 vCPU, 4 GiB) | `t3.large` (2 vCPU, 8 GiB) | Amazon Linux 2023 |

### 3.2 Auto Scaling Groups

**All services follow this pattern:**

```yaml
# Example: auth-service ASG
auto_scaling_group:
  name: popcut-auth-service-asg
  min_size: 2
  max_size: 10
  desired_capacity: 2
  health_check_type: ELB
  health_check_grace_period: 60
  termination_policies:
    - OldestLaunchTemplate
    - Default
  vpc_zone_identifier:
    - subnet-app-a
    - subnet-app-b
    - subnet-app-c
  launch_template:
    instance_type: t3.large  # staging: t3.medium
    image_id: ami-2023       # Amazon Linux 2023
    user_data: |
      #!/bin/bash
      exec docker run --rm -p 4001:4001 \
        -e DATABASE_URL=${database_url} \
        -e REDIS_URL=${redis_url} \
        ghcr.io/popcut/auth-service:latest
  scaling_policies:
    - name: cpu-target
      type: TargetTrackingScaling
      target_value: 70
      metric: ASGAverageCPUUtilization
      cooldown: 120
    - name: request-count-per-target
      type: TargetTrackingScaling
      target_value: 1000
      metric: ALBRequestCountPerTarget
      cooldown: 120
```

**Scaling thresholds (production):**

| Metric | Scale-out threshold | Scale-in threshold | Cooldown |
|--------|--------------------|--------------------|----------|
| CPU utilization | > 70% for 3 min | < 40% for 10 min | 120s |
| Memory utilization | > 75% for 3 min | < 50% for 10 min | 120s |
| ALB request count/target | > 1,000 req/min | < 300 req/min | 120s |

**Scheduled scaling (production):**

| Time Window | Desired Capacity | Reason |
|-------------|-----------------|--------|
| 08:00–23:59 UTC | 4–10 | Peak usage hours |
| 00:00–07:59 UTC | 2–5 | Off-peak, cost savings |

### 3.3 AMI Strategy

- **Base AMI:** Amazon Linux 2023 (free, well-supported, includes ECS-optimized variants)
- **Provisioning:** Packer builds golden AMI with Docker, CloudWatch agent, SSM agent, EFS mount helper
- **Update cadence:** Weekly security patch rebuilds (automated via CI), manual rebuilds for OS updates
- **Immutable deployments:** New ASG launch template version → instance refresh — never SSH into running instances
- **Deprecation:** AMIs older than 90 days automatically deregistered

### 3.4 EC2 Instance Details

```yaml
Instance Metadata:
  - HttpTokens: required (IMDSv2)
  - HttpPutResponseHopLimit: 1
  - InstanceMetadataTags: enabled

Block Device Mappings:
  - DeviceName: /dev/xvda
    Ebs:
      VolumeSize: 30          # GiB
      VolumeType: gp3
      Iops: 3000
      Throughput: 125
      DeleteOnTermination: true
      Encrypted: true

Detailed Monitoring: enabled
EBS Optimization: default
```

---

## 4. Database

### 4.1 RDS PostgreSQL

| Parameter | Staging | Production |
|-----------|---------|------------|
| **Engine** | PostgreSQL 17 | PostgreSQL 17 |
| **Instance class** | `db.t3.medium` (2 vCPU, 4 GiB) | `db.r6g.large` (2 vCPU, 16 GiB) |
| **Storage** | 100 GiB gp3 | 500 GiB gp3 |
| **Storage autoscaling** | Disabled | Max 2 TiB, threshold 90% |
| **Multi-AZ** | Disabled | Enabled (synchronous standby) |
| **Backup retention** | 7 days | 35 days |
| **Backup window** | 03:00–04:00 UTC | 02:00–03:00 UTC |
| **Maintenance window** | Mon 04:00–05:00 UTC | Sun 03:00–04:00 UTC |
| **Performance Insights** | Disabled | Enabled (7-day retention) |
| **Deletion protection** | Disabled | Enabled |
| **Auto minor version upgrade** | Enabled | Enabled |
| **Parameter group** | `custom-postgres17-dev` | `custom-postgres17-prod` |

### 4.2 Parameter Groups

**Production parameter group (`custom-postgres17-prod`):**

```ini
shared_buffers = {DBInstanceClassMemory/4}      # 25% of instance memory
effective_cache_size = {DBInstanceClassMemory*3/4}
maintenance_work_mem = {DBInstanceClassMemory/16}
work_mem = 8192                                  # 8 MB
random_page_cost = 1.1
effective_io_concurrency = 200
wal_buffers = 16384                              # 16 MB
max_connections = 200
statement_timeout = 30000                        # 30 seconds
idle_in_transaction_session_timeout = 60000      # 60 seconds
log_min_duration_statement = 1000                # Log slow queries (>1s)
log_connections = 1
log_disconnections = 1
rds.force_ssl = 1
```

### 4.3 Connection Pooling

RDS Proxy sits between application services and the database to prevent connection exhaustion:

| Environment | RDS Proxy | Max Connections | Idle timeout |
|-------------|-----------|----------------|--------------|
| staging | Disabled | — | — |
| prod | Enabled | 100 | 10 min |

**IAM authentication** is used for RDS Proxy, eliminating database passwords from connection strings.

### 4.4 Database Security

- Encryption at rest: AES-256 (AWS KMS, customer-managed key)
- Encryption in transit: TLS 1.3 (enforced via `rds.force_ssl=1`)
- Network isolation: Deployed in private data subnets only
- Automated snapshots: 35-day retention for prod
- Manual snapshots before schema migrations

---

## 5. Caching

### 5.1 ElastiCache Redis

| Parameter | Staging | Production |
|-----------|---------|------------|
| **Engine** | Redis 7.1 | Redis 7.1 |
| **Node type** | `cache.t6g.micro` (1 vCPU, 0.5 GiB) | `cache.r6g.large` (2 vCPU, 13.07 GiB) |
| **Cluster mode** | Disabled | Enabled |
| **Shards** | 1 | 3 (each with 1 replica) |
| **Total nodes** | 1 | 6 |
| **Auto-failover** | Disabled | Enabled |
| **Multi-AZ** | Disabled | Enabled (replicas in different AZs) |
| **Port** | 6379 | 6379 |
| **Encryption at rest** | Disabled | Enabled |
| **Encryption in transit** | Enabled | Enabled |
| **Auth token** | Disabled | Enabled (random token) |
| **Backup retention** | 0 (no backup) | 7 days |
| **Maintenance window** | Mon 05:00–06:00 UTC | Sun 04:00–05:00 UTC |

### 5.2 Redis Key Namespaces

| Namespace | Purpose | TTL | Memory Budget |
|-----------|---------|-----|--------------|
| `session:*` | Auth sessions (JWT blacklist) | 24h | 2 GiB |
| `cache:*` | API response cache | 5m | 4 GiB |
| `rate:*` | Rate limiter counters | 1m | 500 MiB |
| `queue:*` | Background job queues | — | 3 GiB |
| `lock:*` | Distributed locks | 30s | 200 MiB |
| `stream:*` | Redis streams for events | 7d | 3 GiB |

### 5.3 Cluster Mode Configuration (Production)

```
Configuration:
  cluster-enabled: yes
  cluster-require-full-coverage: no
  maxmemory-policy: allkeys-lru
  activedefrag: yes
  lazyfree-lazy-eviction: yes
  lazyfree-lazy-expire: yes
  replica-read-only: yes
```

Client configuration uses the Redis Cluster protocol — application services connect via `ioredis` Cluster class.

---

## 6. Storage

### 6.1 Cloudflare R2 (Primary Object Store)

R2 provides S3-compatible object storage with zero egress fees, used for user-facing media assets.

| Bucket | Purpose | Public Access | Lifecycle |
|--------|---------|--------------|-----------|
| `popcut-media-{env}` | User-uploaded videos, images | No (presigned URLs) | Abort multipart uploads > 7 days |
| `popcut-exports-{env}` | Rendered video exports | No (presigned URLs) | Delete incomplete exports > 24h |
| `popcut-thumbnails-{env}` | Video thumbnails | Yes (CDN) | — |
| `popcut-assets-{env}` | Static assets (templates, fonts) | Yes (CDN) | — |
| `popcut-backups-{env}` | Database & config backups | No | Move to cold storage after 30d, delete after 1y |

**Presigned URL configuration:**
- Upload URLs: 15-minute expiry, `PUT` only
- Download URLs: 1-hour expiry, `GET` only
- Generated server-side by the auth/media services

### 6.2 EBS Volumes

| Volume | Type | Size | IOPS | Throughput | Encrypted | Use Case |
|--------|------|------|------|------------|-----------|----------|
| Root (`/dev/xvda`) | `gp3` | 30 GiB | 3000 | 125 MB/s | Yes | OS + Docker overlay |
| Data (`/dev/xvdf`) | `gp3` | 100 GiB | 3000 | 125 MB/s | Yes | Temp processing files |
| AI (GPU instances) | `gp3` | 200 GiB | 6000 | 250 MB/s | Yes | ML model cache |

**Lifecycle:** EBS volumes are deleted on instance termination. AI services use EFS for persistent model storage.

### 6.3 EFS (Shared File System)

| Parameter | Value |
|-----------|-------|
| Performance mode | `generalPurpose` |
| Throughput mode | `bursting` |
| Lifecycle | Transition files to `IA` after 14 days |
| Backup | Daily backups with 30-day retention |
| Encryption | Enabled at rest (KMS) |
| Mount targets | One per private data subnet |

Used for: shared AI model artifacts, temporary processing workspace, export staging directory.

### 6.4 Storage Hierarchy Summary

```
User upload → Cloudflare R2 (direct presigned PUT)
    ↓
Media service processes → EBS temp → EFS (models) → R2 (output)
    ↓
Export service → R2 (export bucket) → CloudFront CDN → User
```

---

## 7. DNS & CDN

### 7.1 Route 53

| Domain | Type | Record | Target |
|--------|------|--------|--------|
| `popcut.app` | A | Alias | CloudFront distribution |
| `*.popcut.app` | A | Alias | CloudFront distribution |
| `admin.popcut.app` | A | Alias | CloudFront distribution |
| `api.popcut.app` | A | Alias | `api-alb` (regional) |
| `staging.popcut.app` | A | Alias | CloudFront distribution |
| `popcut.app` | MX | — | Google Workspace |
| `popcut.app` | TXT | — | SPF, DKIM, DMARC |

**Health checks:**
- Endpoint: `https://api.popcut.app/health`
- Interval: 30s
- Failure threshold: 3
- Regions: 3 (US East, US West, EU)

### 7.2 CloudFront Distribution

| Parameter | Value |
|-----------|-------|
| **Price class** | PriceClass100 (US, Canada, Europe) |
| **SSL certificate** | ACM `us-east-1` — `*.popcut.app`, `popcut.app` |
| **Minimum TLS** | TLSv1.2_2021 |
| **Supported HTTP** | HTTP/2, HTTP/3 |
| **Default TTL** | 24 hours |
| **Error responses** | 403 → `/404.html` (TTL: 10s), 500 → `/500.html` (TTL: 0s) |
| **WAF** | Attached (see §8.5) |

**Origin configuration:**

| Origin | Behavior Path | Protocol | Cache Policy |
|--------|--------------|----------|-------------|
| S3 `popcut-assets` | `/assets/*` | HTTPS only | `CachingOptimized` (1y max-age) |
| `web-alb` | `/` (default) | HTTPS only | `CachingDisabled` (SSR) |
| S3 `popcut-thumbnails` | `/thumbnails/*` | HTTPS only | `CachingOptimized` (7d max-age) |
| `api-alb` | `/api/*` | HTTPS only | `CachingDisabled` (API) |

**Custom error responses:**

```json
{
  "errorCode": 403,
  "responsePagePath": "/404.html",
  "responseCode": 404,
  "errorCachingMinTtl": 10
}
```

### 7.3 ACM Certificates

| Domain | Region | Validation | Renewal |
|--------|--------|-----------|---------|
| `*.popcut.app`, `popcut.app` | `us-east-1` | DNS (Route53) | Automatic |
| `*.staging.popcut.app` | `us-east-1` | DNS (Route53) | Automatic |

Production certificates are always provisioned in `us-east-1` for CloudFront compatibility. Regional certificates used for ALBs in their respective regions.

---

## 8. Security

### 8.1 Shared Responsibility Model

| Layer | AWS Responsibility | PopCut Responsibility |
|-------|-------------------|----------------------|
| Physical | ✅ | — |
| Network (VPC, firewalls) | ✅ | ✅ (config) |
| OS / Docker | — | ✅ |
| Application code | — | ✅ |
| Secrets management | — | ✅ |
| Data encryption | ✅ (KMS) | ✅ (key management) |

### 8.2 IAM Roles & Policies

**Service roles (EC2 instances):**

| Role | Managed Policies | Permissions |
|------|-----------------|-------------|
| `popcut-ec2-web` | `AmazonSSMManagedInstanceCore` | SSM Session Manager |
| `popcut-ec2-app` | `AmazonSSMManagedInstanceCore`, custom inline | RDS Proxy IAM auth, S3 read, Secrets Manager read, CloudWatch PutMetric |
| `popcut-ec2-ai` | `AmazonSSMManagedInstanceCore`, custom inline | Same as app + EFS mount, GPU config |

**Cross-service roles:**

```json
{
  "Effect": "Allow",
  "Action": [
    "rds-db:connect",
    "secretsmanager:GetSecretValue",
    "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
    "cloudwatch:PutMetricData",
    "ec2:DescribeTags"
  ],
  "Resource": ["*"]
}
```

**Principle of least privilege:** Each service role is scoped to exactly the actions it needs. No wildcard `s3:*` — always scoped to specific buckets.

### 8.3 Secrets Manager

| Secret Name | Contains | Rotation |
|-------------|----------|----------|
| `popcut/prod/database` | RDS master password, connection string | 90 days (Lambda) |
| `popcut/prod/redis` | Redis auth token | Manual |
| `popcut/prod/jwt` | JWT private key, public key | 180 days |
| `popcut/prod/r2` | Cloudflare R2 access key, secret key | Manual |
| `popcut/prod/sentry` | Sentry DSN | Manual |
| `popcut/prod/sendgrid` | SendGrid API key | 90 days (Lambda) |

**Access pattern:** Applications retrieve secrets at startup via the AWS SDK and cache in memory. Secrets are never written to disk or logged.

### 8.4 Security Groups & NACLs

**Network ACLs (stateless, subnet-level):**

| Direction | Rule # | Type | Protocol | Port Range | Source/Dest | Allow/Deny |
|-----------|--------|------|----------|------------|-------------|------------|
| Inbound | 100 | HTTP | TCP | 80 | 0.0.0.0/0 | Allow |
| Inbound | 110 | HTTPS | TCP | 443 | 0.0.0.0/0 | Allow |
| Inbound | 120 | Ephemeral | TCP | 1024-65535 | 0.0.0.0/0 | Allow |
| Inbound | * | All | All | All | 0.0.0.0/0 | Deny |
| Outbound | 100 | All | All | All | 0.0.0.0/0 | Allow |
| Outbound | * | All | All | All | 0.0.0.0/0 | Deny |

### 8.5 WAF (Web Application Firewall)

**WAF ACL:** `popcut-waf-prod` — Attached to CloudFront and public ALBs

| Rule | Priority | Action | Description |
|------|----------|--------|-------------|
| `AWS-AWSManagedRulesCommonRuleSet` | 10 | Block | OWASP Top 10 (SQLi, XSS, LFI, RFI) |
| `AWS-AWSManagedRulesKnownBadInputsRuleSet` | 20 | Block | Known bad inputs, probes |
| `AWS-AWSManagedRulesAmazonIpReputationList` | 30 | Block | Known malicious IPs |
| `AWS-AWSManagedRulesAnonymousIpList` | 40 | Block | VPN, proxy, Tor exit nodes |
| `AWS-AWSManagedRulesBotControlRuleSet` | 50 | Block | Scrapers, crawlers, bots |
| `rate-limit-global` | 60 | Block | 2,000 requests per 5 min per IP |
| `rate-limit-api` | 70 | Block | 500 requests per 5 min per IP to `/api/*` |
| `rate-limit-auth` | 80 | Block | 20 requests per 5 min per IP to `/api/auth/*` |
| `aws-mandatory-headers` | 90 | Block | Missing `Host` header |

**WAF logging:** CloudWatch Logs group `/aws/waf/popcut-prod`, sampled requests only.

### 8.6 Shield

| Feature | Configuration |
|---------|--------------|
| **Shield Standard** | Enabled by default (free) — protects against L3/L4 DDoS |
| **Shield Advanced** | Enabled for production — $3,000/mo |

Shield Advanced provides DDoS cost protection (waives scaling charges from usage spikes) and 24/7 access to the DDoS Response Team (DRT).

### 8.7 Additional Security Controls

- **GuardDuty:** Enabled in all accounts, findings sent to Security Hub
- **Security Hub:** Consolidated security score, CIS 1.4 benchmarks
- **Config:** Rules for required encryption, public access, VPC flow logs
- **VPC Flow Logs:** Enabled on all subnets, delivered to S3 + CloudWatch Logs, 30-day retention
- **CloudTrail:** Multi-region trail, management + data events (S3), log file validation, 7-year retention
- **SSM Session Manager:** Replaces SSH — no bastion SSH keys, no public subnets for EC2
- **IMDSv2:** Required on all EC2 instances

---

## 9. Monitoring

### 9.1 CloudWatch Dashboards

**Production dashboard: `popcut-prod-overview`**

```
┌───────────────────────┬───────────────────────┬───────────────────────┐
│   ALB — Request Count │   ALB — Latency p50   │   ALB — 5xx Rate      │
│   (sparkline, 1h)     │   (sparkline, 1h)     │   (sparkline, 1h)     │
├───────────────────────┼───────────────────────┼───────────────────────┤
│   RDS — Connections   │   RDS — CPU Util      │   RDS — Read IOPS     │
│   (sparkline, 1h)     │   (sparkline, 1h)     │   (sparkline, 1h)     │
├───────────────────────┼───────────────────────┼───────────────────────┤
│   Redis — CPU         │   Redis — Memory      │   Redis — Cache Hits  │
│   (sparkline, 1h)     │   (sparkline, 1h)     │   (sparkline, 1h)     │
├───────────────────────┼───────────────────────┼───────────────────────┤
│   EC2 — CPU Avg       │   EC2 — Mem Avg       │   ASG — Running       │
│   (by ASG, 1h)        │   (by ASG, 1h)        │   (by ASG, 1h)        │
└───────────────────────┴───────────────────────┴───────────────────────┘
```

### 9.2 CloudWatch Alarms

**Critical alarms (page on-call):**

| Alarm Name | Metric | Threshold | Evaluation Periods | Action |
|------------|--------|-----------|-------------------|--------|
| `prod-alb-5xx-rate` | `ALB/5xxCount` | > 1% of requests | 2 of 2 (1 min) | SNS → PagerDuty |
| `prod-rds-cpu-high` | `RDS/CPUUtilization` | > 80% | 3 of 3 (5 min) | SNS → PagerDuty |
| `prod-rds-connections` | `RDS/DatabaseConnections` | > 150 | 1 of 1 (1 min) | SNS → PagerDuty |
| `prod-redis-cpu-high` | `ElastiCache/CPUUtilization` | > 75% | 3 of 3 (5 min) | SNS → PagerDuty |
| `prod-asg-instance-fail` | `AutoScaling/GroupTotalInstances` | < 2 | 1 of 1 (1 min) | SNS → PagerDuty |

**Warning alarms (notify Slack, no page):**

| Alarm Name | Metric | Threshold | Evaluation Periods |
|------------|--------|-----------|-------------------|
| `prod-alb-latency-high` | `ALB/TargetResponseTime` avg | > 2s | 3 of 3 (5 min) |
| `prod-rds-storage-low` | `RDS/FreeStorageSpace` | < 50 GiB | 1 of 1 (5 min) |
| `prod-rds-replica-lag` | `RDS/ReplicaLag` | > 5s | 2 of 2 (5 min) |
| `prod-s3-4xx-errors` | `S3/4xxErrors` | > 50 | 2 of 2 (5 min) |
| `prod-redis-memory-high` | `ElastiCache/DatabaseMemoryUsage` | > 80% | 2 of 2 (5 min) |

### 9.3 CloudWatch Logs

| Log Group | Retention | Source |
|-----------|-----------|--------|
| `/ecs/popcut/web` | 30 days | Next.js app logs (stdout/stderr) |
| `/ecs/popcut/auth-service` | 30 days | NestJS structured JSON logs |
| `/ecs/popcut/ai-service` | 30 days | FastAPI logs |
| `/ecs/popcut/admin` | 14 days | Admin app logs |
| `/aws/alb/popcut-web` | 30 days | ALB access logs |
| `/aws/alb/popcut-api` | 30 days | ALB access logs |
| `/aws/rds/proxy/popcut` | 7 days | RDS Proxy logs |
| `/aws/vpc/flow-logs` | 30 days | VPC Flow Logs |
| `/aws/waf/popcut-prod` | 30 days | WAF sampled requests |

**Log format (structured JSON):**

```json
{
  "timestamp": "2026-06-06T12:00:00Z",
  "level": "info",
  "service": "auth-service",
  "requestId": "req_abc123",
  "method": "POST",
  "path": "/api/auth/login",
  "statusCode": 200,
  "duration": 45,
  "userId": "usr_xyz",
  "error": null,
  "version": "1.2.3"
}
```

### 9.4 AWS X-Ray

**Tracing configuration:**

| Service | Sampling Rate | Annotations |
|---------|--------------|-------------|
| Auth Service | 10% (prod), 100% (dev) | `service`, `version`, `environment` |
| AI Service | 5% (prod) | `service`, `model`, `duration` |
| ALB | 10% (prod) | — |

X-Ray SDK is integrated at the framework level. Traces flow: ALB → NestJS/FastAPI → RDS/Redis HTTP calls.

### 9.5 Sentry (APM)

All services report to Sentry for error tracking and performance monitoring:

- **Error sampling:** 100% (prod)
- **Performance tracing:** 10% (prod), 100% (dev/staging)
- **Release tracking:** Tagged with git SHA + Docker image tag

---

## 10. Cost Optimization

### 10.1 Reserved Instances & Savings Plans

| Commitment | Type | Term | Coverage | Monthly Cost | Savings vs On-Demand |
|------------|------|------|----------|-------------|---------------------|
| Compute Savings Plan | `t3.large`, `t3.medium`, `r6g.large` | 1 year | All EC2 + Fargate | ~$850 | ~30% |
| RDS Reserved Instance | `db.r6g.large` | 1 year | Partial upfront | ~$180 | ~35% |
| ElastiCache Reserved Node | `cache.r6g.large` | 1 year | Partial upfront | ~$90 | ~30% |

**Strategy:** Start with 1-year Compute Savings Plan covering 80% of baseline usage. Convert to 3-year after 6 months of stable usage data.

### 10.2 Auto-Scaling Cost Control

| Policy | Implementation | Est. Annual Savings |
|--------|---------------|-------------------|
| Scheduled scaling (off-peak) | ASG scheduled actions, 2→4 instances overnight | $1,200 |
| Warm pools for ASG | Pre-provisioned, stopped instances | $400 |
| Spot instances (AI service) | Spot fleet for GPU workloads (if interruptible) | $3,000 |
| Dev/staging shutdown | Lambda: stop non-essential instances on nights/weekends | $2,400 |

### 10.3 Storage Lifecycle

| Service | Tier | After | Policy |
|---------|------|-------|--------|
| RDS snapshots | — | 35 days | Automated deletion |
| R2 media (incomplete uploads) | Standard | 7 days | Abort multipart upload |
| R2 exports (incomplete) | Standard | 24 hours | Delete |
| R2 backups | Standard | 30 days | Move to cold storage |
| R2 backups | Cold | 365 days | Delete |
| EBS snapshots | — | 14 days | Automated deletion via DLM |
| CloudWatch Logs | — | 30 days | Expire |
| CloudTrail logs | — | 7 years | Archive to S3 Glacier Deep Archive |

### 10.4 Monthly Cost Estimate (Production)

| Service | Estimated Monthly Cost |
|---------|----------------------|
| EC2 (all ASGs, baseline) | $1,400 |
| RDS (r6g.large + Multi-AZ) | $320 |
| ElastiCache (r6g.large × 6) | $540 |
| ALB (3 public + 1 internal) | $80 |
| NAT Gateway (3 AZs) | $98 |
| CloudFront | $50 |
| WAF + Shield Advanced | $3,050 |
| RDS Proxy | $30 |
| EFS | $20 |
| Route53 | $5 |
| Data transfer (est.) | $200 |
| **Total baseline** | **~$5,793/mo** |
| With Savings Plans/RIs | **~$4,200/mo** |

---

## 11. Deployment Strategy

### 11.1 Blue/Green Deployment

**Application services (NestJS, FastAPI):**

1. Build new Docker image → push to `ghcr.io`
2. Update ASG launch template with new image tag
3. Start instance refresh (50% at a time) — green instances
4. Wait for ALB health checks to pass on green instances
5. Deregister blue instances after 5-minute cooldown
6. Rollback: Cancel instance refresh, re-register blue instances

```
Before:
  ASG: [A] [A] [A] (blue, version 1.0)
  Target group:  [A] [A] [A] ✓

In-progress:
  ASG: [A] [A] [A] [B]
  Target group:  [A] [A] [B] [B] ✓

After:
  ASG: [B] [B] [B] (green, version 2.0)
  Target group:  [B] [B] [B] ✓
```

### 11.2 Rolling Updates

**Static frontends (Next.js web, admin):**

1. Build static export → upload to S3
2. CloudFront invalidation (`/*`)
3. Rollback: Restore previous S3 version, create new invalidation

### 11.3 Canary Releases

**Canary flow (for high-risk changes):**

1. Deploy new version to 10% of instances in a canary ASG
2. Route 5% of traffic to canary via ALB weighted target groups
3. Monitor for 15 minutes (latency, errors, business metrics)
4. If healthy → ramp to 50% for 15 minutes → 100%
5. If degraded → drain canary, roll back, alert

### 11.4 CI/CD Pipeline (GitHub Actions)

```
PR → main/develop
    │
    ├── CI (web.yml + backend.yml)
    │   ├── Install deps
    │   ├── Lint
    │   ├── Build
    │   └── Test (unit + integration)
    │
    ├── Docker build (docker.yml)
    │   ├── Build images
    │   └── Push to ghcr.io
    │
    └── Deploy (deploy.yml, manual approval for prod)
        ├── Staging
        │   ├── Update ASG task definition
        │   ├── Run smoke tests
        │   └── Log results
        └── Production (requires approval)
            ├── Blue/green deploy
            ├── Canary (5% → 50% → 100%)
            ├── Run smoke tests
            └── Notify Slack
```

### 11.5 Deployment Configuration

```yaml
# Deployment parameters per service
deployment:
  strategy: blue_green           # blue_green | rolling | canary
  min_healthy_percent: 100       # During rolling update
  max_surge: 100                 # During rolling update
  health_check_path: /health
  health_check_interval: 30      # seconds
  health_check_timeout: 5        # seconds
  health_check_threshold: 2      # healthy
  unhealthy_threshold: 10
  cooldown_period: 300           # 5 minutes between batches
  rollback:
    automatic: true
    trigger: ">1% 5xx errors in 5 minutes"
```

---

## 12. Disaster Recovery

### 12.1 RPO / RTO Targets

| Scenario | RPO (Recovery Point Objective) | RTO (Recovery Time Objective) |
|----------|-------------------------------|------------------------------|
| Single AZ failure | 0 (zero data loss) | 2 minutes (Multi-AZ failover) |
| Region failure (us-east-1) | 5 minutes | 30 minutes |
| Accidental data deletion | 5 minutes (PITR) | 30 minutes |
| Full region catastrophe | 1 hour (cross-region replica) | 1 hour |

### 12.2 Backup Strategy

| Resource | Method | Frequency | Retention | Location |
|----------|--------|-----------|-----------|----------|
| RDS PostgreSQL | Automated snapshots | Daily | 35 days | Same region |
| RDS PostgreSQL | Point-in-time recovery | Continuous (WAL) | 35 days | Same region |
| RDS PostgreSQL | Manual snapshot | Pre-migration | 90 days | Same region |
| RDS PostgreSQL | Cross-region copy | Daily | 7 days | us-west-2 |
| ElastiCache Redis | Automated backup | Daily | 7 days | Same region |
| EFS | AWS Backup | Daily | 30 days | Same region |
| EBS | DLM snapshots | Daily | 14 days | Same region |
| Terraform state | S3 versioning | Every change | Indefinite | Same region |

### 12.3 Cross-Region Replication

**Primary region:** `us-east-1` (N. Virginia)
**DR region:** `us-west-2` (Oregon)

| Component | DR Strategy |
|-----------|-------------|
| RDS | Cross-region read replica → promote on failover |
| ElastiCache | No cross-region — rebuild from RDS + re-cache on DR activation |
| S3 / R2 | Cross-region replication (S3), pre-signed URLs rebuilt (R2) |
| Route53 | Health-checked failover DNS record |
| CloudFront | Global by default — works from any region |
| ACM | Re-issue certificate in DR region (failover plan step) |

### 12.4 Disaster Recovery Runbook

**DR Activation (Region Failure):**

```
1. DETECT   — Route 53 health checks fail, PagerDuty alerts
2. ASSESS   — Confirm us-east-1 outage via AWS Health Dashboard
3. PROMOTE  — Promote RDS cross-region replica to standalone (us-west-2)
4. ROUTE    — Update Route 53 DNS (TTL: 60s) → point to us-west-2 ALB
5. SCALE    — Apply ASG in us-west-2 (pre-warmed AMI cache)
6. VALIDATE — Run smoke tests, verify metrics dashboard
7. DECLARE  — Update status page, notify stakeholders
```

**DR Recovery (Return to Primary):**

```
1. REPLICATE — Set up new primary in us-east-1 from DR snapshot
2. TEST      — Validate data consistency
3. SWITCH    — Route 53 DNS → back to us-east-1
4. CLEANUP   — Tear down DR resources, document lessons learned
```

### 12.5 Regular DR Testing

| Test | Frequency | Scope |
|------|-----------|-------|
| RDS failover | Quarterly | Verify Multi-AZ auto-failover completes within 2 min |
| Cross-region promotion | Bi-annually | Promote read replica, validate data + app |
| Snapshot restore | Quarterly | Restore RDS snapshot to staging, run smoke tests |
| Full DR drill | Annually | Simulate region failure — full failover runbook |

---

## 13. Architecture Diagram

```
                                  Internet
                                      │
                                      ▼
                              ┌───────────────┐
                              │   CloudFront   │
                              │   CDN (global) │
                              └───────┬───────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
              ┌──────────┐    ┌──────────────┐   ┌──────────┐
              │   WAF    │    │    Route53   │   │   ACM    │
              │ (CloudFront│   │  popcut.app  │   │ *.popcut │
              │  + ALB)  │    └──────────────┘   └──────────┘
              └──────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
┌───────────────┐       ┌───────────────┐
│  Public ALB   │       │  Public ALB   │
│  web.popcut   │       │  api.popcut   │
│  (port 443)   │       │  (port 443)   │
└───────┬───────┘       └───────┬───────┘
        │                       │
        ▼                       ▼
┌─────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                     │
│                                                         │
│  ┌───────────────────────────────────────────┐          │
│  │         Public Subnets (AZ-a/b/c)          │          │
│  │  ┌──────┐   ┌──────┐   ┌──────┐            │          │
│  │  │ NAT  │   │ NAT  │   │ NAT  │            │          │
│  │  │ GW a │   │ GW b │   │ GW c │            │          │
│  │  └──┬───┘   └──┬───┘   └──┬───┘            │          │
│  │     │          │          │                 │          │
│  │  ┌──┴────┐ ┌──┴────┐ ┌──┴────┐             │          │
│  │  │ ALB   │ │ ALB   │ │ ALB   │             │          │
│  │  │ web   │ │ admin │ │ api   │             │          │
│  │  └──┬────┘ └──┬────┘ └──┬────┘             │          │
│  └─────┼─────────┼─────────┼───────────────────┘          │
│        │         │         │                              │
│  ┌─────┼─────────┼─────────┼───────────────────┐          │
│  │     │         │         │                     │          │
│  │  ┌──┴─────────┴─────────┴──┐                 │          │
│  │  │    Private App Subnets   │                 │          │
│  │  │    (AZ-a, AZ-b, AZ-c)    │                 │          │
│  │  │                          │                 │          │
│  │  │  ┌──────────────────┐    │                 │          │
│  │  │  │  Auto Scaling     │    │                 │          │
│  │  │  │  Groups:          │    │                 │          │
│  │  │  │  ┌────────────┐   │    │                 │          │
│  │  │  │  │ Web (Next) │   │    │                 │          │
│  │  │  │  ├────────────┤   │    │                 │          │
│  │  │  │  │ Admin (Next│   │    │                 │          │
│  │  │  │  ├────────────┤   │    │                 │          │
│  │  │  │  │ Auth (Nest)│   │    │                 │          │
│  │  │  │  ├────────────┤   │    │                 │          │
│  │  │  │  │ AI (FastAPI│   │    │                 │          │
│  │  │  │  ├────────────┤   │    │                 │          │
│  │  │  │  │ Export     │   │    │                 │          │
│  │  │  │  ├────────────┤   │    │                 │          │
│  │  │  │  │ Media /    │   │    │                 │          │
│  │  │  │  │ Project /  │   │    │                 │          │
│  │  │  │  │ Template   │   │    │                 │          │
│  │  │  │  └────────────┘   │    │                 │          │
│  │  │  └──────────────────┘    │                 │          │
│  │  └──────────────────────────┘                 │          │
│  │                                                │          │
│  ┌────────────────────────────────────────────┐   │          │
│  │         Private Data Subnets                │   │          │
│  │         (AZ-a, AZ-b, AZ-c)                  │   │          │
│  │                                              │   │          │
│  │  ┌──────────────┐  ┌──────────────────┐     │   │          │
│  │  │  RDS          │  │  ElastiCache      │     │   │          │
│  │  │  PostgreSQL   │  │  Redis 7          │     │   │          │
│  │  │  17           │  │  Cluster mode     │     │   │          │
│  │  │  Multi-AZ     │  │  3 shards × 2     │     │   │          │
│  │  │  + RDS Proxy  │  │  Multi-AZ         │     │   │          │
│  │  └──────┬───────┘  └────────┬─────────┘     │   │          │
│  │         │                   │                │   │          │
│  │  ┌──────┴───────────────────┴──────────┐    │   │          │
│  │  │  EFS (shared AI models, temp)       │    │   │          │
│  │  └─────────────────────────────────────┘    │   │          │
│  └─────────────────────────────────────────────┘   │          │
│                                                    │          │
│  ┌─────────────────────────────────────────────┐   │          │
│  │    Isolated AI/GPU Subnets                   │   │          │
│  │    (AZ-a, AZ-b, AZ-c)                        │   │          │
│  │  ┌──────────────────────┐                    │   │          │
│  │  │ GPU instances (spot)  │                    │   │          │
│  │  │ ML model inference   │                    │   │          │
│  │  └──────────────────────┘                    │   │          │
│  └─────────────────────────────────────────────┘   │          │
│                                                    │          │
└────────────────────────────────────────────────────┘          │
                          │                                     │
                          ▼                                     │
            ┌─────────────────────────┐                        │
            │     Cloudflare R2        │                        │
            │  (S3-compatible object   │                        │
            │   store — media assets,  │                        │
            │   exports, backups)      │                        │
            └─────────────────────────┘                        │
                                                                  │
┌──────────────────────────────────────────────────────────────────┘
│  Supporting Services (AWS)
│
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  │ CloudTrail│  │ GuardDuty│  │ Config   │  │ Security │
│  │ (audit)   │  │ (threat) │  │ (comply) │  │ Hub      │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘
│
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  │ CloudWatch│  │ X-Ray   │  │ Secrets  │  │ IAM      │
│  │ (metrics, │  │ (trace) │  │ Manager  │  │ (authz)  │
│  │ logs,     │  │         │  │ (secrets)│  │          │
│  │ alerts)   │  │         │  │          │  │          │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘
│
│  ┌──────────┐  ┌─────────────────────────────────┐
│  │ SSM      │  │ GitHub Actions (CI/CD)           │
│  │ Session  │  │ ghcr.io container registry       │
│  │ Manager  │  │ Blue/green & canary deployments  │
│  └──────────┘  └─────────────────────────────────┘
│
│  ┌──────────┐  ┌─────────────────────────────────┐
│  │ Sentry   │  │ PagerDuty (on-call)              │
│  │ (errors, │  │ Slack (notifications)            │
│  │ perf)    │  │ Statuspage (status)              │
│  └──────────┘  └─────────────────────────────────┘
│
└─────────────────────────────────────────────────────────┘
```

---

## Appendix A: Terraform State Layout

All AWS infrastructure is provisioned via Terraform. See the `terraform/` directory for the complete implementation.

```
terraform/
├── environments/
│   ├── _global/          # Route53, CloudFront, ACM
│   ├── dev/              # Dev workspace
│   ├── staging/          # Staging workspace
│   └── prod/             # Production workspace
├── modules/
│   ├── vpc/
│   ├── ec2-asg/
│   ├── rds/
│   ├── redis/
│   ├── alb/
│   ├── cloudfront/
│   ├── route53/
│   ├── iam/
│   ├── secrets/
│   ├── monitoring/
│   └── waf/
└── backend.tf            # S3 + DynamoDB state locking
```

---

*This document is maintained alongside the infrastructure code. Any changes to the AWS environment must be reflected here. Update this document when modifying Terraform modules, security group rules, or instance configurations.*
