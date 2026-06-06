#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MONITORING_DIR="$PROJECT_ROOT/docker/monitoring"

echo "=========================================="
echo "  PopCut Monitoring Stack Installer"
echo "=========================================="

# Check prerequisites
echo "[1/5] Checking prerequisites..."

if ! command -v docker &>/dev/null; then
  echo "ERROR: Docker is not installed. Install Docker first."
  exit 1
fi

if ! docker compose version &>/dev/null; then
  echo "ERROR: Docker Compose is not installed or not available."
  exit 1
fi

echo "  Docker: $(docker --version)"
echo "  Docker Compose: $(docker compose version --short)"

# Check if the popcut network exists
echo "[2/5] Checking Docker network..."
if ! docker network inspect popcut_default &>/dev/null 2>&1; then
  echo "  Creating 'popcut_default' network..."
  docker network create popcut_default || true
fi

# Create directories
echo "[3/5] Creating data directories..."
mkdir -p "$MONITORING_DIR/grafana/dashboards"
mkdir -p "$MONITORING_DIR/grafana/datasources"

# Set permissions
echo "[4/5] Setting file permissions..."
chmod 644 "$MONITORING_DIR"/prometheus.yml
chmod 644 "$MONITORING_DIR"/alert.rules.yml
chmod 644 "$MONITORING_DIR"/alertmanager.yml
chmod 644 "$MONITORING_DIR"/loki-config.yml
chmod 644 "$MONITORING_DIR"/promtail.yml
chmod 644 "$MONITORING_DIR"/grafana/datasources/*.yml
chmod 644 "$MONITORING_DIR"/grafana/dashboards/*.json 2>/dev/null || true
chmod 644 "$MONITORING_DIR"/grafana/dashboards/*.yml 2>/dev/null || true

# Start the stack
echo "[5/5] Starting monitoring stack..."
cd "$MONITORING_DIR"
docker compose pull
docker compose up -d

echo ""
echo "=========================================="
echo "  PopCut Monitoring Stack Deployed!"
echo "=========================================="
echo ""
echo "Services:"
echo "  Prometheus:     http://localhost:9090"
echo "  Grafana:        http://localhost:3000 (admin / popcut)"
echo "  Loki:           http://localhost:3100"
echo "  Alertmanager:   http://localhost:9093"
echo "  Node Exporter:  http://localhost:9100"
echo "  cAdvisor:       http://localhost:8080"
echo "  Postgres Exp:   http://localhost:9187"
echo "  Redis Exp:      http://localhost:9121"
echo ""
echo "To stop:  docker compose -f $MONITORING_DIR/docker-compose.yml down"
echo "To view logs: docker compose -f $MONITORING_DIR/docker-compose.yml logs -f"
echo ""
