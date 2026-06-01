# CapCard Pro

AI-powered professional video editing platform.

## Architecture

```
apps/
  web/          Next.js 16 web app
  desktop/      Electron desktop app (coming soon)
  mobile/       Flutter mobile app (coming soon)
packages/
  ui/           Shared UI components
  editor-engine/ Core video editing engine
  api-sdk/      API client SDK
  animations/   Animation library
services/
  auth-service/    NestJS authentication service
  project-service/ Project management service
  export-service/  Video export service
  ai-service/      FastAPI AI service
  media-service/   Media processing service
ai-services/
  captioning/      AI caption generation
  object-detection/Object detection models
  video-generation/Text-to-video pipeline
  voice-cloning/   Voice synthesis
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
