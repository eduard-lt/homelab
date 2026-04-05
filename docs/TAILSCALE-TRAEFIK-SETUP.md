# Tailscale + Traefik Setup Guide

**Created:** 2026-04-05  
**Strategy:** Private homelab access via Tailscale, Plex public exception

---

## 🎯 **Your Current Setup**

### Tailscale Network (Already Running! ✅)
```
Tailscale IP: 100.70.106.23
Hostname:     thedarkurge
Domain:       thedarkurge.tail-scale.ts.net

Connected Devices:
├─ thedarkurge (this server)     - 100.70.106.23
├─ eduard-pc (Windows)            - 100.97.245.23
├─ iphone182 (iOS)                - 100.75.89.55
└─ raspberrypi (Linux)            - 100.123.77.29
```

### Current Domain Config
```bash
# /home/eduard/homelab/services/traefik/.env
DOMAIN=homelab.local
```

**Status:** Local domain only (not real SSL)

---

## 🏗️ **Recommended Architecture**

```
                    INTERNET
                       │
                       │
              ┌────────┼────────┐
              │                 │
         TAILSCALE         PLEX (Public)
         (Private)         Port 32400
              │
              │
      ┌───────▼────────┐
      │   TRAEFIK      │
      │  Port 80/443   │
      │  (Tailscale    │
      │   IP only)     │
      └───────┬────────┘
              │
      ┌───────┴────────────────────┐
      │                            │
  SERVICES                    MONITORING
  (Private)                   (Private)
  ├─ Sonarr                   ├─ Grafana
  ├─ Radarr                   ├─ Netdata
  ├─ Actual                   └─ Traefik Dashboard
  └─ qBittorrent
```

**Access Pattern:**
- ✅ **From Tailscale devices:** `https://sonarr.thedarkurge.ts.net`
- ✅ **From anywhere:** `http://your-public-ip:32400/web` (Plex only)
- ❌ **From internet:** All other services blocked

---

## 🎯 **Strategy: Tailscale MagicDNS + Let's Encrypt**

Tailscale provides **automatic HTTPS** with real certificates! Here's how:

### Option 1: MagicDNS with Tailscale Certs (Recommended)

**How it works:**
1. Tailscale provides domain: `thedarkurge.tail-scale.ts.net`
2. Tailscale can issue real SSL certificates
3. Services only accessible via Tailscale network
4. No port forwarding needed (except Plex)

**Benefits:**
- ✅ Real SSL certificates (no browser warnings)
- ✅ Automatic renewal
- ✅ Zero exposure to public internet
- ✅ Works from any Tailscale device
- ✅ Completely free

**URLs you'll get:**
```
https://traefik.thedarkurge.ts.net
https://sonarr.thedarkurge.ts.net
https://radarr.thedarkurge.ts.net
https://budget.thedarkurge.ts.net
https://grafana.thedarkurge.ts.net
```

---

## 🔧 **Implementation Steps**

### Step 1: Enable Tailscale MagicDNS (5 minutes)

```bash
# Check if MagicDNS is enabled
tailscale status

# If you see domains like "thedarkurge.tail-scale.ts.net", MagicDNS is enabled!
# If not, enable in Tailscale admin console:
# https://login.tailscale.com/admin/dns
```

**In Tailscale Admin Console:**
1. Go to **DNS** settings
2. Enable **MagicDNS**
3. Enable **HTTPS Certificates**

### Step 2: Get Tailscale Certificate (2 minutes)

```bash
# Get SSL certificate for your Tailscale domain
cd ~/homelab/services/traefik

# Request certificate (requires sudo first time)
sudo tailscale cert thedarkurge.tail-scale.ts.net

# This creates:
# - thedarkurge.tail-scale.ts.net.crt (certificate)
# - thedarkurge.tail-scale.ts.net.key (private key)

# Move to Traefik directory
sudo mv thedarkurge.tail-scale.ts.net.* .
sudo chown eduard:eduard thedarkurge.tail-scale.ts.net.*
```

### Step 3: Update Traefik Configuration (10 minutes)

**Edit `.env` file:**
```bash
cd ~/homelab/services/traefik
nano .env
```

**Change from:**
```env
DOMAIN=homelab.local
```

**Change to:**
```env
DOMAIN=thedarkurge.ts.net
TAILSCALE_CERT=/thedarkurge.tail-scale.ts.net.crt
TAILSCALE_KEY=/thedarkurge.tail-scale.ts.net.key
```

### Step 4: Update Traefik docker-compose.yml

