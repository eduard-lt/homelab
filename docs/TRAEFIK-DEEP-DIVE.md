# Traefik Reverse Proxy - Deep Dive Guide

**Created:** 2026-04-05  
**Purpose:** Understand how Traefik transforms service access in your homelab

---

## 📊 **Current State (Without Traefik)**

### How You Access Services TODAY:

```
Your Device → http://172.26.1.31:PORT → Specific Container
```

**Example Access Patterns:**
```
Sonarr:    http://172.26.1.31:8989
Radarr:    http://172.26.1.31:7878
Prowlarr:  http://172.26.1.31:9696
Lidarr:    http://172.26.1.31:8686
Readarr:   http://172.26.1.31:8787
Overseerr: http://172.26.1.31:5055
Tautulli:  http://172.26.1.31:7979
qBittorrent: http://172.26.1.31:8181
Plex:      http://172.26.1.31:32400/web
Grafana:   http://172.26.1.31:3003
Netdata:   http://172.26.1.31:19999
Actual:    http://172.26.1.31:5006
```

### Problems with This Approach:

1. **🧠 Memory Burden**
   - Must remember 12+ different port numbers
   - Easy to forget which service is on which port
   - Port conflicts are possible

2. **🔒 Security Issues**
   - Every port exposed directly to network
   - No centralized authentication
   - No SSL encryption (HTTP only)
   - Anyone on network can access if they know the port

3. **📱 Mobile/Remote Access Harder**
   - Can't use friendly URLs
   - Must VPN in and remember IPs/ports
   - No HTTPS = no modern browser features

4. **🔧 Management Overhead**
   - Each service manages its own auth
   - 15 different username/password combinations
   - No audit trail of who accessed what

5. **🌐 DNS Doesn't Work**
   - Can't use browser bookmarks with names
   - Can't share clean URLs with family
   - Port numbers in every bookmark

---

## 🚀 **Future State (With Traefik)**

### How You'll Access Services AFTER:

```
Your Device → https://service.yourdomain.com → Traefik → Correct Container
                     ↑
                 Port 443 (HTTPS)
```

**Example Access Patterns:**
```
Sonarr:      https://sonarr.yourdomain.com
Radarr:      https://radarr.yourdomain.com
Prowlarr:    https://prowlarr.yourdomain.com
Lidarr:      https://lidarr.yourdomain.com
Readarr:     https://readarr.yourdomain.com
Overseerr:   https://requests.yourdomain.com  (custom name!)
Tautulli:    https://stats.yourdomain.com     (custom name!)
qBittorrent: https://torrents.yourdomain.com  (custom name!)
Plex:        https://plex.yourdomain.com
Grafana:     https://grafana.yourdomain.com
Netdata:     https://monitor.yourdomain.com   (custom name!)
Actual:      https://budget.yourdomain.com    (custom name!)
Traefik:     https://traefik.yourdomain.com   (dashboard)
```

### Benefits of This Approach:

1. **🧠 Human-Friendly URLs**
   - Easy to remember: "radarr.yourdomain.com"
   - Semantic names: "budget", "stats", "requests"
   - Browser autocomplete works

2. **🔒 Security Improvements**
   - SSL/TLS encryption (HTTPS) on everything
   - Only ports 80 & 443 exposed (not 15 ports)
   - Can add centralized authentication
   - Automatic certificate renewal
   - Modern security headers

3. **📱 Remote Access Made Easy**
   - Works from anywhere (with proper DNS)
   - Clean URLs you can share
   - Mobile apps work better with HTTPS

4. **🔧 Simplified Management**
   - One place to configure access (Traefik)
   - Automatic service discovery
   - Centralized logging
   - Easy to add/remove services

5. **🌐 Professional Setup**
   - Works like real websites
   - No more port numbers
   - SSL certificates prove authenticity
   - Family members find it intuitive

---

## 🏗️ **How Traefik Works**

### The Magic: Auto-Discovery

Traefik watches Docker and automatically configures itself! Here's how:

#### Step 1: Traefik Listens
```
Traefik monitors Docker socket → Sees all containers → Reads their labels
```

#### Step 2: Service Labels Tell Traefik What to Do
```yaml
# Example: Sonarr container
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.sonarr.rule=Host(`sonarr.yourdomain.com`)"
  - "traefik.http.routers.sonarr.entrypoints=websecure"
  - "traefik.http.routers.sonarr.tls.certresolver=letsencrypt"
  - "traefik.http.services.sonarr.loadbalancer.server.port=8989"
```

