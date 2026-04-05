# Docker Network Segmentation

## Networks Created

All services are now organized into isolated networks for security and traffic management.

### Network List

1. **gaming_net**
   - Purpose: Game servers
   - Services: Project Zomboid, V Rising, Minecraft/Crafty
   - Isolation: Cannot access media or monitoring services

2. **services_net**
   - Purpose: General services
   - Services: Actual Budget, Portainer, PhotoPrism, Homebridge, Vaultwarden
   - Isolation: Separated from media and gaming traffic

3. **media_net**
   - Purpose: Media server stack
   - Services: Plex, Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Overseerr, Tautulli, qBittorrent
   - Isolation: Heavy traffic isolated from other services

4. **monitoring_net**
   - Purpose: Monitoring and observability
   - Services: Netdata, Grafana, Prometheus (future)
   - Isolation: Can monitor all networks via container name resolution

## Benefits

- **Security**: Services cannot access each other unless explicitly connected
- **Performance**: Network traffic isolation prevents congestion
- **Organization**: Clear service grouping
- **Troubleshooting**: Easier to identify network issues by service type

## Implementation

All docker-compose.yml files in the homelab repo now include network definitions:

```yaml
networks:
  gaming_net:
    name: gaming_net
    driver: bridge
```

## Multi-Network Services

Some services may need access to multiple networks:

- **Monitoring** tools can join all networks to collect metrics
- **Reverse Proxy** (when added) will join all networks for routing

To add a service to multiple networks:

```yaml
services:
  myservice:
    networks:
      - media_net
      - monitoring_net
```

## Network Commands

```bash
# List all networks
docker network ls

# Inspect a network
docker network inspect gaming_net

# See which containers are on a network
docker network inspect gaming_net -f '{{range .Containers}}{{.Name}} {{end}}'

# Remove unused networks
docker network prune
```

## Status

- ✅ gaming_net: Created
- ✅ services_net: Created
- ✅ media_net: Created
- ✅ monitoring_net: Created

All new services use these networks by default.
