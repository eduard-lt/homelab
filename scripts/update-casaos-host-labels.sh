#!/bin/bash
# Update host labels from Tailscale IP to LAN IP

APPS=(
    "media/sonarr:8989"
    "media/radarr:7878"
    "media/lidarr:8686"
    "media/readarr:8787"
    "media/prowlarr:9696"
    "media/overseerr:5055"
    "media/tautulli:8181"
    "media/qbittorrent:8081"
    "monitoring/grafana:3003"
    "monitoring/netdata:19999"
    "services/traefik:9080"
)

LAN_IP="172.26.1.31"

for app_port in "${APPS[@]}"; do
    IFS=':' read -r app port <<< "$app_port"
    app_name=$(basename "$app")
    
    echo "[INFO] Updating $app_name"
    cd "/home/eduard/homelab/$app"
    
    # Use sed to update the host label in docker-compose.yml
    sed -i "s|host=100.70.106.23:$port|host=$LAN_IP:$port|g" docker-compose.yml
    
    # Recreate container
    docker-compose up -d --force-recreate 2>&1 | tail -1
done

echo ""
echo "[INFO] All host labels updated to LAN IP: $LAN_IP"
