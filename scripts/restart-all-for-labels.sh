#!/bin/bash
# Clean restart all containers to apply CasaOS labels

set -e

APPS=(
    "media/radarr"
    "media/lidarr" 
    "media/readarr"
    "media/prowlarr"
    "media/overseerr"
    "media/tautulli"
    "media/qbittorrent"
    "monitoring/grafana"
    "monitoring/netdata"
    "services/traefik"
)

cd /home/eduard/homelab

for app in "${APPS[@]}"; do
    echo "[INFO] Restarting: $app"
    cd "/home/eduard/homelab/$app"
    docker-compose down 2>&1 | grep -E "(Removing|Stopping)" || true
    docker-compose up -d 2>&1 | grep -E "(Creating|Starting|done)" || true
    sleep 1
done

echo ""
echo "[INFO] All containers restarted. Checking status..."
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(radarr|sonarr|lidarr|prowlarr|overseerr|tautulli|qbittorrent|grafana|netdata|traefik)"
