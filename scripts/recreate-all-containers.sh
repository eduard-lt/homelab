#!/bin/bash
#
# Recreate all containers to apply new CasaOS labels
#

set -e

HOMELAB_BASE="/home/eduard/homelab"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

recreate_service() {
    local service_path="$1"
    local service_name=$(basename $(dirname "$service_path"))
    
    log_info "Recreating: $service_name"
    
    cd "$(dirname "$service_path")"
    
    # Recreate container (pulls new labels)
    docker-compose up -d 2>&1 | tail -5
    
    # Brief wait for startup
    sleep 2
    
    # Check status
    if docker-compose ps | grep -q "Up"; then
        log_info "✓ $service_name is running"
    else
        log_warn "⚠ $service_name may have issues, check logs"
    fi
    
    echo ""
}

log_info "Recreating all containers to apply CasaOS labels..."
echo ""

# Media apps
for app in lidarr overseerr prowlarr qbittorrent radarr readarr sonarr tautulli; do
    if [[ -f "$HOMELAB_BASE/media/$app/docker-compose.yml" ]]; then
        recreate_service "$HOMELAB_BASE/media/$app/docker-compose.yml"
    fi
done

# Monitoring apps
for app in grafana netdata; do
    if [[ -f "$HOMELAB_BASE/monitoring/$app/docker-compose.yml" ]]; then
        recreate_service "$HOMELAB_BASE/monitoring/$app/docker-compose.yml"
    fi
done

# Services (skip discord-bot if not needed, traefik is critical)
log_warn "Skipping discord-bot (not critical)"
recreate_service "$HOMELAB_BASE/services/traefik/docker-compose.yml"

log_info "Done! All containers recreated with new labels."
log_info "Next: Register with CasaOS using register-with-casaos.sh"
