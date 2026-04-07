# 🎉 Traefik + Tailscale - WORKING Configuration!

**Last Updated:** 2026-04-06  
**Status:** ✅ WORKING!

---

## ✅ **What's Working**

1. **Traefik Reverse Proxy**
   - Running on Tailscale IP: `100.70.106.23`
   - Ports: 8080 (HTTP), 8443 (HTTPS), 9080 (Dashboard)
   - SSL certificates: `thedarkurge.li-rattlesnake.ts.net`

2. **Actual Budget**
   - ✅ Working via HTTPS: `https://100.70.106.23:8443`
   - ✅ SharedArrayBuffer enabled (COOP/COEP headers)
   - ✅ Proper SSL/TLS encryption

3. **Security**
   - ✅ Only accessible via Tailscale network
   - ✅ Real SSL certificates from Tailscale
   - ✅ Plex remains public (intentional)

---

## 📱 **Access URLs**

### From Tailscale Network Only:

```
Traefik Dashboard:  http://100.70.106.23:9080/dashboard/
                    Username: admin
                    Password: (your admin password)

Actual Budget:      https://100.70.106.23:8443
                    (Certificate warning - click Advanced > Proceed)

Alternative:        http://100.70.106.23:5006
                    (Direct port - SharedArrayBuffer error)
```

### From Anywhere (Public):

```
Plex:              http://YOUR-PUBLIC-IP:32400/web
                   (Intentional public exception)
```

---

## ⚠️ **Important Notes**

### Why IP Instead of Domain?

**Tried:** `https://budget.thedarkurge.li-rattlesnake.ts.net:8443`  
**Result:** "Server Not Found"  
**Reason:** MagicDNS not resolving on your device

**Solution:** Use IP address `https://100.70.106.23:8443`  
**Works:** ✅ Yes! (certificate warning is expected)

### Why Certificate Warning?

When accessing via IP (`100.70.106.23`), the browser sees:
- Certificate is for: `thedarkurge.li-rattlesnake.ts.net`
- You're accessing: `100.70.106.23`
- Browser says: "Name mismatch!"

**This is SAFE!** The certificate is valid, just for a different name.  
Click "Advanced" → "Proceed" (or similar in your browser).

### Why Port 8443 Instead of 443?

- CasaOS is using port 80 (HTTP)
- Traefik uses 8080 (HTTP) and 8443 (HTTPS)
- This avoids port conflicts

---

## 🔧 **Technical Details**

### Traefik Configuration

```yaml
Binding: 100.70.106.23:8080 → HTTP
         100.70.106.23:8443 → HTTPS
         100.70.106.23:9080 → Dashboard

Networks: services_net, media_net, gaming_net, monitoring_net
```

### Actual Budget Labels

```yaml
Rule: Host(`budget.thedarkurge.li-rattlesnake.ts.net`) || Host(`100.70.106.23`)
Entrypoint: websecure (HTTPS)
TLS: Enabled
Headers: COOP/COEP for SharedArrayBuffer
```

---

## 🚀 **Next Steps**

### Option 1: Fix MagicDNS (Recommended)

**Goal:** Make domains work (`budget.thedarkurge.li-rattlesnake.ts.net`)

**Steps:**
1. On your device (iPhone/PC), open Tailscale app
2. Go to Settings
3. Enable "Use Tailscale DNS" or "Accept DNS"
4. Reconnect to Tailscale
5. Test: `ping thedarkurge.li-rattlesnake.ts.net`

**If it works:**
- Access: `https://budget.thedarkurge.li-rattlesnake.ts.net:8443`
- No certificate warning!
- Cleaner URLs!

### Option 2: Migrate More Services

Now that we know the pattern works, we can migrate:
- Sonarr → `https://100.70.106.23:8443` (or `sonarr.domain:8443`)
- Radarr → `https://100.70.106.23:8443` (or `radarr.domain:8443`)
- Grafana → `https://100.70.106.23:8443` (or `grafana.domain:8443`)

**Each service needs:**
1. Traefik labels in docker-compose.yml
2. Rule accepting IP: `Host(`service.${DOMAIN}`) || Host(`100.70.106.23`)`
3. Unique subdomain OR path-based routing

### Option 3: Keep It Simple

**What's working NOW:**
- Actual Budget: `https://100.70.106.23:8443` ✅
- Traefik Dashboard: `http://100.70.106.23:9080/dashboard/` ✅
- Other services: Direct ports (`100.70.106.23:PORT`)

**Benefits:**
- Everything accessible
- Secure (Tailscale only)
- No complexity
- Can improve later

---

## 🐛 **Troubleshooting**

### "Server Not Found"

**Problem:** Domain doesn't resolve  
**Solution:** Use IP: `https://100.70.106.23:8443`

### "Certificate Warning"

**Problem:** Name mismatch (cert for domain, accessing via IP)  
**Solution:** Click "Advanced" → "Proceed" (safe!)

### "SharedArrayBuffer Error"

**Problem:** Accessing via HTTP not HTTPS  
**Solution:** Use `https://100.70.106.23:8443` (not port 5006)

### "404 Page Not Found"

**Problem:** Traefik can't route to service  
**Check:**
1. Is container running? `docker ps | grep actual`
2. Is router registered? Visit dashboard
3. Is network correct? `docker inspect actual-budget | grep Networks`

---

## 📊 **Current Progress**

**Services on Traefik:** 1/15 (6.7%)
- ✅ Actual Budget

**Services Remaining:**
- Sonarr, Radarr, Prowlarr, Lidarr, Readarr
- Overseerr, Tautulli, qBittorrent
- Plex (keep public)
- Grafana, Netdata
- Zomboid, V Rising

**Tasks Done:** 21/46 (45.7%)

---

## 💡 **Key Learnings**

1. **Actual Budget requires HTTPS** for SharedArrayBuffer
2. **MagicDNS needs device configuration** to resolve domains
3. **IP-based access works** as a fallback
4. **Certificate warnings are expected** when using IP with domain cert
5. **Router rules can accept multiple hosts** (`||` operator)

---

**🎉 Major milestone achieved! Traefik + Tailscale + HTTPS working!**

