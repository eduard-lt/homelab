# Path-Based Routing - Complete Explanation

**Created:** 2026-04-06

---

## 🎯 **What Is Path-Based Routing?**

Instead of using different **subdomains** for each service, you use different **paths** on ONE domain.

### Visual Comparison

```
SUBDOMAIN-BASED (What we configured):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
https://budget.thedarkurge.li-rattlesnake.ts.net:8443    → Actual Budget
https://sonarr.thedarkurge.li-rattlesnake.ts.net:8443    → Sonarr
https://radarr.thedarkurge.li-rattlesnake.ts.net:8443    → Radarr
https://grafana.thedarkurge.li-rattlesnake.ts.net:8443   → Grafana
         ↑
    Different subdomain for each service

Problem: Need separate certificate for EACH subdomain!
         Your certificate only covers "thedarkurge.li-rattlesnake.ts.net"
         So you get certificate warnings for "budget.", "sonarr.", etc.


PATH-BASED (Alternative approach):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
https://thedarkurge.li-rattlesnake.ts.net:8443/actual    → Actual Budget
https://thedarkurge.li-rattlesnake.ts.net:8443/sonarr    → Sonarr
https://thedarkurge.li-rattlesnake.ts.net:8443/radarr    → Radarr
https://thedarkurge.li-rattlesnake.ts.net:8443/grafana   → Grafana
                                               ↑
                                    Different path for each service

Benefit: ONE domain = ONE certificate = NO warnings!
         All services use "thedarkurge.li-rattlesnake.ts.net" cert
```

---

## 📊 **How It Works**

### Current Setup (Subdomain-Based)

```
User requests: https://budget.thedarkurge.li-rattlesnake.ts.net:8443

Browser checks certificate:
  Certificate is for: thedarkurge.li-rattlesnake.ts.net
  You're accessing:   budget.thedarkurge.li-rattlesnake.ts.net
  ❌ MISMATCH! → Certificate warning!

Traefik routing:
  Rule: Host(`budget.thedarkurge.li-rattlesnake.ts.net`)
  Matches! → Route to Actual Budget container
```

### Path-Based Routing

```
User requests: https://thedarkurge.li-rattlesnake.ts.net:8443/actual

Browser checks certificate:
  Certificate is for: thedarkurge.li-rattlesnake.ts.net
  You're accessing:   thedarkurge.li-rattlesnake.ts.net
  ✅ MATCH! → No warning!

Traefik routing:
  Rule: Host(`thedarkurge.li-rattlesnake.ts.net`) && PathPrefix(`/actual`)
  Matches! → Strip "/actual" → Route to Actual Budget container
```

---

## 🔧 **Configuration Example**

### Actual Budget (Current - Subdomain)

```yaml
labels:
  - "traefik.http.routers.actual.rule=Host(`budget.${DOMAIN}`)"
  - "traefik.http.services.actual.loadbalancer.server.port=5006"
```

**Access:** `https://budget.thedarkurge.li-rattlesnake.ts.net:8443`  
**Problem:** Certificate warning!

### Actual Budget (Path-Based)

```yaml
labels:
  # Router matches path /actual
  - "traefik.http.routers.actual.rule=Host(`${DOMAIN}`) && PathPrefix(`/actual`)"
  - "traefik.http.routers.actual.entrypoints=websecure"
  
  # Strip /actual before forwarding to container
  - "traefik.http.routers.actual.middlewares=actual-strip"
  - "traefik.http.middlewares.actual-strip.stripprefix.prefixes=/actual"
  
  # Service configuration
  - "traefik.http.services.actual.loadbalancer.server.port=5006"
```

**Access:** `https://thedarkurge.li-rattlesnake.ts.net:8443/actual`  
**Result:** ✅ No certificate warning!

---

## 🎨 **Your Homelab With Path-Based Routing**

### All Services On ONE URL

