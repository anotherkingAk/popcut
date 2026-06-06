# PopCut Production Launch Checklist

## 1. Security Audit Checklist

### Authentication & Authorization
- [ ] **JWT secret strength** — Confirm `JWT_SECRET` is a cryptographically random 256-bit key (not `popcut-dev-secret-change-in-production`). Rotate immediately if weak.
- [ ] **JWT expiration** — Access token expiry is 7d (`auth.service.ts:68`). Consider reducing to 15–60min with refresh token rotation for production.
- [ ] **Refresh token rotation** — Verify refresh tokens are invalidated after use to prevent replay attacks.
- [ ] **Role-based access control** — Verify `RolesGuard` is applied to all admin endpoints. Confirm `OWNER`, `ADMIN`, `MODERATOR` roles map correctly to UI permission boundaries.
- [ ] **Password hashing** — Confirm bcrypt cost factor is ≥12 (`auth.service.ts:19`). Verify no plaintext passwords in logs or error responses.
- [ ] **Rate limiting** — Install and configure `@nestjs/throttler` or a reverse-proxy rate limiter (nginx/Cloudflare). Apply 10 req/min on `/auth/login`, 100 req/min on API endpoints.
- [ ] **Account lockout** — Implement lockout after 5 failed login attempts within 15 minutes.

### Network & Transport
- [ ] **HTTPS enforcement** — All traffic must terminate TLS 1.2+ at the load balancer. Redirect HTTP → 301 HTTPS. Configure HSTS header (max-age=31536000; includeSubDomains).
- [ ] **CORS configuration** — Verify `CORS_ORIGIN` in production is restricted to the specific deployed domain(s), not `http://localhost:3000` (`main.ts:10`).
- [ ] **Helmet / security headers** — Enable NestJS Helmet or equivalent: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `X-XSS-Protection: 0`, `Referrer-Policy: strict-origin-when-cross-origin`, `Content-Security-Policy`.

### Data & Injection
- [ ] **SQL injection prevention** — Prisma parameterized queries are used throughout. Audit raw SQL queries if any exist.
- [ ] **NoSQL injection** — If MongoDB is used anywhere, validate all query operators are sanitized.
- [ ] **XSS prevention** — React/Next.js auto-escapes JSX. Verify any `dangerouslySetInnerHTML` usage is audited and sanitized.
- [ ] **Input validation** — NestJS `ValidationPipe` with `whitelist: true` is enabled globally (`main.ts:13`). Verify all DTOs use class-validator decorators.
- [ ] **File upload validation** — Restrict asset uploads to allowed MIME types (image/video/audio only). Set max file size limits. Scan uploads for malware.

### Secrets & Infrastructure
- [ ] **Secrets management** — Never commit secrets to git. Use a vault or env-file injection (AWS Secrets Manager, Doppler, 1Password). Audit `.env` files and remove from repos.
- [ ] **Dependency vulnerability scan** — Run `npm audit` / `pnpm audit` in all packages and services. Fix or suppress critical/high CVEs. Consider Snyk or Dependabot for continuous scanning.
- [ ] **IAM permissions audit** — Database users have least-privilege access. No root DB credentials in application code. Service accounts scoped to specific operations.
- [ ] **Network security group review** — Restrict ingress to ports 80/443 only (or 4001 if directly exposed). DB port (5432) must not be publicly accessible. Redis/MQ ports are internal.
- [ ] **Logging & monitoring** — Never log tokens, passwords, or PII. Ensure structured JSON logging with log levels (`warn`, `error`) for security events.

---

## 2. Performance Audit Checklist

### API & Server
- [ ] **API response times <200ms p95** — Measure all critical endpoints. Identify slow queries with distributed tracing (OpenTelemetry).
- [ ] **Database query optimization** — Review Prisma query logs for N+1 patterns. Ensure `include` joins are intentional. Use `select` to fetch only needed columns.
- [ ] **Index coverage analysis** — All query `where`, `orderBy`, and `join` fields must have indexes. Review Prisma schema `@@index` directives. Run `EXPLAIN ANALYZE` on slow queries.
- [ ] **Connection pooling** — Prisma uses a connection pool. Tune pool size based on concurrent request load (default: typical 10–20 connections per instance).
- [ ] **Database CPU/memory** — Monitor PostgreSQL `pg_stat_activity` for long-running queries. Set `statement_timeout` to 30s.