**Translation:**
- ✅ Enable Traefik for this container
- 📍 Route requests for `sonarr.yourdomain.com` to this container
- 🔒 Use HTTPS (port 443)
- 🔐 Get SSL certificate from Let's Encrypt
- 🎯 Forward to container port 8989

#### Step 3: Automatic Routing
```
Request comes in → Traefik checks Host header → Routes to correct container
```

#### Step 4: SSL Certificates
```
Let's Encrypt → Traefik requests cert → Stores in acme.json → Auto-renews every 60 days
```

### Architecture Diagram

```
                              TRAEFIK CONTAINER
                              ┌─────────────────────────────────┐
Internet/LAN                  │  Port 80 (HTTP)                 │
      │                       │  Port 443 (HTTPS)               │
      ├──→ sonarr.domain.com ─┼─→ Router: Check Host header    │
      │                       │     ↓                           │
      ├──→ radarr.domain.com ─┼─→ SSL Termination              │
      │                       │     ↓                           │
      └──→ plex.domain.com   ─┼─→ Middleware (auth, headers)   │
                              │     ↓                           │
                              │  Forward to Backend Container   │
                              └──────────┬──────────────────────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
                    ▼                    ▼                    ▼
          ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
          │ SONARR          │  │ RADARR          │  │ PLEX            │
          │ Port: 8989      │  │ Port: 7878      │  │ Port: 32400     │
          │ Network:        │  │ Network:        │  │ Network:        │
          │   media_net     │  │   media_net     │  │   media_net     │
          └─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## 🔄 **Migration Path - Before & After**

### Service-by-Service Transformation

#### **Sonarr Example**

**BEFORE (Current docker-compose.yml somewhere):**
```yaml
version: "3"
services:
  sonarr:
    image: linuxserver/sonarr:3.0.10
    ports:
      - "8989:8989"
    # No Traefik labels
```

**Access:** `http://172.26.1.31:8989`

**AFTER (In /home/eduard/homelab/media/sonarr/):**
```yaml
version: "3.8"
services:
  sonarr:
    container_name: sonarr
    image: linuxserver/sonarr:latest
    # NO PORTS EXPOSED!
    networks:
      - media_net
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sonarr.rule=Host(`sonarr.${DOMAIN}`)"
      - "traefik.http.routers.sonarr.entrypoints=websecure"
      - "traefik.http.routers.sonarr.tls.certresolver=letsencrypt"
      - "traefik.http.services.sonarr.loadbalancer.server.port=8989"
    # ... rest of config

networks:
  media_net:
    external: true
```

**Access:** `https://sonarr.yourdomain.com`

**Key Changes:**
- ❌ Remove `ports:` section (Traefik handles it)
- ✅ Add to `media_net` network (Traefik connects to all networks)
- ✅ Add Traefik labels for routing
- ✅ Automatic HTTPS with Let's Encrypt

---

#### **Actual Budget Example (Already Migrated)**

**BEFORE:**
```yaml
ports:
  - "5006:5006"
```
**Access:** `http://172.26.1.31:5006`

**AFTER (Add these labels):**
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.actual.rule=Host(`budget.${DOMAIN}`)"
  - "traefik.http.routers.actual.entrypoints=websecure"
  - "traefik.http.routers.actual.tls.certresolver=letsencrypt"
  - "traefik.http.services.actual.loadbalancer.server.port=5006"
```
**Access:** `https://budget.yourdomain.com`

---

#### **Netdata Example (Monitoring)**

**BEFORE:**
```yaml
ports:
  - "19999:19999"
```
**Access:** `http://172.26.1.31:19999` (⚠️ No authentication!)

**AFTER:**
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.netdata.rule=Host(`monitor.${DOMAIN}`)"
  - "traefik.http.routers.netdata.entrypoints=websecure"
  - "traefik.http.routers.netdata.tls.certresolver=letsencrypt"
  - "traefik.http.services.netdata.loadbalancer.server.port=19999"
  # ADD AUTHENTICATION!
  - "traefik.http.routers.netdata.middlewares=netdata-auth"
  - "traefik.http.middlewares.netdata-auth.basicauth.users=${NETDATA_USER}"
```
**Access:** `https://monitor.yourdomain.com` (✅ Requires password!)

---

## 🎯 **Domain Name Options**

You need to choose a domain strategy. Here are your options:

### **Option 1: Local DNS Only (.local or .home)**

