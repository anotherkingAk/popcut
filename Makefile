.PHONY: dev dev-services install build lint test clean

dev:
	pnpm dev

dev-services:
	docker compose -f docker/docker-compose.yml up -d

dev-services-stop:
	docker compose -f docker/docker-compose.yml down

install:
	pnpm install

build:
	pnpm build

lint:
	pnpm lint

test:
	pnpm test

clean:
	pnpm clean
	rm -rf apps/*/node_modules
	rm -rf packages/*/node_modules
	rm -rf services/*/node_modules
	rm -rf node_modules

# Auth service
auth-dev:
	cd services/auth-service && pnpm dev

auth-db-setup:
	cd services/auth-service && pnpm db:generate && pnpm db:push

# AI service
ai-dev:
	cd services/ai-service && uvicorn src.main:app --reload --port 8000

# Web
web-dev:
	cd apps/web && pnpm dev

# Setup full dev environment
setup: install dev-services auth-db-setup
	echo "Setup complete. Run 'make dev' to start."

# Initialize project (first time)
init:
	pnpm install
	cp services/auth-service/.env.example services/auth-service/.env
	cp apps/web/.env.example apps/web/.env
	make dev-services
	cd services/auth-service && npx prisma generate && npx prisma db push
	echo "Initialization complete."