```
BASE URL: https://thedarkurge.li-rattlesnake.ts.net:8443

SERVICES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/traefik     → Traefik Dashboard
/actual      → Actual Budget
/sonarr      → Sonarr (TV shows)
/radarr      → Radarr (Movies)
/prowlarr    → Prowlarr (Indexers)
/lidarr      → Lidarr (Music)
/readarr     → Readarr (Books)
/requests    → Overseerr (Media requests)
/downloads   → qBittorrent
/stats       → Tautulli (Plex stats)
/grafana     → Grafana (Dashboards)
/monitor     → Netdata (System monitoring)
```

### Example URLs

```
Actual Budget:  https://thedarkurge.li-rattlesnake.ts.net:8443/actual
Sonarr:         https://thedarkurge.li-rattlesnake.ts.net:8443/sonarr
Grafana:        https://thedarkurge.li-rattlesnake.ts.net:8443/grafana
```

**All using the SAME certificate - no warnings!**

---

## ✅ **Pros & Cons**

### ✅ Advantages

1. **No Certificate Warnings**
   - ONE domain = ONE certificate
   - Everything just works!

2. **Simpler DNS**
   - Don't need MagicDNS for subdomains
   - Just one hostname to remember

3. **Easier Bookmarks**
   - All services under one domain
   - Organize by path

4. **Mobile-Friendly**
   - Shorter URLs
   - Less typing on phone

5. **Professional Looking**
   - `domain.com/sonarr` vs `sonarr.domain.com`
   - Both are valid, path-based looks clean

### ❌ Disadvantages

1. **Some Apps Don't Support It**
   - Apps that expect to be at root path (`/`)
   - Might have issues with URLs
   - **Sonarr/Radarr**: Work fine! ✅
   - **Actual Budget**: Might need special config

2. **Longer URLs**
   - `/actual` added to every URL
   - More typing if not bookmarked

3. **Base Path Configuration**
   - Some apps need "Base URL" setting
   - Example: Tell Sonarr it lives at `/sonarr`

4. **Path Conflicts**
   - Can't have two services on same path
   - Need to manage path names

---

## 🛠️ **What Needs To Change**

### Traefik Configuration

**Current (subdomain-based):**
```yaml
labels:
  - "traefik.http.routers.actual.rule=Host(`budget.${DOMAIN}`)"
```

**New (path-based):**
```yaml
labels:
  - "traefik.http.routers.actual.rule=Host(`${DOMAIN}`) && PathPrefix(`/actual`)"
  - "traefik.http.routers.actual.middlewares=actual-strip"
  - "traefik.http.middlewares.actual-strip.stripprefix.prefixes=/actual"
```

### App Configuration

Some apps need to know they're behind a path:

**Sonarr Example:**
```
Settings → General → URL Base
Set to: /sonarr
```

**Radarr Example:**
```
Settings → General → URL Base
Set to: /radarr
```

**Grafana Example:**
```yaml
environment:
  - GF_SERVER_ROOT_URL=https://thedarkurge.li-rattlesnake.ts.net:8443/grafana
  - GF_SERVER_SERVE_FROM_SUB_PATH=true
```

---

## 🎯 **Real-World Example: Sonarr**

### Configuration Steps

**1. Update docker-compose.yml**

```yaml
version: "3.8"

services:
  sonarr:
    container_name: sonarr
    image: linuxserver/sonarr:latest
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - /path/to/config:/config
      - /path/to/tv:/tv
    networks:
      - media_net
    labels:
      # Enable Traefik
      - "traefik.enable=true"
      
      # Path-based routing
      - "traefik.http.routers.sonarr.rule=Host(`${DOMAIN}`) && PathPrefix(`/sonarr`)"
      - "traefik.http.routers.sonarr.entrypoints=websecure"
      - "traefik.http.routers.sonarr.tls=true"
      
      # Strip /sonarr prefix before forwarding
      - "traefik.http.routers.sonarr.middlewares=sonarr-strip,sonarr-headers"
      - "traefik.http.middlewares.sonarr-strip.stripprefix.prefixes=/sonarr"
      
      # Security headers
      - "traefik.http.middlewares.sonarr-headers.headers.customResponseHeaders.X-Forwarded-Proto=https"
      
      # Service configuration
      - "traefik.http.services.sonarr.loadbalancer.server.port=8989"

networks:
  media_net:
    external: true
```

