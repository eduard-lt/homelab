# Traefik Access URLs - Quick Reference

**Updated:** 2026-04-05  
**Domain:** thedarkurge.tailc19e34.ts.net

---

## 🔒 **Important: Tailscale Only Access**

All services below are **only accessible when connected to your Tailscale network**!

- ✅ Works from: iPhone, iPad, PC, Raspberry Pi (when Tailscale is on)
- ❌ Does NOT work from: Public internet, friends without Tailscale

**Exception: Plex is still publicly accessible** (see below)

---

## 🎯 **Traefik Dashboard**

**URL:** `https://thedarkurge.tailc19e34.ts.net:8443/dashboard/`  
**Note:** Port 8443 (CasaOS uses port 80/443)
**Auth:** Username: `admin`, Password: (your dashboard password)

**Important:** Don't forget the trailing slash: `/dashboard/`

---

## 📱 **Service URLs**

Once services are migrated to Traefik, use these URLs:

### Media Stack
```
Sonarr:      https://sonarr.thedarkurge.tailc19e34.ts.net:8443
Radarr:      https://radarr.thedarkurge.tailc19e34.ts.net:8443
Prowlarr:    https://prowlarr.thedarkurge.tailc19e34.ts.net:8443
Lidarr:      https://lidarr.thedarkurge.tailc19e34.ts.net:8443
Readarr:     https://readarr.thedarkurge.tailc19e34.ts.net:8443
Overseerr:   https://requests.thedarkurge.tailc19e34.ts.net:8443
Tautulli:    https://stats.thedarkurge.tailc19e34.ts.net:8443
qBittorrent: https://torrents.thedarkurge.tailc19e34.ts.net:8443
```

### Services
```
Actual:      https://budget.thedarkurge.tailc19e34.ts.net:8443
```

### Monitoring
```
Grafana:     https://grafana.thedarkurge.tailc19e34.ts.net:8443
Netdata:     https://monitor.thedarkurge.tailc19e34.ts.net:8443
```

### Gaming
```
Zomboid:     https://zomboid.thedarkurge.tailc19e34.ts.net:8443
V Rising:    https://vrising.thedarkurge.tailc19e34.ts.net:8443
```

---

## 🎬 **Plex - Public Exception**

**Plex remains publicly accessible:**

```
From Tailscale:       http://100.70.106.23:32400/web
From Public Internet: http://YOUR-PUBLIC-IP:32400/web
From Local Network:   http://172.26.1.31:32400/web
```

**Why:** Plex needs to work for family/friends and smart TVs without Tailscale.

---

## 🔧 **Port Reference**

```
Service          Tailscale Binding          Container Port
──────────────────────────────────────────────────────────
Traefik HTTP     100.70.106.23:8080  →  80
Traefik HTTPS    100.70.106.23:8443  →  443
Traefik Dash     100.70.106.23:9080  →  8080

CasaOS           0.0.0.0:80          →  (system service)
Plex             0.0.0.0:32400       →  32400 (public)
```

---

## ✅ **Testing Checklist**

### From Device on Tailscale (iPhone, PC)

- [ ] Dashboard: `https://thedarkurge.tailc19e34.ts.net:8443/dashboard/`
- [ ] Should show Traefik dashboard with login
- [ ] SSL certificate should be valid (green lock)

### From Public Internet (No Tailscale)

- [ ] Dashboard: `https://thedarkurge.tailc19e34.ts.net:8443/dashboard/`
- [ ] Should NOT work (connection timeout/refused)
- [ ] Plex: `http://PUBLIC-IP:32400/web`
- [ ] Should work! (public exception)

---

## 🚀 **Next Steps**

1. **Test Traefik Dashboard** (from Tailscale device)
2. **Migrate Actual Budget** (add Traefik labels)
3. **Migrate Media Stack** (Sonarr, Radarr, etc.)
4. **Update Bookmarks** (save new URLs)

---

## 🔒 **Security Notes**

- ✅ **99% Private:** All services except Plex require Tailscale
- ✅ **Real SSL:** Valid certificates from Tailscale (no warnings)
- ✅ **No Port Forwarding:** Only Plex (32400) and CasaOS (80) exposed
- ✅ **Encrypted:** All traffic uses HTTPS

---

## 📞 **Troubleshooting**

### "Can't reach traefik.thedarkurge.tailc19e34.ts.net"

**Solution:**
```bash
# On device trying to access:
tailscale status

# Should show "100.70.106.23  thedarkurge"
# If not connected: tailscale up
```

### "Certificate error"

**Solution:** Tailscale certificates should be automatically trusted. If you see a warning, Tailscale might not be properly connected.

### "Dashboard shows no routers"

**Solution:** This is normal! No services migrated yet. After we add Traefik labels to services, they'll appear.

---

**🎉 Traefik is now running! Ready to migrate services when you are!**