### Caching
- [ ] **Cache hit ratio targets** — API response cache (Redis/memory) hit ratio >80% for read-heavy endpoints (templates, effects, filters).
- [ ] **CDN configuration** — Static assets (thumbnails, previews, fonts) served via CDN with 1y cache headers and immutable flag. Dynamic content cached at edge with short TTLs.
- [ ] **Redis cache warmup** — Pre-populate cache for most-requested content on deploy.

### Frontend
- [ ] **Bundle size budgets** — Main JS chunk <200KB gzipped. Route-based code splitting active. Verify with `next-bundle-analyzer`.
- [ ] **Image optimization** — Use Next.js `<Image>` with remote patterns configured. Serve WebP/AVIF formats. Implement responsive image breakpoints.
- [ ] **Lighthouse scores 90+** — Performance, Accessibility, Best Practices, SEO all ≥90 on desktop and mobile.
- [ ] **Core Web Vitals** — LCP <2.5s, FID <100ms, CLS <0.1. Monitor with RUM (Vercel Analytics / Google Analytics).
- [ ] **Server-side rendering** — Verify critical pages use SSR/SSG appropriately. Avoid client-side waterfalls for data fetching.
- [ ] **Font loading** — Self-host fonts or use `font-display: swap`. Preload primary fonts. Subset font files to needed character sets.

---

## 3. Load Testing Plan