**2. Configure Sonarr URL Base**

After deploying, go to Sonarr web interface:
1. Settings → General
2. Find "URL Base"
3. Enter: `/sonarr`
4. Save & restart Sonarr

**3. Access**

```
URL: https://thedarkurge.li-rattlesnake.ts.net:8443/sonarr
✅ No certificate warning!
✅ Sonarr loads correctly!
```

---

## 🔄 **Migration Strategy**

### Option A: Migrate All At Once

1. Update all docker-compose.yml files
2. Configure URL Base in each app
3. Restart all services
4. Update bookmarks

**Time:** 1-2 hours  
**Risk:** Medium (all services down if issue)

### Option B: Migrate One By One

1. Start with Actual Budget
2. Test thoroughly
3. Then Sonarr
4. Then Radarr
5. Continue...

**Time:** 2-3 hours total  
**Risk:** Low (other services still work)

### Option C: Hybrid Approach

Keep both working:
- Path-based for new services
- IP-based for existing services
- Migrate gradually

**Time:** Ongoing  
**Risk:** Very low

---

## 🎬 **Implementation Plan (If You Choose This)**

### Phase 1: Test with Actual Budget (15 min)

1. Update Actual Budget labels to path-based
2. Test: `https://thedarkurge.li-rattlesnake.ts.net:8443/actual`
3. Verify no certificate warning
4. Check if Actual works correctly

### Phase 2: Migrate Sonarr (10 min)

1. Update Sonarr docker-compose
2. Set URL Base in Sonarr settings
3. Test: `https://thedarkurge.li-rattlesnake.ts.net:8443/sonarr`

### Phase 3: Migrate Other Services (30 min)

1. Radarr, Prowlarr, etc.
2. Each follows same pattern
3. Test each after migration

### Phase 4: Update Documentation (5 min)

1. Update bookmarks
2. Create service index page
3. Share URLs with family

**Total Time: ~1 hour**

---

## 💡 **My Recommendation**

### For Your Situation

**Pros of path-based for you:**
- ✅ Solves certificate warning issue
- ✅ Works with your current Tailscale cert
- ✅ Clean, professional URLs
- ✅ Easier to manage

**Cons:**
- ⚠️ Some work to configure URL Base in each app
- ⚠️ Actual Budget might need testing (SharedArrayBuffer + paths)
- ⚠️ Migration time (~1 hour)

### Alternative: Keep IP-Based

**What you have now works great:**
- `https://100.70.106.23:8443` → Actual Budget ✅
- Certificate warning is expected and safe
- Zero additional configuration
- Can bookmark it

**Suggestion:** 
Keep using IP for now, migrate more services to Traefik with IP-based access, THEN decide if you want path-based routing once you see how many services you have.

---

## 🎯 **Summary**

**Path-Based Routing:**
```
ONE domain + different paths = ONE certificate = NO warnings

https://thedarkurge.li-rattlesnake.ts.net:8443/actual   ✅
https://thedarkurge.li-rattlesnake.ts.net:8443/sonarr   ✅
https://thedarkurge.li-rattlesnake.ts.net:8443/grafana  ✅
```

**Current IP-Based:**
```
IP address + port 8443 = Certificate warning (safe to ignore)

https://100.70.106.23:8443  ⚠️ (but works perfectly!)
```

---

**Want me to set up path-based routing for Actual Budget so you can try it?**

Or would you prefer to:
- Keep current setup and migrate more services with IP-based access
- Enable MagicDNS and accept certificate warnings for subdomains
- Something else

Let me know! 🚀
