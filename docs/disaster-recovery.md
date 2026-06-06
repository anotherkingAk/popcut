# PopCut Disaster Recovery Plan

> **Version:** 1.0  
> **Owner:** Platform Engineering  
> **Last Updated:** $(date +%Y-%m-%d)  
> **Review Cycle:** Quarterly

---

## Table of Contents

1. [Recovery Objectives](#1-recovery-objectives)
2. [System Architecture](#2-system-architecture)
3. [Backup Strategy](#3-backup-strategy)
4. [Recovery Scenarios](#4-recovery-scenarios)
5. [Step-by-Step Procedures](#5-step-by-step-procedures)
6. [Runbook](#6-runbook)
7. [Testing Schedule](#7-testing-schedule)
8. [Contact Escalation Matrix](#8-contact-escalation-matrix)
9. [Backup Validation](#9-backup-validation)
10. [Appendices](#10-appendices)

---

## 1. Recovery Objectives

### 1.1 RPO / RTO Targets

| System       | RPO (Recovery Point Obj.) | RTO (Recovery Time Obj.) | Priority |
|-------------|--------------------------|--------------------------|----------|
| PostgreSQL  | 1 hour                   | 4 hours                  | Critical |
| Redis       | 1 hour                   | 2 hours                  | High     |
| MinIO / S3  | 24 hours                 | 8 hours                  | Medium   |
| Full System | 1 hour                   | 4 hours                  | Critical |

### 1.2 Definitions

- **RPO**: Maximum acceptable data loss measured in time. A 1-hour RPO means we accept losing at most 1 hour of data.
- **RTO**: Maximum acceptable downtime to restore service. A 4-hour RTO means the system must be fully operational within 4 hours of declaration.
- **Critical**: Complete loss of service or data. Affects all users.
- **High**: Partial loss of service or degraded performance. Affects subsets of users.
- **Medium**: Non-critical data loss. Affects internal tooling or archival data.

### 1.3 Assumptions

- Backups are stored in S3-compatible object storage (MinIO / R2) on separate infrastructure from primary systems.
- Network connectivity between recovery environment and backup storage is available.
- Engineers executing recovery have SSH access to recovery hosts and the required credentials.
- Source code and infrastructure definitions are available in the git repository.

---

## 2. System Architecture

### 2.1 Service Topology

```
┌─────────────────────────────────────────────────────┐
│                   Production                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │PostgreSQL│  │  Redis   │  │  MinIO (Storage) │  │
│  │ :5432    │  │ :6379    │  │ :9000 / :9001    │  │
│  └────┬─────┘  └────┬─────┘  └────────┬─────────┘  │
│       │              │                  │           │
│       └──────────────┴──────────────────┘           │
│                        │                            │
└────────────────────────┼────────────────────────────┘
                         │
                    Backup Pipeline
                         │
┌────────────────────────┼────────────────────────────┐
│                   Backup Storage                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  MinIO / R2 (popcut-backups)                 │   │
│  │  ├─ postgres/YYYY/MM/DD/                    │   │
│  │  ├─ redis/YYYY/MM/DD/                       │   │
│  │  ├─ minio/YYYY/MM/DD/                       │   │
│  │  └─ manifests/                              │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

```
Production DB ──> pg_dump (custom format) ──> gzip ──> S3 (daily)
Production DB ──> WAL archiving (continuous) ──> S3 (5-min intervals)
Redis ──> BGSAVE ──> dump.rdb ──> gzip ──> S3 (daily)
MinIO ──> rclone/aws s3 sync ──> S3 (daily)
```

---

## 3. Backup Strategy

### 3.1 PostgreSQL

| Aspect          | Detail                                      |
|----------------|---------------------------------------------|
| Tool           | `pg_dump` (custom format, `-Fc`)            |
| Frequency      | Daily full backup at 2:00 AM                |
| WAL Archiving  | Continuous (every 5 minutes)                |
| Retention      | 7 daily, 4 weekly, 12 monthly               |
| Format         | Compressed `.dump.gz`                       |
| Verification   | Checksum (SHA256) + test query on restore   |
| Storage        | `s3://popcut-backups/postgres/YYYY/MM/DD/`  |

### 3.2 Redis

| Aspect          | Detail                                      |
|----------------|---------------------------------------------|
| Tool           | `redis-cli BGSAVE` + file copy              |
| Frequency      | Daily at 2:00 AM                            |
| Retention      | 7 daily, 4 weekly, 12 monthly               |
| Format         | Compressed `.rdb.gz`                        |
| Verification   | Checksum (SHA256)                           |
| Storage        | `s3://popcut-backups/redis/YYYY/MM/DD/`     |

### 3.3 MinIO

| Aspect          | Detail                                      |
|----------------|---------------------------------------------|
| Tool           | `aws s3 sync`                               |
| Frequency      | Daily at 2:00 AM                            |
| Retention      | 7 daily, 4 weekly                           |
| Exclusions     | `tmp/*`, `temp/*`, `*.swp`                  |
| Storage        | `s3://popcut-backups/minio/YYYY/MM/DD/`     |
| Manifest       | File listing (checksums + sizes)            |

### 3.4 Backup Schedule

```
Time (UTC)   | Mon | Tue | Wed | Thu | Fri | Sat | Sun
-------------|-----|-----|-----|-----|-----|-----|-----
02:00        | F   | F   | F   | F   | F   | F   | F    Full backup (all components)
03:00        | C   | C   | C   | C   | C   | C   | C    Cleanup retention
06:00        | V   | V   | V   | V   | V   | V   | V    Validate backups
Every 5 min  | W   | W   | W   | W   | W   | W   | W    WAL archiving

F = Full backup, C = Cleanup, V = Validation, W = WAL archive
```

---

## 4. Recovery Scenarios

### 4.1 Scenario Matrix

| # | Scenario                     | Severity | RTO Target | Restore Method                      |
|---|------------------------------|----------|------------|-------------------------------------|
| 1 | Database corruption          | Critical | 4 hours    | pg_restore from latest full backup  |
| 2 | Accidental data deletion     | High     | 2 hours    | Point-in-time recovery (WAL)        |
| 3 | Entire region failure        | Critical | 4 hours    | Cross-region restore from S3        |
| 4 | Ransomware attack            | Critical | 8 hours    | Air-gapped backup restore           |
| 5 | Redis data loss              | High     | 2 hours    | Redis dump.rdb restore              |
| 6 | MinIO data loss              | Medium   | 8 hours    | s3 sync from backup bucket          |
| 7 | Configuration corruption     | Medium   | 2 hours    | Git restore + infra redeploy        |

### 4.2 Escalation Path

```
First Responder (On-Call Engineer)
    │
    ├── Resolved within 1 hour? ──> Close incident
    │
    └── Escalate after 1 hour
            │
            ├── Platform Engineering Lead
            │       │
            │       ├── Resolved within 2 hours? ──> Close incident
            │       │
            │       └── Escalate after 2 hours
            │               │
            │               ├── Engineering Director
            │               │       │
            │               │       ├── Resolved within 4 hours? ──> Close incident
            │               │       │
            │               │       └── Escalate after 4 hours
            │               │               │
            │               │               └── CTO / VP Engineering
            │               │                       │
            │               │                       └── Declare disaster / invoke crisis team
            │               │
            │               └── Communication team notified for user-facing outage
            │
            └── SRE team paged for infrastructure issues
```

---

## 5. Step-by-Step Procedures

### 5.1 Database Corruption — pg_restore from Latest Backup

**Trigger:** Application reports constraint violations, `pg_isready` fails, or queries return corruption errors.

**Severity:** Critical  
**RTO:** 4 hours  
**Expected Downtime:** ~30-60 minutes for restore

#### Steps

```bash
# 1. Assess the damage
ssh popcut@db-host
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;" popcut
sudo -u postgres psql -c "CHECKPOINT;" popcut

# 2. Verify backup availability
ssh popcut@backup-host
./scripts/restore/postgres-restore.sh --list

# 3. Stop application traffic (prevent writes)
ssh popcut@app-host
systemctl stop popcut-web popcut-worker

# 4. Restore latest backup
ssh popcut@db-host
export DROP_EXISTING=true
./scripts/restore/postgres-restore.sh --latest

# 5. Validate the restore
# (The script runs validation automatically — check output for table count)

# 6. Restart application
ssh popcut@app-host
systemctl start popcut-web popcut-worker

# 7. Verify application health
curl -f http://localhost:3000/health
```

### 5.2 Accidental Data Deletion — Point-in-Time Recovery

**Trigger:** `DELETE` or `DROP` statement executed without `WHERE` clause, or script error causes data loss.

**Severity:** High  
**RTO:** 2 hours  
**Expected Downtime:** ~30-90 minutes

#### Prerequisites

WAL archiving must be enabled. Archives stored at `s3://popcut-backups/postgres/wal/`.

#### Steps

```bash
# 1. Determine the point-in-time to restore to
# Find the exact time of the damaging query from application logs:
grep "DELETE FROM users" /var/log/popcut/app.log

# Example: 2024-03-15 14:23:45 UTC

# 2. Prepare a recovery.conf
cat > /tmp/recovery.conf << EOF
restore_command = 'aws s3 cp s3://popcut-backups/postgres/wal/%f %p --endpoint-url http://localhost:9000'
recovery_target_time = '2024-03-15 14:23:00 UTC'
recovery_target_action = 'promote'
EOF

# 3. Stop database
systemctl stop postgresql

# 4. Restore full backup
./scripts/restore/postgres-restore.sh --latest

# 5. Place PostgreSQL in recovery mode with PITR target
cp /tmp/recovery.conf /var/lib/postgresql/data/recovery.conf
chown postgres:postgres /var/lib/postgresql/data/recovery.conf

# 6. Start PostgreSQL in recovery mode
systemctl start postgresql

# 7. Monitor recovery progress
tail -f /var/log/postgresql/postgresql.log
# Look for: "recovery stopping before commit of transaction ..."
# Look for: "recovery has paused"

# 8. Verify data is restored
sudo -u postgres psql -c "SELECT count(*) FROM users;" popcut

# 9. If correct, resume
sudo -u postgres psql -c "SELECT pg_wal_replay_resume();" popcut

# 10. Start application
systemctl start popcut-web popcut-worker
```

### 5.3 Entire Region Failure — Cross-Region Restore

**Trigger:** Cloud provider region outage, complete datacenter failure, or network partition isolating the primary region.

**Severity:** Critical  
**RTO:** 4 hours  
**Expected Downtime:** ~2-4 hours

#### Steps

```bash
# 1. Declare disaster and activate secondary region
# Notify on-call engineering via PagerDuty/#ops channel

# 2. Provision infrastructure in secondary region
cd /opt/popcut/infra
terraform workspace select secondary
terraform apply -auto-approve

# 3. Configure backup storage access in secondary region
export S3_ENDPOINT="https://backup-secondary.example.com"
export S3_BUCKET="popcut-backups"

# 4. Restore PostgreSQL
ssh popcut@secondary-db
./scripts/restore/postgres-restore.sh --latest

# 5. Restore Redis
ssh popcut@secondary-redis
./scripts/restore/redis-restore.sh --latest

# 6. Restore MinIO
ssh popcut@secondary-minio
CONFIRM_DANGER=yes ./scripts/restore/minio-restore.sh --latest

# 7. Point DNS to secondary region
# Update Route53 / Cloudflare DNS record to point to secondary load balancer

# 8. Verify full system health
curl -f https://popcut.example.com/health

# 9. Update status page
./scripts/update-status.sh --incident resolved
```

### 5.4 Ransomware Attack — Air-Gapped Backup Restore

**Trigger:** Encrypted files detected, ransom note found, or monitoring alerts on mass file modifications.

**Severity:** Critical  
**RTO:** 8 hours  
**Expected Downtime:** ~4-8 hours

#### Critical First Steps

```bash
# 1. IMMEDIATELY ISOLATE AFFECTED SYSTEMS
# Do NOT power off (preserves forensic evidence)
# Disconnect network interfaces

# On each host:
systemctl stop popcut-web popcut-worker
ip link set eth0 down

# 2. Contain the spread
# Block storage account access
# Revoke compromised credentials
# Rotate all secrets

# 3. Assess the scope
# Determine which systems are encrypted
# Check if backups are accessible (should be air-gapped)
```

#### Recovery from Air-Gapped Backups

```bash
# 4. Provision clean infrastructure
# Use immutable infrastructure — do NOT restore compromised hosts
cd /opt/popcut/infra
terraform apply -auto-approve

# 5. Verify backup integrity
# Run checksum verification against stored manifests
aws s3 cp s3://popcut-backups/manifests/ . --recursive --endpoint-url <air-gapped-endpoint>
sha256sum -c manifest-*.txt

# 6. Restore from air-gapped backup storage
# Air-gapped storage is physically isolated or uses write-once media
export S3_ENDPOINT="https://airgap-backup.internal"
export S3_BUCKET="popcut-backups"

ssh popcut@new-db
./scripts/restore/postgres-restore.sh --latest

ssh popcut@new-redis
./scripts/restore/redis-restore.sh --latest

ssh popcut@new-minio
CONFIRM_DANGER=yes ./scripts/restore/minio-restore.sh --latest

# 7. Restore configuration from version control
cd /opt/popcut
git clone git@github.com:org/popcut-infra.git
git checkout <last-known-good-tag>

# 8. Deploy application
make deploy

# 9. Enable monitoring and alerting
# Verify all metrics are reporting
# Enable intrusion detection systems

# 10. Post-incident
# Forensics investigation
# Root cause analysis
# Security audit
# Rotate all credentials
```

### 5.5 Redis Data Loss

**Trigger:** Redis process crash with persistence failure, `FLUSHALL` executed accidentally, or corrupted dump.rdb.

**Severity:** High  
**RTO:** 2 hours  
**Expected Downtime:** ~15-30 minutes

#### Steps

```bash
# 1. Check current Redis state
redis-cli -h localhost -p 6379 INFO persistence
redis-cli -h localhost -p 6379 DBSIZE

# 2. List available Redis backups
./scripts/restore/redis-restore.sh --list

# 3. If Redis is still running but corrupted, flush it
redis-cli -h localhost -p 6379 FLUSHALL

# 4. Restore from latest backup
./scripts/restore/redis-restore.sh --latest

# 5. Validate
redis-cli -h localhost -p 6379 DBSIZE
# Compare with expected key count

# 6. If application uses Redis as cache, warm it up
# (Optional: run cache warming script if available)
```

### 5.6 MinIO Data Loss

**Trigger:** Accidental bucket deletion, object versioning disabled, or storage hardware failure.

**Severity:** Medium  
**RTO:** 8 hours  
**Expected Downtime:** ~1-4 hours (depends on data volume)

#### Steps

```bash
# 1. Assess damage
aws s3 ls s3://popcut/ --endpoint-url http://localhost:9000 --recursive --summarize

# 2. List available backup dates
./scripts/restore/minio-restore.sh --list

# 3. Restore from backup
CONFIRM_DANGER=yes ./scripts/restore/minio-restore.sh --latest

# 4. Verify restoration
aws s3 ls s3://popcut/ --endpoint-url http://localhost:9000 --recursive --summarize
```

---

## 6. Runbook

### 6.1 On-Call Engineer Runbook

#### Initial Assessment (First 15 Minutes)

```
1. Is the issue confirmed?
   - Check monitoring dashboard: https://monitor.popcut.internal
   - Check recent deployments: git log --oneline -5
   - Check application logs: journalctl -u popcut-web -n 100 --no-pager

2. What is the severity?
   - CRITICAL: Complete outage, data loss, or security incident
   - HIGH: Partial outage, degraded performance
   - MEDIUM: Non-critical data loss, cosmetic issues

3. Declare incident
   - #incidents channel in Slack
   - PagerDuty if after hours
```

#### Quick Reference — Common Commands

```bash
# Check database status
sudo -u postgres pg_isready
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;" popcut

# Check Redis status
redis-cli ping
redis-cli dbsize

# Check MinIO status
curl -f http://localhost:9000/minio/health/live

# Check backup status
tail -100 /var/log/popcut/backups/full-backup-*.log

# List latest backup files
aws s3 ls s3://popcut-backups/postgres/ --endpoint-url http://localhost:9000 --recursive | tail -5
aws s3 ls s3://popcut-backups/redis/ --endpoint-url http://localhost:9000 --recursive | tail -5
aws s3 ls s3://popcut-backups/minio/ --endpoint-url http://localhost:9000 --recursive | tail -5
```

#### Decision Tree

```
┌─────────────────────────────┐
│  Is the database accessible? │
├───────┬─────────────┬───────┤
│  YES  │    PARTIAL   │  NO   │
│  Go   │   Go to     │  Go   │
│  to A │   Section   │  to B │
│       │   5.1/5.2   │       │
└───┬───└─────────────└───┬───┘
    │                      │
    ▼                      ▼
  Check            Provision new DB
  application      instance, restore
  data integrity   from latest backup
    │               (Section 5.1)
    │
    ▼
  Any corruption?
  ┌───┴───┐
  │ YES   │  NO
  │       │
  ▼       ▼
Restore  Check
from     application
backup   logs for
(Sec 5.1)other issues
```

### 6.2 Communication Templates

#### Incident Declaration

```
INCIDENT: [INC-XXXX]
Severity: [CRITICAL|HIGH|MEDIUM]
Service: [PostgreSQL|Redis|MinIO|Full System]
Impact: [Describe user-facing impact]
Started: [Timestamp]
Status: [Investigating|Mitigating|Resolved]
Lead: [Name]

Update: [Describe what happened, what we're doing, ETA]
```

#### Status Update (Every 30 Minutes)

```
INCIDENT: [INC-XXXX] — Update #[N]
Time: [Timestamp]
What we know: [Brief summary]
What we're doing: [Current recovery action]
Next update: [Timestamp + 30 min]
```

#### Resolution

```
INCIDENT: [INC-XXXX] — RESOLVED
Time: [Timestamp]
Duration: [X hours Y minutes]
Root cause: [Summary]
Action items:
  - [ ] Post-mortem scheduled
  - [ ] Monitoring improvements
  - [ ] Runbook updates
```

---

## 7. Testing Schedule

### 7.1 Quarterly DR Drills

| Quarter | Focus Area               | Date        | Success Criteria                                              |
|---------|--------------------------|-------------|---------------------------------------------------------------|
| Q1      | PostgreSQL restore       | March 15    | Full pg_restore + validation under 1 hour                     |
| Q2      | Full system restore      | June 15     | Full system restore in secondary region under 4 hours         |
| Q3      | Redis + MinIO restore    | September 15| Redis RPO < 1h, MinIO RTO < 2h                                |
| Q4      | Ransomware simulation    | December 15 | Air-gapped restore complete under 8 hours                     |

### 7.2 Weekly Validation

| Day       | Test                                   | Automated |
|-----------|----------------------------------------|-----------|
| Monday    | Verify PostgreSQL backup checksums     | Yes (cron)|
| Tuesday   | Verify Redis backup checksums          | Yes (cron)|
| Wednesday | Test restore on staging DB             | Manual    |
| Thursday  | Verify MinIO backup manifests          | Yes (cron)|
| Friday    | Review backup logs for warnings/errors | Manual    |

### 7.3 Monthly PITR Test

```bash
# On staging environment, once per month:
# 1. Restore full backup
./scripts/restore/postgres-restore.sh --latest

# 2. Replay WAL to a specific point in time
# (See Section 5.2 for PITR procedure)

# 3. Verify data consistency
sudo -u postgres psql -c "SELECT count(*) FROM information_schema.tables;" popcut

# 4. Record test results
echo "PITR test $(date +%Y-%m-%d): PASSED" >> /var/log/popcut/dr-drills.log
```

### 7.4 Annual Full-Scale Exercise

Once per year, conduct a full failover exercise:

1. Announce maintenance window (4 hours)
2. Simulate region failure
3. Provision secondary region from scratch
4. Restore all systems from backups
5. Switch production traffic to secondary
6. Run for 2 hours (verify all features)
7. Fail back to primary
8. Document lessons learned

---

## 8. Contact Escalation Matrix

### 8.1 Primary Contacts

| Role                    | Name              | Phone             | Email                    | Backup          |
|-------------------------|-------------------|-------------------|--------------------------|-----------------|
| On-Call Engineer        | Rotation          | +1-555-0100       | oncall@popcut.internal   | SRE Team        |
| Platform Engineering    | Alice Smith       | +1-555-0101       | alice@popcut.internal    | Bob Johnson     |
| SRE Lead                | Bob Johnson       | +1-555-0102       | bob@popcut.internal      | Carol Williams  |
| Engineering Director    | Carol Williams    | +1-555-0103       | carol@popcut.internal    | David Brown     |
| CTO                     | David Brown       | +1-555-0104       | david@popcut.internal    | CEO             |
| Security Lead           | Eve Davis         | +1-555-0105       | eve@popcut.internal      | Frank Miller    |
| DB Administrator        | Frank Miller      | +1-555-0106       | frank@popcut.internal    | Alice Smith     |

### 8.2 Vendor / External Contacts

| Service         | Contact                  | Account #     | SLA         |
|-----------------|--------------------------|---------------|-------------|
| MinIO / R2      | Cloudflare Support       | POPCUT-1234   | 1 hour      |
| Cloud Provider  | AWS/Azure/GCP Support    | POPCUT-5678   | 15 min      |
| DNS Provider    | Cloudflare Support       | POPCUT-9012   | 1 hour      |
| Incident Response| CrowdStrike             | POPCUT-3456   | 30 min      |

### 8.3 Communication Channels

| Channel       | Purpose                         | Link / Info                              |
|---------------|---------------------------------|------------------------------------------|
| Slack         | Real-time incident coordination | #incidents, #ops, #engineering           |
| PagerDuty     | Automated alerting              | popcut-pd.pagerduty.com                  |
| Email         | Formal notifications            | ops@popcut.internal                      |
| Status Page   | User-facing status              | status.popcut.com                        |
| Zoom Bridge   | War room (if needed)            | https://zoom.popcut.internal/war-room    |

---

## 9. Backup Validation

### 9.1 Automated Validation (Daily Cron)

The daily validation cron runs at 6:00 AM and performs:

```
1. Check that all three backup types ran in the last 24 hours
2. Verify SHA256 checksums match stored manifests
3. Test PostgreSQL backup by restoring to an ephemeral instance
4. Verify Redis backup is valid RDB format
5. Verify MinIO backup is non-empty
6. Report results to #ops channel and ops@popcut.internal
```

### 9.2 Manual Validation Procedure

```bash
# 1. List latest backups for each service
echo "=== PostgreSQL ==="
aws s3 ls s3://popcut-backups/postgres/ --endpoint-url http://localhost:9000 --recursive | sort | tail -5

echo "=== Redis ==="
aws s3 ls s3://popcut-backups/redis/ --endpoint-url http://localhost:9000 --recursive | sort | tail -5

echo "=== MinIO ==="
aws s3 ls s3://popcut-backups/minio/ --endpoint-url http://localhost:9000 --recursive | sort | tail -5

# 2. Download latest manifest
aws s3 cp \
    s3://popcut-backups/manifests/$(aws s3 ls s3://popcut-backups/manifests/ --endpoint-url http://localhost:9000 | sort | tail -1 | awk '{print $4}') \
    /tmp/manifest.txt \
    --endpoint-url http://localhost:9000

# 3. Verify checksums (if manifest contains local paths)
# Download one backup and checksum it
aws s3 cp \
    s3://popcut-backups/postgres/$(aws s3 ls s3://popcut-backups/postgres/ --endpoint-url http://localhost:9000 --recursive | grep dump.gz | sort | tail -1 | awk '{print $4}') \
    /tmp/test-backup.dump.gz \
    --endpoint-url http://localhost:9000

sha256sum /tmp/test-backup.dump.gz
```

### 9.3 Restore Testing on Staging

```bash
# For PostgreSQL
./scripts/restore/postgres-restore.sh --latest

# Expected output:
#   Validation passed: 42 tables found in popcut
#   Database size: 256 MB

# For Redis
./scripts/restore/redis-restore.sh --latest

# Expected output:
#   Validation passed: Redis contains 15023 keys

# For MinIO
CONFIRM_DANGER=yes ./scripts/restore/minio-restore.sh --latest

# Expected output:
#   Source bucket now contains 2048 objects
```

### 9.4 Backup Size Baselines

Track these baselines to detect anomalies:

| Service    | Expected Size | Growth Rate | Alert Threshold |
|------------|---------------|-------------|-----------------|
| PostgreSQL | ~2 GB         | ~50 MB/day  | ±20% from avg   |
| Redis      | ~500 MB       | ~10 MB/day  | ±20% from avg   |
| MinIO      | ~50 GB        | ~200 MB/day | ±20% from avg   |

---

## 10. Appendices

### A. Environment Variables Reference

| Variable          | Default               | Description                          |
|-------------------|-----------------------|--------------------------------------|
| `DB_HOST`         | `localhost`           | PostgreSQL host                      |
| `DB_PORT`         | `5432`                | PostgreSQL port                      |
| `DB_NAME`         | `popcut`              | Database name                        |
| `DB_USER`         | `popcut`              | Database user                        |
| `DB_PASSWORD`     | `popcut`              | Database password                    |
| `REDIS_HOST`      | `localhost`           | Redis host                           |
| `REDIS_PORT`      | `6379`                | Redis port                           |
| `S3_ENDPOINT`     | `http://localhost:9000` | S3-compatible endpoint              |
| `S3_BUCKET`       | `popcut-backups`      | Backup bucket name                   |
| `S3_ACCESS_KEY`   | `popcut`              | S3 access key                        |
| `S3_SECRET_KEY`   | `popcut123`           | S3 secret key                        |
| `BACKUP_DIR`      | `/tmp/popcut-backups` | Local staging directory              |
| `LOG_DIR`         | `/var/log/popcut/backups` | Log directory                  |
| `RETENTION_DAILY` | `7`                   | Daily backups to keep                |
| `RETENTION_WEEKLY`| `4`                   | Weekly backups to keep               |
| `RETENTION_MONTHLY`| `12`                 | Monthly backups to keep              |
| `EMAIL_TO`        | *(empty)*             | Failure notification email           |
| `DROP_EXISTING`   | `false`               | Drop DB before restore               |
| `CONFIRM_DANGER`  | `no`                  | Safety flag for destructive ops      |

### B. Script Reference

| Script                                   | Purpose                      |
|------------------------------------------|------------------------------|
| `scripts/backup/postgres-backup.sh`      | PostgreSQL backup            |
| `scripts/backup/redis-backup.sh`         | Redis backup                 |
| `scripts/backup/minio-backup.sh`         | MinIO/s3 backup              |
| `scripts/backup/full-backup.sh`          | Orchestrate all backups      |
| `scripts/backup/backup-cron.sh`          | Install cron schedule        |
| `scripts/restore/postgres-restore.sh`    | PostgreSQL restore           |
| `scripts/restore/redis-restore.sh`       | Redis restore                |
| `scripts/restore/minio-restore.sh`       | MinIO/s3 restore             |

### C. Metrics and Alerting

| Alert Name                  | Condition                          | Severity | Action               |
|-----------------------------|------------------------------------|----------|----------------------|
| BackupFailed                | Any backup script exits non-zero   | Critical | Page on-call         |
| BackupStale                 | No backup in > 28 hours            | Warning  | Investigate          |
| BackupSizeAnomaly           | Backup size deviates > 20%         | Warning  | Check for corruption |
| RestoreTestFailed           | Validation query fails             | Critical | Investigate backups  |
| BackupStorageUsage          | Bucket > 80% capacity              | Warning  | Review retention     |
| WALArchiveStale             | No WAL in > 10 minutes             | Critical | Check WAL archiving  |

### D. Recovery Checklist

Use this checklist during any recovery operation:

```
[ ] 1. Incident declared in #incidents
[ ] 2. Impact assessed and documented
[ ] 3. Affected services identified
[ ] 4. Backup availability confirmed
[ ] 5. Application traffic stopped (if needed)
[ ] 6. Restore procedure started
[ ] 7. Restore validated
[ ] 8. Application traffic restored
[ ] 9. Monitoring verified
[ ] 10. Status page updated
[ ] 11. Post-mortem scheduled
```

### E. Changelog

| Date       | Author          | Changes                                      |
|------------|-----------------|----------------------------------------------|
| $(date +%Y-%m-%d) | Platform Eng | Initial version                              |

---

> **"Trust, but verify."** — Always validate backups, never assume they work.