**How it works:**
- Use local DNS names like `sonarr.homelab.local`
- Configure your router or Pi-hole for DNS resolution
- Only works on your home network

**Pros:**
- ✅ Free
- ✅ No internet dependency
- ✅ Fast (local only)
- ✅ Private (not on public internet)

**Cons:**
- ❌ No remote access
- ❌ Can't use Let's Encrypt (must use self-signed certs)
- ❌ Browser security warnings

**Best for:** Internal-only setups, maximum privacy

**Setup Steps:**
1. Configure local DNS (router/Pi-hole)
2. Point `*.homelab.local → 172.26.1.31`
3. Use Traefik with self-signed certificates

---

### **Option 2: Purchased Domain + Dynamic DNS**

**How it works:**
- Buy domain: `yourhomelab.com` ($10-15/year)
- Use Dynamic DNS to update IP when it changes
- Use Let's Encrypt for free SSL certificates

**Pros:**
- ✅ Real SSL certificates (no warnings)
- ✅ Can access remotely (if you allow)
- ✅ Professional looking
- ✅ Let's Encrypt auto-renewal

**Cons:**
- ❌ Annual cost ($10-15/year)
- ❌ Exposes you have these services (DNS is public)
- ❌ Need to manage DNS records

**Best for:** Remote access, professional setup

**Setup Steps:**
1. Buy domain from Namecheap/Cloudflare/etc
2. Configure Dynamic DNS (if home IP changes)
3. Point DNS: `*.yourhomelab.com → Your Public IP`
4. Configure router port forwarding (80, 443 → Traefik)
5. Let Traefik handle SSL automatically

**Recommended Providers:**
- Cloudflare (free DNS, $10/year domain)
- Namecheap (~$12/year)
- Porkbun (~$8/year)

---

### **Option 3: DuckDNS (Free Dynamic DNS)**

**How it works:**
- Free subdomain: `yourhomelab.duckdns.org`
- Automatic IP updates
- Use Let's Encrypt for SSL

**Pros:**
- ✅ Completely free
- ✅ Real SSL certificates
- ✅ Easy setup
- ✅ Good for testing/learning

**Cons:**
- ❌ Subdomain only (not custom domain)
- ❌ Public DNS (everyone sees you have services)
- ❌ Less professional looking

**Best for:** Budget-conscious, testing Traefik

**Setup Steps:**
1. Sign up at duckdns.org
2. Create subdomain: `yourhomelab.duckdns.org`
3. Install DuckDNS updater
4. Configure Traefik to use `yourhomelab.duckdns.org`

---

### **Option 4: Cloudflare Tunnel (Zero Trust)**

**How it works:**
- Free tunnel from Cloudflare to your homelab
- No ports opened on router
- Cloudflare handles SSL automatically

**Pros:**
- ✅ Free
- ✅ No port forwarding needed
- ✅ DDoS protection
- ✅ Cloudflare's SSL certificates
- ✅ Extra security layer

**Cons:**
- ❌ All traffic goes through Cloudflare
- ❌ Cloudflare ToS applies
- ❌ Slightly more complex setup
- ❌ Need Cloudflare account

**Best for:** Maximum security, no port forwarding allowed

**Setup Steps:**
1. Get free Cloudflare account
2. Add domain (or use Cloudflare subdomain)
3. Install `cloudflared` daemon
4. Configure tunnel to Traefik
5. Traefik handles internal routing

---

### **🏆 Recommendation Matrix**

| Use Case | Best Option | Why |
|----------|-------------|-----|
| **Internal only, maximum privacy** | Local DNS (.local) | No internet exposure |
| **Remote access on budget** | DuckDNS | Free, real SSL, easy setup |
| **Professional + remote** | Purchased Domain | Full control, custom branding |
| **Maximum security** | Cloudflare Tunnel | No open ports, DDoS protection |
| **Testing/Learning** | DuckDNS or Local DNS | Low commitment |

**My Recommendation for You:** Start with **Local DNS** to test Traefik, then upgrade to **Purchased Domain** if you like it.

---

## 🔐 **SSL Certificate Deep Dive**

### Let's Encrypt (Automatic SSL)

When you use a real domain (purchased or DuckDNS), Traefik can automatically get SSL certificates:

```yaml
# traefik.yml
certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email@example.com
      storage: /acme.json
      httpChallenge:
        entryPoint: web
```

