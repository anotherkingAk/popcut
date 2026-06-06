#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MONITORING_DIR="$PROJECT_ROOT/docker/monitoring"

FAILED=0
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  PopCut Monitoring Health Check"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "=========================================="
echo ""

check() {
  local name="$1"
  local url="$2"
  local expected_code="${3:-200}"

  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$url" 2>/dev/null || echo "000")

  if [ "$code" = "$expected_code" ]; then
    echo -e "  ${GREEN}[OK]${NC} $name ($url -> $code)"
    return 0
  else
    echo -e "  ${RED}[FAIL]${NC} $name ($url -> $code, expected $expected_code)"
    FAILED=1
    return 1
  fi
}

container_running() {
  local name="$1"
  local status
  status=$(docker inspect --format='{{.State.Status}}' "$name" 2>/dev/null || echo "not-found")

  if [ "$status" = "running" ]; then
    echo -e "  ${GREEN}[OK]${NC} Container '$name' is running"
    return 0
  else
    echo -e "  ${RED}[FAIL]${NC} Container '$name' status: $status"
    FAILED=1
    return 1
  fi
}

echo "--- Container Status ---"
container_running "popcut-prometheus"
container_running "popcut-grafana"
container_running "popcut-loki"
container_running "popcut-promtail"
container_running "popcut-alertmanager"
container_running "popcut-node-exporter"
container_running "popcut-cadvisor"
container_running "popcut-postgres-exporter"
container_running "popcut-redis-exporter"

echo ""
echo "--- HTTP Endpoints ---"
check "Prometheus" "http://localhost:9090/-/ready" 200
check "Grafana" "http://localhost:3000/api/health" 200
check "Loki" "http://localhost:3100/ready" 200
check "Alertmanager" "http://localhost:9093/-/ready" 200
check "Node Exporter" "http://localhost:9100/metrics" 200
check "cAdvisor" "http://localhost:8080/healthz" 200
check "Postgres Exporter" "http://localhost:9187/metrics" 200
check "Redis Exporter" "http://localhost:9121/metrics" 200

echo ""
echo "--- Prometheus Targets ---"
PROM_TARGETS=$(curl -s --max-time 5 "http://localhost:9090/api/v1/targets" 2>/dev/null || echo '{}')
UP_COUNT=$(echo "$PROM_TARGETS" | python3 -c "import sys,json; d=json.load(sys.stdin); t=[i for i in d.get('data',{}).get('activeTargets',[]) if i.get('health')=='up']; print(len(t))" 2>/dev/null || echo "0")
TOTAL_COUNT=$(echo "$PROM_TARGETS" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('data',{}).get('activeTargets',[])))" 2>/dev/null || echo "0")

if [ "$TOTAL_COUNT" -gt 0 ] 2>/dev/null; then
  echo -e "  ${GREEN}[OK]${NC} Prometheus targets: $UP_COUNT/$TOTAL_COUNT up"
else
  echo -e "  ${YELLOW}[WARN]${NC} Prometheus targets: $UP_COUNT/$TOTAL_COUNT up (could not parse)"
fi

echo ""
echo "--- Grafana Datasources ---"
DS_COUNT=$(curl -s --max-time 5 "http://localhost:3000/api/datasources" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d))" 2>/dev/null || echo "0")
echo -e "  ${GREEN}[OK]${NC} Grafana datasources configured: $DS_COUNT"

echo ""
echo "--- Alertmanager Status ---"
AM_CLUSTER=$(curl -s --max-time 5 "http://localhost:9093/-/healthy" 2>/dev/null || echo "")
if [ -n "$AM_CLUSTER" ]; then
  echo -e "  ${GREEN}[OK]${NC} Alertmanager is healthy"
else
  echo -e "  ${RED}[FAIL]${NC} Alertmanager health check failed"
  FAILED=1
fi

echo ""
echo "=========================================="
if [ "$FAILED" -eq 0 ]; then
  echo -e " ${GREEN} All checks passed! Stack is healthy.${NC}"
else
  echo -e " ${RED} Some checks failed. Review the output above.${NC}"
  echo ""
  echo "Quick fixes:"
  echo "  docker compose -f $MONITORING_DIR/docker-compose.yml logs --tail=50 <service>"
  echo "  docker compose -f $MONITORING_DIR/docker-compose.yml restart <service>"
fi
echo "=========================================="
exit "$FAILED"
