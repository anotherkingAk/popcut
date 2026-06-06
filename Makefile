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

# Admin Web
admin-dev:
	cd apps/admin-web && pnpm dev

# Admin Mobile (requires Flutter SDK)
admin-mobile-dev:
	cd apps/admin-mobile && flutter run -d chrome

# Setup full dev environment
setup: install dev-services auth-db-setup
	echo "Setup complete. Run 'make dev' to start."

# Monitoring
monitoring-up:
	bash scripts/monitoring/install.sh

monitoring-down:
	docker compose -f docker/monitoring/docker-compose.yml down

monitoring-logs:
	docker compose -f docker/monitoring/docker-compose.yml logs -f

monitoring-health:
	bash scripts/monitoring/health-check.sh

monitoring-restart:
	docker compose -f docker/monitoring/docker-compose.yml restart

# Terraform
terraform-init:
	cd infra/terraform && terraform init

terraform-plan:
	cd infra/terraform && terraform plan -var-file=environments/$(env)/terraform.tfvars

terraform-apply:
	cd infra/terraform && terraform apply -var-file=environments/$(env)/terraform.tfvars

terraform-destroy:
	cd infra/terraform && terraform destroy -var-file=environments/$(env)/terraform.tfvars

terraform-deploy:
	bash infra/terraform/scripts/deploy.sh

# Backups
backup-all:
	bash scripts/backup/full-backup.sh

backup-db:
	bash scripts/backup/postgres-backup.sh

backup-redis:
	bash scripts/backup/redis-backup.sh

backup-minio:
	bash scripts/backup/minio-backup.sh

restore-db:
	bash scripts/restore/postgres-restore.sh

restore-redis:
	bash scripts/restore/redis-restore.sh

restore-minio:
	bash scripts/restore/minio-restore.sh

setup-cron:
	bash scripts/backup/backup-cron.sh

# Initialize project (first time)
init:
	pnpm install
	cp services/auth-service/.env.example services/auth-service/.env
	cp apps/web/.env.example apps/web/.env
	make dev-services
	cd services/auth-service && npx prisma generate && npx prisma db push
	echo "Initialization complete."