**What Happens:**
1. Browser requests `https://sonarr.yourdomain.com`
2. Traefik checks: "Do I have a cert for this domain?"
3. If NO: Traefik contacts Let's Encrypt
4. Let's Encrypt: "Prove you own this domain"
5. Traefik: Creates temporary file at `http://yourdomain.com/.well-known/acme-challenge/TOKEN`
6. Let's Encrypt: Checks file exists → Issues certificate
7. Traefik: Stores cert in `/acme.json` → Serves HTTPS
8. Auto-renewal happens every 60 days

**Certificate Storage:**
```bash
# acme.json format (don't edit manually!)
{
  "letsencrypt": {
    "Certificates": [
      {
        "domain": {
          "main": "sonarr.yourdomain.com"
        },
        "certificate": "...",
        "key": "...",
        "Store": "default"
      }
    ]
  }
}
```

### Self-Signed Certificates (Local DNS)

If using local DNS, you'll need self-signed certs:

```bash
# Generate self-signed cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout traefik.key -out traefik.crt \
  -subj "/CN=*.homelab.local"
```

**Browser Warning:**
> ⚠️ "Your connection is not private"
> NET::ERR_CERT_AUTHORITY_INVALID

You'll need to click "Advanced → Proceed" (annoying but works).

---

## 📋 **Complete Migration Checklist**

### Phase 1: Setup Traefik (30 minutes)

- [ ] **Choose domain strategy** (see options above)
- [ ] **Configure DNS** (point domain to your server)
- [ ] **Edit `/home/eduard/homelab/services/traefik/.env`**
  ```bash
  DOMAIN=yourdomain.com
  DASHBOARD_USER=admin:$apr1$xyz...  # use htpasswd to generate
  ACME_EMAIL=your-email@example.com
  ```
- [ ] **Enable SSL in `traefik.yml`** (currently commented out)
- [ ] **Deploy Traefik:**
  ```bash
  cd ~/homelab/services/traefik
  docker-compose up -d
  ```
- [ ] **Test dashboard:** `https://traefik.yourdomain.com`

### Phase 2: Migrate One Service (Test) (15 minutes)

Start with **Actual Budget** (already in homelab structure):

- [ ] **Add Traefik labels to `~/homelab/services/actual/docker-compose.yml`**
- [ ] **Stop old container:** `docker stop actual-budget`
- [ ] **Deploy new:** `cd ~/homelab/services/actual && docker-compose up -d`
- [ ] **Test old URL still works:** `http://172.26.1.31:5006`
- [ ] **Test new URL:** `https://budget.yourdomain.com`
- [ ] **If works, remove port exposure from compose file**

### Phase 3: Migrate Media Stack (1-2 hours)

For each service (Sonarr, Radarr, Prowlarr, etc.):

- [ ] **Create directory:** `~/homelab/media/sonarr/`
- [ ] **Find current config:** `docker inspect sonarr`
- [ ] **Create new docker-compose.yml** with Traefik labels
- [ ] **Test deployment** without stopping old one (use different container name)
- [ ] **Verify:** `https://sonarr.yourdomain.com`
- [ ] **Stop old, start new**
- [ ] **Update internal URLs** (e.g., Sonarr settings, Prowlarr apps)

### Phase 4: Migrate Monitoring (30 minutes)

- [ ] **Netdata** - Add authentication via Traefik
- [ ] **Grafana** - Route through Traefik
- [ ] **Test alerts** still work

### Phase 5: Migrate Game Servers (30 minutes)

- [ ] **Zomboid** - Already in homelab, add Traefik labels
- [ ] **V Rising** - Already in homelab, add Traefik labels

### Phase 6: Update Bookmarks (10 minutes)

- [ ] **Update browser bookmarks** to new URLs
- [ ] **Test from mobile devices**
- [ ] **Share with family** (if applicable)

---

## 🎨 **Custom Naming Ideas**

You can make URLs more intuitive than just the app name:

```
Service      → Boring URL              → Better URL
──────────────────────────────────────────────────────
Overseerr    → overseerr.domain.com   → requests.domain.com
Tautulli     → tautulli.domain.com    → stats.domain.com
qBittorrent  → qbittorrent.domain.com → torrents.domain.com
Netdata      → netdata.domain.com     → monitor.domain.com
Actual       → actual.domain.com      → budget.domain.com
Grafana      → grafana.domain.com     → dashboard.domain.com
Prowlarr     → prowlarr.domain.com    → indexers.domain.com
```

