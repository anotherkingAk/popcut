# PopCut

AI-powered professional video editing platform.

## Architecture

```
apps/
  web/          Next.js 16 web app (editor)
  admin/        Next.js 16 admin panel
  mobile/       Flutter mobile app
packages/
  ui/           Shared UI components
  editor-engine/ Core video editing engine
  api-sdk/      API client SDK
  animations/   Animation library
services/
  auth-service/    NestJS API (auth, admin, RBAC)
  ai-service/      FastAPI ai-service
docker/
  docker-compose.yml  PostgreSQL 17, Redis 7, MinIO
```

## Quick Start

```bash
# Prerequisites: Node.js 22+, pnpm 10+, Docker

# Install dependencies
pnpm install

# Start infrastructure (PostgreSQL, Redis, MinIO)
make dev-services

# Set up database
make auth-db-setup

# Start development
pnpm dev
```

## Tech Stack

- **Frontend**: Next.js 16, React 19, TypeScript, Tailwind CSS 4, Framer Motion
- **Backend**: NestJS 11, Prisma, PostgreSQL, Redis
- **AI**: FastAPI, PyTorch, Whisper, OpenCV
- **Storage**: MinIO (local), AWS S3 (production)
- **Video**: FFmpeg, WebRTC
- **DevOps**: Docker, Kubernetes, GitHub Actions
