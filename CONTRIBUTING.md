# Contributing to PopCut

## Branch Strategy

- `main` — Production-ready code. Deploys to production.
- `develop` — Integration branch. Deploys to staging.
- `feat/*` — Feature branches off `develop`.
- `fix/*` — Bug fix branches.
- `chore/*` — Maintenance, dependencies, tooling.

All feature/fix branches merge into `develop` via PR.
`develop` merges into `main` via release PR.

## Commit Convention

Conventional Commits enforced:

```
feat: new feature
fix: bug fix
chore: maintenance, deps
docs: documentation
refactor: code restructure
test: tests
ci: CI/CD changes
```

## PR Requirements

- [ ] Code follows existing style
- [ ] No lint errors (`pnpm lint`)
- [ ] TypeScript compiles (`pnpm build`)
- [ ] Tests pass (`pnpm test`)
- [ ] Self-reviewed
- [ ] Changelog entry added

## Development Setup

```bash
make init        # Install deps + start services + DB setup
make dev         # Start all dev servers
```

## Adding a New Database Model

1. Add model to `services/auth-service/prisma/schema.prisma`
2. Run `make auth-db-setup`
3. Create migration: `cd services/auth-service && npx prisma migrate dev --name describe_change`
4. Generate NestJS CRUD in `admin.service.ts` + `admin.controller.ts`

## Architecture Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Monorepo | pnpm workspaces | Shared types, single CI |
| Backend | NestJS + Prisma | Type-safe, structured |
| AI | FastAPI + Celery | Python ML ecosystem |
| Frontend | Next.js App Router | SSR, RSC, modern |
| Mobile | Flutter | Cross-platform perf |
| Database | PostgreSQL 17 | JSON, full-text search |
| Cache | Redis 7 | Multi-model |
| Storage | Cloudflare R2 | S3-compatible, cheap |
| Infra | Terraform + AWS | IaC, battle-tested |
| Monitoring | Prometheus + Grafana | Open source, flexible |
| CI/CD | GitHub Actions | Integrated, OIDC |