Just change the `Host()` rule:
```yaml
# Instead of:
- "traefik.http.routers.overseerr.rule=Host(`overseerr.${DOMAIN}`)"

# Use:
- "traefik.http.routers.overseerr.rule=Host(`requests.${DOMAIN}`)"
```

---

## 🛡️ **Security Considerations**

### Network Isolation

Traefik connects to all networks but services don't need to:

```
┌─────────────┐
│  TRAEFIK    │
│  (connects  │
│   to all    │
│  networks)  │
└──────┬──────┘
       │
   ┌───┴───────────┬────────────┐
   │               │            │
┌──▼───────┐  ┌───▼────┐  ┌───▼────┐
│ media_net│  │gaming  │  │services│
│          │  │_net    │  │_net    │
│ Sonarr   │  │Zomboid │  │Actual  │
│ Radarr   │  │VRising │  │        │
└──────────┘  └────────┘  └────────┘
```

**Benefit:** Zomboid can't directly talk to Sonarr (different networks).

### Authentication Layers

```
Internet → Firewall → Traefik Auth → Service Auth
           (router)    (middleware)    (app login)
```

**Three layers of protection:**
1. **Firewall/VPN:** Only allow trusted IPs
2. **Traefik Middleware:** Basic auth before reaching service
3. **Service Login:** App's own authentication

### Headers & Security

Traefik can add security headers automatically:

```yaml
labels:
  - "traefik.http.middlewares.secure-headers.headers.stsSeconds=31536000"
  - "traefik.http.middlewares.secure-headers.headers.stsIncludeSubdomains=true"
  - "traefik.http.middlewares.secure-headers.headers.contentTypeNosniff=true"
  - "traefik.http.routers.sonarr.middlewares=secure-headers"
```

---

## 📊 **Performance Impact**

### Latency

**Without Traefik:**
```
Browser → Docker Container
~1ms
```

**With Traefik:**
```
Browser → Traefik → Docker Container
~2-3ms additional
```

**Impact:** Negligible (< 3ms added latency)

### Resource Usage

**Traefik Container:**
- CPU: ~0.5-1.0% (mostly idle)
- RAM: ~128MB (can spike to 512MB under load)
- Disk: ~200MB (image + logs)

**Verdict:** Very lightweight, won't impact server performance.

---

## 🚨 **Common Pitfalls & Solutions**

### Problem 1: "404 Not Found" from Traefik

**Cause:** Service not on same network as Traefik

**Solution:**
```yaml
networks:
  - media_net  # Add the network!
```

### Problem 2: Certificate Error

**Cause:** Let's Encrypt can't verify domain (DNS not pointing to server)

**Solution:**
```bash
# Check DNS resolution
nslookup sonarr.yourdomain.com

# Should return your public IP
# If not, fix DNS settings
```

### Problem 3: "Gateway Timeout"

**Cause:** Service not responding, or wrong port in labels

**Solution:**
```yaml
# Make sure this matches service's actual port
- "traefik.http.services.sonarr.loadbalancer.server.port=8989"
```

### Problem 4: Can't Access Dashboard

**Cause:** Wrong credentials or domain

**Solution:**
```bash
# Generate new password
htpasswd -nb admin yourpassword
# Copy output to .env file

# Check DNS
ping traefik.yourdomain.com
```

---

## 📚 **Learning Resources**

- **Traefik Docs:** https://doc.traefik.io/traefik/
- **Let's Encrypt:** https://letsencrypt.org/how-it-works/
- **Cloudflare Tunnel:** https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
- **htpasswd Generator:** https://hostingcanada.org/htpasswd-generator/

---

## 🎯 **Quick Start Decision Tree**

```
Do you need remote access?
│
├─ NO → Use Local DNS (.local)
│        - Free
│        - Self-signed certs (browser warnings)
│        - 100% private
│
└─ YES → Do you have $10/year for domain?
         │
         ├─ NO → Use DuckDNS
         │        - Free
         │        - Real SSL
         │        - subdomain.duckdns.org
         │
         └─ YES → Want maximum security?
                  │
                  ├─ YES → Use Cloudflare Tunnel
                  │         - No open ports
                  │         - DDoS protection
                  │
                  └─ NO → Buy domain + Let's Encrypt
                           - Full control
                           - Professional
```

---

## ✅ **Next Steps**

1. **Choose your domain strategy** (see options above)
2. **Read the migration checklist**
3. **Test with one service first** (Actual Budget recommended)
4. **Expand to all services** once confident

**Want me to help with any of these steps? Just ask!** 🚀

