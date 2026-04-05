# Homelab Service Inventory

**Last Updated:** 2026-04-05  
**Total Services:** 15 running containers + 2 configured (not running)

---

## 🎬 Media Stack

### Plex Media Server
- **Image:** `lscr.io/linuxserver/plex:1.41.3`
- **Purpose:** Stream movies, TV shows, music, and photos
- **Port:** Network mode (all ports)
- **Data Location:** `/mnt/Data/Plex/`
- **Config:** Unknown compose location (deployed outside tracked files)
- **Status:** ✅ Running (14 months old container)
- **Access:** http://your-server-ip:32400/web
- **Auth:** Plex account required

### Sonarr (TV Shows)
- **Image:** `linuxserver/sonarr:3.0.10`
- **Purpose:** TV show management and automation
- **Port:** 8989
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (23 months old, restarted 8h ago)
- **Access:** http://your-server-ip:8989
- **Auth:** Default admin/admin (should be changed)

### Radarr (Movies)
- **Image:** `linuxserver/radarr:5.7.0`
- **Purpose:** Movie management and automation
- **Port:** 7878
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (20 months old)
- **Access:** http://your-server-ip:7878
- **Auth:** Default admin/admin (should be changed)

### Lidarr (Music)
- **Image:** `linuxserver/lidarr:1.4.5`
- **Purpose:** Music management and automation
- **Port:** 8686
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (23 months old)
- **Access:** http://your-server-ip:8686
- **Auth:** Default admin/admin (should be changed)

### Readarr (Books)
- **Image:** `linuxserver/readarr:0.3.10-develop`
- **Purpose:** Book/audiobook management
- **Port:** 8787
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (23 months old)
- **Access:** http://your-server-ip:8787
- **Auth:** Default admin/admin (should be changed)

### Prowlarr (Indexer Manager)
- **Image:** `linuxserver/prowlarr:1.9.4`
- **Purpose:** Unified indexer management for *arr apps
- **Port:** 9696
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (restarted 8h ago)
- **Access:** http://your-server-ip:9696
- **Auth:** Default admin/admin (should be changed)

### Overseerr (Request Management)
- **Image:** `linuxserver/overseerr:1.33.2`
- **Purpose:** Media request and discovery platform
- **Port:** 5055
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (restarted 8h ago)
- **Access:** http://your-server-ip:5055
- **Auth:** Configured during first setup

### Tautulli (Plex Analytics)
- **Image:** `linuxserver/tautulli:2.13.2`
- **Purpose:** Plex monitoring and statistics
- **Port:** 7979 → 8181
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (23 months old)
- **Access:** http://your-server-ip:7979
- **Auth:** Configured during first setup

### qBittorrent (Download Client)
- **Image:** `hotio/qbittorrent:release-5.0.1`
- **Purpose:** Torrent download client
- **Port:** 8181 → 8080
- **Data Location:** TBD (downloads to /mnt/Data/Downloads)
- **Config:** Unknown compose location
- **Status:** ✅ Running (16 months old)
- **Resource Limit:** 16GB RAM
- **Access:** http://your-server-ip:8181
- **Auth:** Username/password required

---

## 🎮 Game Servers

### Crafty Controller (Minecraft)
- **Image:** `registry.gitlab.com/crafty-controller/crafty-4:4.4.4`
- **Purpose:** Minecraft server management and control panel
- **Ports:** 
  - 8112 → 8123 (HTTP)
  - 8111 → 8443 (HTTPS)
  - 19132 (UDP - Bedrock)
  - 25500-25600 (TCP - Java servers)
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (12 months old)
- **Restart Policy:** always
- **Access:** http://your-server-ip:8112
- **Auth:** Admin credentials required

### Project Zomboid Server
- **Image:** `pepecitron/projectzomboid-server`
- **Purpose:** Multiplayer survival game server
- **Ports:** 
  - 16261 (UDP)
  - 16262 (UDP)
  - 27015 (TCP - RCON)
- **Data Location:** `/mnt/Data/Zomboid/`
- **Config:** 
  - ⚠️ OLD: `/home/eduard/docker_stuff/zomboid/docker-compose.yml`
  - ✅ NEW: `/home/eduard/homelab/gaming/zomboid/docker-compose.yml`
- **Status:** ⚠️ Migrated but not redeployed
- **Server Name:** "ultimiiRatati"
- **Auth:** Server password in .env file

### V Rising Server
- **Image:** `trueosiris/vrising`
- **Purpose:** Vampire survival game server
- **Ports:**
  - 9876 (UDP)
  - 9877 (UDP)
- **Data Location:** `/DATA/Vrising_crack/` ⚠️ Inconsistent path
- **Config:** `/home/eduard/docker-compose.yml`
- **Status:** ⚠️ Not running (vrising container not found)
- **Server Name:** "vrising-TheDarkCrack"
- **Restart Policy:** unless-stopped

---

## 📊 Monitoring

### Netdata
- **Image:** `netdata/netdata:stable`
- **Purpose:** Real-time system performance monitoring
- **Port:** 19999
- **Data Location:** Container volumes
- **Config:** Unknown compose location
- **Status:** ✅ Running, healthy (23 months old)
- **Resource Limit:** 1.8GB RAM
- **Access:** http://your-server-ip:19999
- **Auth:** None (should be behind reverse proxy)