**Edit docker-compose.yml:**
```bash
nano docker-compose.yml
```

**Add Tailscale certificate volumes:**
```yaml
version: "3.8"

services:
  traefik:
    container_name: traefik
    image: traefik:v3.0
    restart: unless-stopped
    env_file:
      - .env
    ports:
      # Bind to Tailscale IP only (not public)
      - "100.70.106.23:80:80"     # HTTP (Tailscale only)
      - "100.70.106.23:443:443"   # HTTPS (Tailscale only)
      - "100.70.106.23:8080:8080" # Dashboard (Tailscale only)
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml:ro
      - ./acme.json:/acme.json
      # Add Tailscale certificates
      - ./thedarkurge.tail-scale.ts.net.crt:/certs/tailscale.crt:ro
      - ./thedarkurge.tail-scale.ts.net.key:/certs/tailscale.key:ro
    networks:
      - services_net
      - media_net
      - gaming_net
      - monitoring_net
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik.${DOMAIN}`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.middlewares=auth"
      - "traefik.http.middlewares.auth.basicauth.users=${DASHBOARD_USER}"
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M

networks:
  services_net:
    external: true
  media_net:
    external: true
  gaming_net:
    external: true
  monitoring_net:
    external: true
```

### Step 5: Update traefik.yml (Tailscale Certificates)

**Edit traefik.yml:**
```bash
nano traefik.yml
```

**Update to use Tailscale certificates:**
```yaml
# Traefik Static Configuration
global:
  checkNewVersion: true
  sendAnonymousUsage: false

# Entrypoints
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https

  websecure:
    address: ":443"
    http:
      tls:
        # Use Tailscale certificate
        certificates:
          - certFile: /certs/tailscale.crt
            keyFile: /certs/tailscale.key

# Dashboard
api:
  dashboard: true
  insecure: true  # Access via Tailscale only

# Docker Provider
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: services_net

# Logging
log:
  level: INFO

accessLog:
  filePath: "/var/log/traefik/access.log"
```

### Step 6: Deploy Traefik

```bash
cd ~/homelab/services/traefik

# Create log directory
mkdir -p logs

# Deploy
docker-compose up -d

# Check logs
docker logs traefik -f
```

**Test access from Tailscale device:**
```bash
# From any device on Tailscale network
curl https://traefik.thedarkurge.ts.net
```

---

## 🎬 **Plex Exception (Public Access)**

Plex needs to remain publicly accessible for:
- Remote streaming (outside Tailscale)
- Mobile apps
- Smart TVs

### Current Plex Setup

**Check Plex network mode:**
```bash
docker inspect plex | grep -A 10 "NetworkMode"
```

**Plex is using `network_mode: host`** - it has direct access to all ports.

### Recommended Plex Configuration

**Option A: Keep Host Network (Easiest)**

Plex already exposed on all interfaces:
- ✅ Public access works: `http://public-ip:32400/web`
- ✅ Tailscale access works: `http://100.70.106.23:32400/web`
- ✅ No changes needed!

**Option B: Bind Specific Ports (More Secure)**

If you want to migrate Plex to docker-compose in homelab:

```yaml
# /home/eduard/homelab/media/plex/docker-compose.yml
version: "3.8"

services:
  plex:
    container_name: plex
    image: lscr.io/linuxserver/plex:latest
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - VERSION=docker
    volumes:
      - /mnt/Data/Plex:/config
      - /mnt/Data/Media:/media
    ports:
      # Bind to ALL interfaces (public + Tailscale)
      - "32400:32400"   # Plex Web UI
      - "1900:1900/udp" # DLNA
      - "5353:5353/udp" # Bonjour/Avahi
      - "8324:8324"     # Roku
      - "32410:32410/udp" # GDM Network Discovery
      - "32412:32412/udp" # GDM Network Discovery
      - "32413:32413/udp" # GDM Network Discovery
      - "32414:32414/udp" # GDM Network Discovery
      - "32469:32469"   # Plex DLNA
    networks:
      - media_net
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 4G

networks:
  media_net:
    external: true
```

**Key difference:** Plex binds to `0.0.0.0` (all interfaces), Traefik binds to Tailscale IP only.

---

## 🔐 **Security Configuration**

### Firewall Rules (ufw)

```bash
# Allow Plex from anywhere
sudo ufw allow 32400/tcp comment "Plex"

# Allow Tailscale
sudo ufw allow in on tailscale0

# Block direct access to Traefik from public
sudo ufw deny 80/tcp
sudo ufw deny 443/tcp
sudo ufw deny 8080/tcp

# Check rules
sudo ufw status numbered
```

