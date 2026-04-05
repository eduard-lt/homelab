# Resource Limits Guidelines

## Overview

Resource limits prevent containers from consuming excessive CPU/memory and starving other services.

## Current State

Most containers have NO resource limits, except:
- Plex: 16GB memory limit
- qBittorrent: 16GB memory limit  
- Radarr, Sonarr, Lidarr, Readarr, Overseerr, Tautulli: 16GB memory limit
- Netdata: 1.8GB memory limit

## Recommended Limits

### Format
```yaml
services:
  myservice:
    deploy:
      resources:
        limits:
          cpus: '2.0'      # Max 2 CPU cores
          memory: 2G       # Max 2GB RAM
        reservations:
          cpus: '0.5'      # Guaranteed 0.5 cores
          memory: 512M     # Guaranteed 512MB
```

### Service-Specific Recommendations

#### Media Stack

**Plex** (Performance-critical)
```yaml
limits:
  cpus: '4.0'
  memory: 8G
reservations:
  cpus: '2.0'
  memory: 2G
```

**Sonarr, Radarr, Lidarr, Readarr** (Medium)
```yaml
limits:
  cpus: '2.0'
  memory: 2G
reservations:
  cpus: '0.25'
  memory: 256M
```

**Prowlarr** (Light)
```yaml
limits:
  cpus: '1.0'
  memory: 1G
reservations:
  cpus: '0.25'
  memory: 256M
```

**Overseerr** (Light)
```yaml
limits:
  cpus: '1.0'
  memory: 1G
reservations:
  cpus: '0.25'
  memory: 256M
```

**Tautulli** (Light)
```yaml
limits:
  cpus: '1.0'
  memory: 512M
reservations:
  cpus: '0.1'
  memory: 128M
```

**qBittorrent** (Heavy during downloads)
```yaml
limits:
  cpus: '4.0'
  memory: 4G
reservations:
  cpus: '0.5'
  memory: 512M
```

#### Game Servers

**Project Zomboid** (Heavy)
```yaml
limits:
  cpus: '4.0'
  memory: 6G
reservations:
  cpus: '1.0'
  memory: 2G
```

**V Rising** (Heavy)
```yaml
limits:
  cpus: '4.0'
  memory: 8G
reservations:
  cpus: '2.0'
  memory: 4G
```

**Minecraft/Crafty** (Heavy)
```yaml
limits:
  cpus: '4.0'
  memory: 8G
reservations:
  cpus: '2.0'
  memory: 4G
```

#### Monitoring

**Netdata** (Always-on, low impact)
```yaml
limits:
  cpus: '2.0'
  memory: 1G
reservations:
  cpus: '0.5'
  memory: 256M
```

**Grafana** (Light)
```yaml
limits:
  cpus: '1.0'
  memory: 1G
reservations:
  cpus: '0.25'
  memory: 256M
```

#### Services

**Portainer** (Light)
```yaml
limits:
  cpus: '1.0'
  memory: 512M
reservations:
  cpus: '0.1'
  memory: 128M
```

**PhotoPrism** (Heavy during indexing)
```yaml
limits:
  cpus: '4.0'
  memory: 4G
reservations:
  cpus: '1.0'
  memory: 1G
```

**Homebridge** (Light)
```yaml
limits:
  cpus: '1.0'
  memory: 512M
reservations:
  cpus: '0.1'
  memory: 128M
```

**Actual Budget** (Light)
```yaml
limits:
  cpus: '0.5'
  memory: 512M
reservations:
  cpus: '0.1'
  memory: 128M
```

## Total Resource Allocation

Assuming you have adequate CPU cores (8+) and 32GB+ RAM:

- **Reserved (guaranteed):** ~14GB RAM, ~8 CPU cores
- **Limit (max burst):** Can use full system resources with limits

## Implementation

### For New Services
Add to docker-compose.yml:
```yaml
version: "3.8"
services:
  myservice:
    image: myimage
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
```

### For Existing Services
Update existing docker-compose files and restart:
```bash
cd /path/to/service
# Edit docker-compose.yml
docker-compose up -d
```

## Monitoring Resource Usage

```bash
# See current usage
docker stats

# See specific container
docker stats <container-name>

# Check if hitting limits
docker stats --no-stream | sort -k 3 -h
```

## Tuning Tips

1. **Start conservative:** Set lower limits, increase if needed
2. **Monitor:** Use Netdata/Grafana to track actual usage
3. **Priority services:** Give more resources to critical services (Plex, game servers)
4. **Adjust based on load:** Increase limits during peak usage times

## Notes

- Limits prevent resource starvation
- Reservations ensure minimum guaranteed resources
- Game servers need higher limits during active gameplay
- Media indexing/scanning needs burst capacity
- Monitor /var/log messages for OOM kills

## Applied To

- ✅ Project Zomboid (homelab/gaming/zomboid/)
- ✅ V Rising (homelab/gaming/vrising/)
- ✅ Actual Budget (homelab/services/actual/)
- ⏳ Others: Update existing services gradually