### Grafana
- **Image:** `grafana/grafana:11.1.5`
- **Purpose:** Metrics visualization and dashboards
- **Port:** 3003 → 3000
- **Data Location:** TBD
- **Config:** Unknown compose location
- **Status:** ✅ Running (14 months old)
- **Restart Policy:** always
- **Access:** http://your-server-ip:3003
- **Auth:** Admin credentials required

---

## 🛠️ Services

### Portainer
- **Image:** `portainer/portainer-ce:2.19.4`
- **Purpose:** Docker container management UI
- **Ports:**
  - 8000 (TCP)
  - 9000 (HTTP)
  - 9443 (HTTPS)
- **Data Location:** Docker volume
- **Config:** Unknown compose location
- **Status:** ✅ Running (23 months old)
- **Access:** http://your-server-ip:9000
- **Auth:** Admin account required

### PhotoPrism
- **Image:** `photoprism/photoprism:231011`
- **Purpose:** AI-powered photo management
- **Ports:**
  - 2342 (HTTP)
  - 2442-2443 (HTTPS)
- **Data Location:** TBD (photos likely in /mnt/Data/Photos)
- **Config:** Unknown compose location
- **Status:** ✅ Running (13 months old)
- **Access:** http://your-server-ip:2342
- **Auth:** Username/password required

### Homebridge
- **Image:** `homebridge/homebridge:latest`
- **Purpose:** HomeKit integration for smart home devices
- **Ports:** Network mode
- **Data Location:** Container volume
- **Config:** Unknown compose location (likely homebridge_default network)
- **Status:** ✅ Running (23 months old)
- **Restart Policy:** always
- **Access:** Via Homebridge UI or HomeKit app
- **Auth:** PIN code for HomeKit

### Actual Budget
- **Image:** `actualbudget/actual-server:latest`
- **Purpose:** Personal finance and budgeting
- **Port:** 5006
- **Data Location:** `/home/eduard/actual/actual-data/`
- **Config:** `/home/eduard/actual/docker-compose.yml`
- **Status:** ⚠️ Not running (actual_server container not found)
- **Access:** http://your-server-ip:5006
- **Auth:** Configured during first use

### Vaultwarden
- **Image:** Unknown
- **Purpose:** Bitwarden-compatible password manager
- **Port:** Unknown
- **Data Location:** `/home/eduard/vaultwarden/` (empty directory)
- **Config:** Not found
- **Status:** ⚠️ Not configured or running
- **Note:** Directory exists but appears unused

---

## 🔴 Disabled/Stopped Services

### Tunnel (SideJITServer)
- **Image:** `sidejitserver-142-tunnel:latest`
- **Purpose:** iOS sideloading server
- **Status:** 🛑 Stopped (missing Python dependency)
- **Issue:** `ModuleNotFoundError: no module named 'ipsw_parser.img4'`
- **Action:** Disabled restart policy on 2026-04-05
- **Notes:** See `/home/eduard/homelab/docs/tunnel-container-notes.md`

---

## 📦 Storage Summary

### Primary Storage
- **Path:** `/mnt/Data`
- **Size:** 7.3TB (5.9TB used, 1.3TB available)
- **Usage:** 83%
- **Contents:**
  - Apps/
  - Backup/
  - Books/
  - Downloads/ (25 items)
  - Files/
  - Github/
  - Minecraft/
  - Music/
  - Photos/
  - Plex/
  - Zomboid/

### Fast Storage
- **Path:** `/mnt/FastStorage`
- **Size:** 458GB (54GB used, 399GB available)
- **Usage:** 12%
- **Contents:** TBD (underutilized)

### ⚠️ Path Inconsistencies
- V Rising uses `/DATA/` instead of `/mnt/Data/`
- Need to verify if `/DATA` is a symlink or different mount

---

## 🔧 Required Actions

### High Priority
1. ✅ Find compose files for running containers (most are unknown)
2. ⚠️ Change default *arr passwords (security risk)
3. ⚠️ Investigate /DATA vs /mnt/Data inconsistency
4. ⚠️ Deploy Actual Budget (configured but not running)
5. ⚠️ Start or remove V Rising server

### Medium Priority
6. Configure Vaultwarden (or remove if unused)
7. Document all data volume locations
8. Set up reverse proxy with authentication
9. Move performance-sensitive services to NVMe storage
10. Implement backup strategy

### Low Priority
11. Update container images
12. Add resource limits where missing
13. Consolidate all services to homelab repo
14. Create unified monitoring dashboard

---

## 🌐 Network Configuration

### Docker Networks
- `bridge` (default) - Most services
- `crafty_default`
- `overseerr_default`
- `zomboid_default`
- `homebridge_default` (implied)

### Recommended Structure
- `media_net` - Media stack (*arr, Plex, qBittorrent)
- `gaming_net` - Game servers
- `monitoring_net` - Netdata, Grafana
- `services_net` - Portainer, PhotoPrism, etc.

---

## 📝 Notes

- Most containers are 12-23 months old (need updates)
- Many services lack resource limits (risk of resource starvation)
- No centralized authentication (each service has own auth)
- Compose file locations mostly unknown (deployed manually?)
- Several services configured but not running
- Storage is 83% full on main drive
- NVMe storage is only 12% utilized (optimization opportunity)

**Migration Status:**
- ✅ Project Zomboid: Migrated to homelab repo (not deployed)
- ⏳ All other services: Need migration