### Network Isolation Summary

```
Port 32400 (Plex)        → 0.0.0.0 (public + Tailscale)
Port 80/443 (Traefik)    → 100.70.106.23 (Tailscale only)
Port 8989 (Sonarr)       → No port binding (Traefik routes)
Port 7878 (Radarr)       → No port binding (Traefik routes)
All other services       → No public exposure
```

---

## 📋 **Service Migration with Tailscale URLs**

### Example: Sonarr Migration

**Create `/home/eduard/homelab/media/sonarr/docker-compose.yml`:**

```yaml
version: "3.8"

services:
  sonarr:
    container_name: sonarr
    image: linuxserver/sonarr:latest
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    volumes:
      - /mnt/Data/Sonarr:/config
      - /mnt/Data/Media/TV:/tv
      - /mnt/Data/Downloads:/downloads
    # NO PORT BINDING! Traefik handles it
    networks:
      - media_net
    labels:
      # Enable Traefik
      - "traefik.enable=true"
      
      # Router configuration
      - "traefik.http.routers.sonarr.rule=Host(`sonarr.${DOMAIN}`)"
      - "traefik.http.routers.sonarr.entrypoints=websecure"
      
      # Service configuration (tell Traefik which port)
      - "traefik.http.services.sonarr.loadbalancer.server.port=8989"
      
      # Security headers
      - "traefik.http.routers.sonarr.middlewares=secure-headers"
      - "traefik.http.middlewares.secure-headers.headers.stsSeconds=31536000"
      - "traefik.http.middlewares.secure-headers.headers.contentTypeNosniff=true"
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G

networks:
  media_net:
    external: true
```

**Access URL:** `https://sonarr.thedarkurge.ts.net`

---

## 🎨 **Custom Subdomain Naming**

You can use friendlier names:

```yaml
# Instead of: sonarr.thedarkurge.ts.net
# Use:        tv.thedarkurge.ts.net

labels:
  - "traefik.http.routers.sonarr.rule=Host(`tv.${DOMAIN}`)"
```

**Suggested Mappings:**
```
Service      → Standard URL                  → Friendly URL
─────────────────────────────────────────────────────────────
Sonarr       → sonarr.thedarkurge.ts.net    → tv.thedarkurge.ts.net
Radarr       → radarr.thedarkurge.ts.net    → movies.thedarkurge.ts.net
Overseerr    → overseerr.thedarkurge.ts.net → requests.thedarkurge.ts.net
qBittorrent  → qbit.thedarkurge.ts.net      → downloads.thedarkurge.ts.net
Actual       → actual.thedarkurge.ts.net    → budget.thedarkurge.ts.net
Grafana      → grafana.thedarkurge.ts.net   → dash.thedarkurge.ts.net
Netdata      → netdata.thedarkurge.ts.net   → monitor.thedarkurge.ts.net
Tautulli     → tautulli.thedarkurge.ts.net  → stats.thedarkurge.ts.net
```

---

## 🧪 **Testing Checklist**

### From Tailscale Device (Phone/Laptop)

- [ ] **Test Traefik Dashboard:** `https://traefik.thedarkurge.ts.net`
- [ ] **Test first service:** `https://sonarr.thedarkurge.ts.net`
- [ ] **Check SSL certificate:** Should show valid (no warnings)
- [ ] **Test from iPhone:** Should work on cellular + WiFi

### From Public Internet (Non-Tailscale)

- [ ] **Test Plex access:** `http://your-public-ip:32400/web` ✅ Should work
- [ ] **Test Sonarr:** `http://your-public-ip:8989` ❌ Should NOT work
- [ ] **Test Traefik:** `https://traefik.thedarkurge.ts.net` ❌ Should NOT work

### Expected Results

```
Service         │ Tailscale Device │ Public Internet
────────────────┼──────────────────┼─────────────────
Plex            │ ✅ Works         │ ✅ Works
Sonarr          │ ✅ Works         │ ❌ Blocked
Radarr          │ ✅ Works         │ ❌ Blocked
Traefik Dash    │ ✅ Works         │ ❌ Blocked
All others      │ ✅ Works         │ ❌ Blocked
```

---

## 🚀 **Quick Start Commands**

### 1. Enable Tailscale HTTPS

```bash
# In Tailscale admin: https://login.tailscale.com/admin/dns
# Enable: MagicDNS + HTTPS Certificates
```

### 2. Get Certificates

