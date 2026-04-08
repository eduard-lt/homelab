# CasaOS Integration - Final Steps

## ✅ What's Been Completed

1. **All docker-compose files updated** with CasaOS labels
2. **All containers recreated** and running with new labels
3. **Scripts created** for registration and management

## 🎯 Final Step: Register Apps with CasaOS

### Run These Commands:

```bash
cd /home/eduard/homelab

# Register all apps with CasaOS (creates symlinks)
sudo scripts/register-with-casaos.sh --all

# Restart CasaOS to detect new apps
sudo systemctl restart casaos
```

### What This Does:

The registration script creates symlinks in `/var/lib/casaos/apps/` that point to your compose files:

```
/var/lib/casaos/apps/sonarr/docker-compose.yml 
  → /home/eduard/homelab/media/sonarr/docker-compose.yml

/var/lib/casaos/apps/radarr/docker-compose.yml
  → /home/eduard/homelab/media/radarr/docker-compose.yml

... and so on for all 11 apps
```

**Benefits:**
- ✅ Single source of truth (files stay in homelab/)
- ✅ CasaOS can see and manage apps
- ✅ Changes in homelab/ automatically reflected
- ✅ Easy to unregister if needed

## 📊 Apps That Will Be Registered

**Media Stack (8 apps):**
- sonarr, radarr, lidarr, readarr
- prowlarr, overseerr, tautulli, qbittorrent

**Monitoring (2 apps):**
- grafana, netdata

**Services (1 app):**
- traefik

**Note:** discord-bot will be skipped (not currently running)

## 🔍 Verification After Registration

After running the commands, verify apps appear:

```bash
# Check via CLI
casaos-cli app-management list apps

# Check via API
curl -s http://localhost/v2/app_management/apps | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['installed'])"

# Check CasaOS UI
# Open: http://YOUR_SERVER_IP/
# You should see all apps in the dashboard
```

## 🛠️ Additional Management Commands

```bash
# List all registered apps
sudo scripts/register-with-casaos.sh --list

# Unregister a specific app
sudo scripts/register-with-casaos.sh --unregister sonarr

# Register a specific app manually
sudo scripts/register-with-casaos.sh --app sonarr /home/eduard/homelab/media/sonarr/docker-compose.yml
```

## ✨ What You'll Get

Once registered, in the CasaOS UI you'll be able to:

1. **See all apps** in one dashboard
2. **Quick restart** any service with one click
3. **Monitor status** (running, stopped, etc.)
4. **System resources** (CPU, RAM, disk, network)
5. **Quick access** to web UIs
6. **Container logs** (if CasaOS supports it)

All while keeping full docker-compose control!

## 🔄 If Something Goes Wrong

### Rollback entire integration:
```bash
cd /home/eduard/homelab/backups/casaos-integration-20260408-150541

# Restore docker-compose files
for file in docker-compose-files/*; do
    dest=$(echo $file | sed 's|docker-compose-files/||' | sed 's|-|/|g')
    cp $file /home/eduard/homelab/$dest
done

# Restore CasaOS database
sudo cp -r casaos-database/* /var/lib/casaos/db/
sudo systemctl restart casaos

# Recreate containers
cd /home/eduard/homelab
for app in media/sonarr media/radarr ...; do
    cd $app && docker-compose up -d
done
```

### Unregister all apps:
```bash
cd /home/eduard/homelab
for app in sonarr radarr lidarr readarr prowlarr overseerr tautulli qbittorrent grafana netdata traefik; do
    sudo scripts/register-with-casaos.sh --unregister $app
done
sudo systemctl restart casaos
```

## 📝 Current Container Status

All running with CasaOS labels:

```
✅ traefik            Up 3 minutes
✅ netdata            Up 3 minutes (healthy)
✅ grafana            Up 3 minutes
✅ qbittorrent        Up 3 minutes
✅ tautulli           Up 3 minutes
✅ overseerr          Up 3 minutes
✅ prowlarr           Up 3 minutes
✅ readarr            Up 3 minutes
✅ lidarr             Up 3 minutes
✅ radarr             Up 3 minutes
✅ sonarr             Up 18 minutes
```

All services are healthy and Traefik routing is preserved!

---

**Ready to proceed? Run the sudo commands above and let me know the result!**