### Tools
- **Primary**: [k6](https://k6.io) (scriptable, CI-friendly)
- **Alternative**: [Artillery](https://www.artillery.io) (YAML-based, good for complex scenarios)

### Test Scenarios

#### Scenario 1: Normal Load
- **Target**: Simulate 100 concurrent users
- **Duration**: 10 minutes
- **Ramp-up**: 10 users/second
- **Endpoints**: Mix of 60% read (GET templates/effects/filters), 20% auth (login/register), 15% write (create project, export), 5% admin
- **Think time**: 1–3s random delay between requests

#### Scenario 2: Peak Load
- **Target**: Simulate 500 concurrent users
- **Duration**: 15 minutes
- **Ramp-up**: 25 users/second
- **Endpoints**: Same distribution as Normal Load
- **Objective**: Verify system maintains <500ms p95 under peak

#### Scenario 3: Stress Test
- **Target**: Ramp from 0 to 1000 concurrent users
- **Duration**: 20 minutes
- **Ramp-up**: 50 users/second until errors appear or response times degrade beyond threshold
- **Objective**: Identify the breaking point of each service

#### Scenario 4: Spike Test
- **Target**: Sudden jump from 50 → 500 concurrent users in 10 seconds
- **Duration**: 5 minutes at peak, then drop back to 50
- **Objective**: Verify auto-scaling behavior and recovery under sudden load

### Key Endpoints to Test

| Endpoint | Method | Priority | Expected p95 |
|---|---|---|---|
| `/api/v1/auth/login` | POST | Critical | <500ms |
| `/api/v1/auth/register` | POST | High | <500ms |
| `/api/v1/templates` | GET | High | <200ms |
| `/api/v1/effects` | GET | High | <200ms |
| `/api/v1/filters` | GET | Medium | <200ms |
| `/api/v1/projects` | POST | Medium | <500ms |
| `/api/v1/export-jobs` | POST | High | <1000ms |
| `/api/v1/admin/dashboard` | GET | Low | <500ms |
| `/api/v1/admin/users` | GET | Low | <500ms |

### Success Criteria
- Error rate <1% across all scenarios
- p95 response time <500ms for all endpoints
- p99 response time <1000ms
- Zero authentication failures due to overload
- No data corruption in concurrent write tests

### Test Data Requirements
- 10,000+ user accounts with varied subscription tiers
- 50,000+ projects with associated assets
- 500+ templates, effects, filters, fonts, audio tracks
- Pre-generated JWT tokens for authenticated test flows
- Realistic file sizes for upload tests (1–50MB)

---

## 4. Cost Analysis

### Monthly Cost Breakdown (Estimated)

| Service | Configuration | Estimated Monthly Cost |
|---|---|---|
| **Compute (API)** | 4× t3.medium EC2 (or equivalent containers) | $240 |
| **Compute (AI Service)** | 2× g4dn.xlarge GPU instances | $600 |
| **Database** | RDS PostgreSQL db.r6g.large (multi-AZ) | $350 |
| **Cache** | ElastiCache Redis r6g.large | $180 |
| **File Storage** | S3 / Cloudflare R2 (10TB) | $250 |
| **CDN** | Cloudflare Pro / AWS CloudFront | $200 |
| **Monitoring** | DataDog / Grafana Cloud | $150 |
| **Email Service** | SendGrid / SES (100K emails/mo) | $50 |
| **CI/CD** | GitHub Actions (2000 min/mo) | $0–$50 |
| **Total** | | **$2,070–$2,120** |

### Reserved Instance Recommendations
- **Database**: 1-year reserved RDS instance → ~30% savings ($105)
- **Compute**: 1-year EC2 Reserved → ~40% savings ($96)
- **Redis**: 1-year reserved ElastiCache → ~30% savings ($54)
- **Total with RI**: **~$1,815/mo** (save ~$255/mo)

### Cost Optimization Opportunities
1. **Right-size GPU instances**: If AI jobs are batch-able, use spot instances (60% savings).
2. **Storage lifecycle**: Transition assets older than 30 days to S3 Infrequent Access, 90+ days to Glacier.
3. **Cache efficiency**: Increase Redis hit ratio >90% to reduce DB reads. Lower tier if memory usage <60%.
4. **CDN origin shield**: Reduce origin requests with Cloudflare Argo or AWS Origin Shield ($50+/mo).
5. **Auto-scaling**: Scale down to 2 instances during low-traffic hours (11PM–7AM).
6. **Database read replicas**: Offload analytics/reporting queries to read replicas rather than primary.
7. **Remove unused resources**: Audit and clean up unattached EBS volumes, stale load balancers, unused IPs.

---

## 5. Monitoring Validation Checklist

### Metrics & Observability
- [ ] **All services emitting metrics** — API, AI, export, media, project, template services all push metrics to the monitoring platform (DataDog / Grafana / Prometheus).
- [ ] **Key health metrics active** — CPU, memory, disk, request rate, error rate, p50/p95/p99 latency, active connections.
- [ ] **Business metrics** — DAU/MAU, signups, exports, revenue, AI jobs completed, storage used.
- [ ] **Custom dashboards** — At minimum: Service Health, API Latency, Database Performance, Business KPIs, Error Overview.
- [ ] **Dashboards show correct data** — Verify each panel against known values. Test with seeded production-like data.

### Alerts
- [ ] **Critical alerts configured** — Service down (5xx rate >5%), DB connection pool exhaustion, p95 latency >1s, error rate >2%.
- [ ] **Warning alerts configured** — CPU >80%, disk >85%, memory >80%, response time >500ms, certificate expiry <30 days.
- [ ] **Alert channels connected** — PagerDuty / Slack / email. Verify each alert triggers the correct notification.
- [ ] **Alert fatigue prevention** — No noisy alerts. Group correlated alerts. Set appropriate thresholds. Use escalation policies.
- [ ] **On-call rotation** — Schedule documented. Runbook accessible for each alert type.

### Logging
- [ ] **Log aggregation working** — All services forward structured JSON logs to centralized system (ELK / Loki / DataDog). Confirm logs are searchable within 30 seconds of emission.
- [ ] **Log levels correct** — `error` for failures, `warn` for degraded state, `info` for key events, `debug` never in production.
- [ ] **PII redaction** — Tokens, passwords, emails not logged. Configure automatic redaction patterns.
- [ ] **Error tracking** — Sentry or equivalent configured for frontend and backend. Source maps uploaded. Error grouping working.

### Uptime & Synthetic Monitoring
- [ ] **Synthetic monitors active** — HTTP health checks every 30s for all public endpoints from ≥3 geographic regions.
- [ ] **Uptime SLA tracking** — Monitor <5m downtime per month (99.99% target). Alert on first failure.

---

## 6. Backup Validation Checklist

### Database
- [ ] **Automated backups running** — PostgreSQL automated backups enabled with 7-day retention minimum.
- [ ] **WAL archiving** — Continuous WAL archiving for point-in-time recovery (PITR). Target RPO <5 minutes.
- [ ] **Backup frequency** — Full backup daily + WAL every 5 minutes.
- [ ] **Encrypted backups** — Backups encrypted at rest (AES-256). Restore procedure requires decryption keys.
- [ ] **Cross-region backup** — Copy backups to a secondary region for disaster recovery.
- [ ] **Restore procedure tested** — Successful restore to a staging environment within the last 30 days. Documented and timed.
- [ ] **Database backup size** — Monitor size trends. Alert if growth exceeds expected +20%.

### File Storage (S3 / R2)
- [ ] **Asset backups** — S3 versioning enabled on all asset buckets. Lifecycle policy to transition older versions to IA/Glacier.
- [ ] **Cross-region replication** — Critical buckets replicate to secondary region asynchronously.
- [ ] **Backup integrity check** — Monthly integrity scan (checksum verification) of stored assets.

### Application & Configuration
- [ ] **Infrastructure-as-Code** — Terraform / Pulumi state backed up and versioned. Config files (env vars, feature flags) exportable and backed up daily.
- [ ] **CI/CD artifacts** — Build artifacts stored with version tags. Rollback to any prior deploy in <10 minutes.

### Retention
- [ ] **Retention policy** — Daily backups kept for 7 days, weekly for 4 weeks, monthly for 12 months.
- [ ] **Compliance** — If GDPR/HIPAA applies, ensure backup retention and deletion processes allow full data erasure on request.

---

## 7. CI/CD Validation Checklist

### Workflows
- [ ] **All workflows pass** — Lint, typecheck, unit tests, integration tests, build all green on `main` branch.
- [ ] **Test coverage thresholds** — Unit test coverage ≥80% for shared packages (api-sdk). Integration tests for all API endpoints.
- [ ] **Security scanning in CI** — Dependency audit (`npm audit`), SAST (CodeQL / Semgrep), secret scanning (truffleHog / git-secrets) run on every PR.
- [ ] **Docker image builds** — All services build via multi-stage Dockerfiles. Images are <500MB, scanned for vulnerabilities, and tagged with commit SHA.

### Deployment
- [ ] **Deployment pipeline tested end-to-end** — Push to `main` → build → test → staging deploy → smoke test → production deploy. All stages validated.
- [ ] **Zero-downtime deployment** — Rolling update or blue/green strategy. No dropped connections during deploy.
- [ ] **Database migrations run safely** — Migrations are backward-compatible. Run before code deploy. Have rollback migration ready.
- [ ] **Environment parity** — Staging mirrors production in architecture (same DB version, same Redis config, same instance types).

### Rollback
- [ ] **Rollback procedure tested** — Full rollback of a production deploy executed in the last 30 days. Time to rollback <10 minutes.
- [ ] **Database migration rollback** — Every migration has a `down` script. Tested that rollback restores previous schema without data loss.
- [ ] **Artifact versioning** — Every deploy maps to a unique version tag. Rollback re-deploys the previous version's artifact.

### Infrastructure
- [ ] **Immutable infrastructure** — Servers are never modified in-place. All changes go through IaC and are deployed fresh.
- [ ] **Health checks post-deploy** — Deploy pipeline waits for health check pass on new instances before cutting traffic.
- [ ] **Canary deployments** — (Optional) Route 2% of traffic to new version for 5 minutes before full rollout.

---

## 8. Go-Live Procedure

### Pre-Launch Checklist

#### T-7 Days
- [ ] All security items in Section 1 verified and signed off.
- [ ] Load testing completed with results meeting success criteria.
- [ ] Backup and restore procedures documented and tested.
- [ ] Runbook for incident response reviewed by on-call team.
- [ ] Monitoring dashboards and alerts validated.
- [ ] Stakeholder go/no-go meeting scheduled.

#### T-24 Hours
- [ ] Final database backup taken and verified.
- [ ] All feature flags for new functionality set to desired states.
- [ ] CDN cache purged for stale content.
- [ ] SSL/TLS certificates confirmed valid (no expiry within 30 days).
- [ ] DNS TTL lowered to 60 seconds for fast cutover.
- [ ] Staging environment frozen (no more deploys until after launch).
- [ ] Rollback plan reviewed and confirmed executable within 10 minutes.
- [ ] Communication drafted for internal team and external users.

#### T-1 Hour
- [ ] Production database backup taken.
- [ ] Last check that all services are healthy (green dashboards).
- [ ] CI/CD pipeline ready — last successful build tagged.
- [ ] On-call engineer and launch lead at terminals.
- [ ] Announce "Pre-Launch Hold" — no merges to main until after go-live.

### Launch Sequence

```
Step 1  — DNS change: point production domain to new load balancer IP
Step 2  — Wait 5 minutes for DNS propagation
Step 3  — Deploy auth-service (database migrations first, then code)
Step 4  — Verify auth-service health: /api/v1/auth/me returns 200
Step 5  — Deploy remaining services (project, media, export, AI, template)
Step 6  — Verify all service health endpoints return 200
Step 7  — Deploy web frontend (Next.js build + deploy to hosting)
Step 8  — Verify frontend loads and can authenticate
Step 9  — Run smoke test suite (10 critical user flows)
Step 10 — DNS TTL restore to normal (300s+)
Step 11 — CDN cache warm by hitting key endpoints
Step 12 — Announce "Launch Complete" to internal team
```

### Rollback Criteria
Rollback immediately if any of the following occur:
- Error rate >5% across any service
- p95 response time >2000ms for critical endpoints
- Database migration causes data inconsistency or corruption
- Authentication failures >2% of login attempts
- Frontend fails to load in any major browser
- Cannot complete a core user flow (register → create project → export)

### Rollback Procedure
1. **Revert DNS** to previous load balancer.
2. **Redeploy previous Docker images** for each service.
3. **Run database rollback migration** (if forward migration ran).
4. **Verify all health checks pass** on the rolled-back version.
5. **Confirm no data loss** — compare pre-launch backup with current state.

### Post-Launch Monitoring Period (72 hours)
- **Hour 0–2**: Active monitoring — launch lead and on-call watch dashboards continuously.
- **Hour 2–24**: High vigilance — respond to any alert within 5 minutes.
- **Hour 24–72**: Standard monitoring — respond to critical alerts within 15 minutes.
- **Day 7**: Post-launch retrospective — review metrics, incidents, and optimizations.

### Communication Plan
| Event | Channel | Audience | Timing |
|---|---|---|---|
| Launch start | Internal Slack | Engineering team | T-5 min |
| Launch complete | Internal Slack | All stakeholders | At completion |
| Post-launch summary | Email | Leadership, Product | Day +1 |
| User-facing announcement | In-app banner, email | All users | Day +1 |
| Incident during launch | PagerDuty + Slack | On-call engineer | Immediate |
| Major outage | Status page | All users | Within 5 min |

---

## 9. Risk Assessment Matrix

### Scoring
- **Likelihood**: 1 (Rare) → 5 (Almost Certain)
- **Impact**: 1 (Negligible) → 5 (Critical)
- **Risk Score** = Likelihood × Impact

| # | Risk Category | Risk Description | L | I | Score | Mitigation Strategy |
|---|---|---|---|---|---|---|
| R1 | **Security** | JWT secret leak via env file or logs | 3 | 5 | **15** | Rotate immediately. Use secrets manager. Audit git history for committed secrets. |
| R2 | **Security** | SQL injection via unsanitized input | 2 | 5 | **10** | Prisma parameterized queries + ValidationPipe. Regular DAST scanning. |
| R3 | **Security** | CORS misconfiguration allowing unauthorized origins | 2 | 4 | **8** | Restrict CORS origin to explicit prod domain. Test with curl/Postman. |
| R4 | **Security** | Rate limiting bypass on auth endpoints | 3 | 4 | **12** | Implement at reverse proxy + application layer. Monitor for brute force patterns. |
| R5 | **Security** | XSS via user-generated content (project names, descriptions) | 2 | 4 | **8** | React auto-escaping + Content-Security-Policy header. Sanitize on input. |
| R6 | **Performance** | Database query timeout under peak load | 3 | 4 | **12** | Query optimization, connection pooling, `statement_timeout`. P99 <1s. |
| R7 | **Performance** | Cache stampede on cache expiry | 3 | 3 | **9** | Implement re-validation (conditional GETs) and stale-while-revalidate. |
| R8 | **Performance** | CDN cold start — all cache misses on new deploy | 2 | 3 | **6** | Cache warm script runs post-deploy. Pre-fetch top 100 assets. |
| R9 | **Availability** | Database primary failure (multi-AZ failover) | 2 | 5 | **10** | Multi-AZ RDS. Test failover monthly. Read replicas for read-heavy load. |
| R10 | **Availability** | Downstream service (AI/Export) unavailability | 3 | 4 | **12** | Circuit breaker pattern. Graceful degradation. Queue-based retry. |
| R11 | **Availability** | Redis outage causing auth failures | 2 | 4 | **8** | Redis Sentinel / ElastiCache Multi-AZ. Session fallback to DB. |
| R12 | **Availability** | DNS propagation delay causing intermittent downtime | 3 | 3 | **9** | Low TTL during launch. Use multiple DNS providers. Health-check aware DNS. |
| R13 | **Data Loss** | Database backup corruption | 2 | 5 | **10** | Daily verified restores. Cross-region backup copy. Checksum validation. |
| R14 | **Data Loss** | Bad migration causing irreversible data changes | 2 | 5 | **10** | All migrations have `down` scripts. Test on staging first. Backup before deploy. |
| R15 | **Data Loss** | Accidental bulk delete (S3 bucket objects, DB records) | 2 | 4 | **8** | Soft-delete where possible. S3 versioning. DB `deletedAt` field pattern. |
| R16 | **Compliance** | GDPR data erasure request cannot be fulfilled | 2 | 5 | **10** | Implement user deletion cascade across all services. Test full erasure flow. |
| R17 | **Compliance** | Privacy policy / ToS not updated for new features | 1 | 4 | **4** | Legal review before launch. In-app consent for new data collection. |
| R18 | **Compliance** | Accessibility violations (ADA/WCAG) | 2 | 3 | **6** | Automated a11y tests. Manual screen reader audit. Remediate before launch. |

### High-Risk Items (Score ≥12)
The following risks require explicit sign-off from the CTO/VP Engineering before launch:

| Risk | Score | Owner | Sign-off |
|---|---|---|---|
| R1 — JWT secret leak | 15 | Security Lead | |
| R4 — Rate limiting bypass | 12 | Backend Lead | |
| R6 — DB timeout | 12 | Backend Lead | |
| R10 — Service unavailability | 12 | Infrastructure Lead | |
| R3 — CORS misconfig | 8 | Backend Lead | *(Acknowledge)* |

### Risk Treatment Plan
- **Accept**: Risks with score <6 (monitor but no immediate action)
- **Mitigate**: Risks with score 6–11 (implement mitigations before launch)
- **Transfer**: Consider cyber insurance for data loss/breach scenarios
- **Avoid**: Any risk with score ≥15 must be resolved before launch

---

*Document version: 1.0.0 — Last updated: 2026-06-06*
*Owner: Platform Engineering*
*Approved by: ________________________________*