```bash
cd ~/homelab/services/traefik
sudo tailscale cert thedarkurge.tail-scale.ts.net
sudo chown eduard:eduard thedarkurge.tail-scale.ts.net.*
```

### 3. Update Configuration

```bash
# Update .env
cat > .env << 'EOF'
DOMAIN=thedarkurge.ts.net
DASHBOARD_USER=admin:$apr1$8oJF3QAT$zL36vWL6x5/QBvMpFYFWk1
EOF

# Backup old config
cp traefik.yml traefik.yml.backup
```

### 4. Deploy Traefik

```bash
cd ~/homelab/services/traefik
docker-compose up -d
docker logs traefik -f
```

### 5. Test Access

```bash
# From this server
curl -k https://traefik.thedarkurge.ts.net

# From phone browser (connected to Tailscale)
# Navigate to: https://traefik.thedarkurge.ts.net
```

---

## 📊 **Comparison: Domain Options**

| Feature | Tailscale Domain | Purchased Domain | Local DNS |
|---------|------------------|------------------|-----------|
| **Cost** | Free | $10/year | Free |
| **SSL Certificates** | Real (Tailscale) | Real (Let's Encrypt) | Self-signed |
| **Public Access** | ❌ No (Tailscale only) | ✅ Yes | ❌ No |
| **Setup Time** | 15 min | 30 min | 10 min |
| **Remote Access** | ✅ Yes (via Tailscale) | ✅ Yes (anywhere) | ❌ No |
| **Security** | ✅ Excellent | 🟨 Good (if configured) | ✅ Excellent |
| **Maintenance** | ✅ Zero | 🟨 Annual renewal | ✅ Zero |

**Recommendation for You:** **Tailscale domain** (thedarkurge.ts.net)

**Why:**
- ✅ You already have Tailscale running
- ✅ Zero cost
- ✅ Real SSL certificates (no browser warnings)
- ✅ Maximum security (not exposed to internet)
- ✅ Works from all your devices (iPhone, iPad, PC)
- ✅ Plex can still be public for streaming

---

## 🔧 **Troubleshooting**

### Issue: "Can't reach traefik.thedarkurge.ts.net"

**Cause:** MagicDNS not enabled or device not on Tailscale

**Solution:**
```bash
# On device trying to access:
tailscale status

# Should show connected
# If not: tailscale up
```

### Issue: "SSL Certificate Error"

**Cause:** Tailscale certificate not properly mounted

**Solution:**
```bash
# Verify cert files exist
ls -la ~/homelab/services/traefik/thedarkurge.tail-scale.ts.net.*

# Check container can access them
docker exec traefik ls -la /certs/
```

### Issue: "404 Not Found from Traefik"

**Cause:** Service not on same network as Traefik

**Solution:**
```bash
# Verify service is on correct network
docker inspect sonarr | grep -A 5 Networks

# Should show "media_net"
```

### Issue: "Plex not accessible from internet"

**Cause:** Firewall blocking port 32400

**Solution:**
```bash
# Allow Plex through firewall
sudo ufw allow 32400/tcp

# Check if port is listening
sudo netstat -tlnp | grep 32400
```

---

## 📚 **Next Steps**

1. ✅ **Enable Tailscale MagicDNS + HTTPS** (admin console)
2. ✅ **Get Tailscale certificates**
3. ✅ **Update Traefik configuration**
4. ✅ **Deploy Traefik**
5. ✅ **Test from Tailscale device**
6. ✅ **Migrate first service** (Actual Budget recommended)
7. ✅ **Migrate media stack** (Sonarr, Radarr, etc.)
8. ✅ **Update bookmarks** with new URLs

---

## 🎯 **Final Architecture**

```
Your iPhone (Tailscale)
    │
    ├─→ https://tv.thedarkurge.ts.net (Sonarr)
    ├─→ https://movies.thedarkurge.ts.net (Radarr)
    ├─→ https://budget.thedarkurge.ts.net (Actual)
    └─→ http://your-public-ip:32400/web (Plex)

Internet (No Tailscale)
    │
    ├─→ https://tv.thedarkurge.ts.net ❌ BLOCKED
    ├─→ https://budget.thedarkurge.ts.net ❌ BLOCKED
    └─→ http://your-public-ip:32400/web ✅ WORKS (Plex only)
```

**Benefits:**
- 🔒 99% of your homelab is private (Tailscale only)
- 📺 Plex still works for family/friends (public)
- 🔐 Real SSL certificates (no warnings)
- 🚀 Professional URLs
- 🛡️ Zero attack surface (except Plex)

---

**Want me to help implement this? I can update all the config files now!** 🚀
