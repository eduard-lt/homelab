# Homelab Backup Strategy

**Created:** 2026-04-05  
**Status:** Proposed (not yet implemented)

## Backup Philosophy: 3-2-1 Rule

- **3** copies of data (original + 2 backups)
- **2** different storage media types
- **1** copy offsite

---

## What to Backup

### Tier 1: Critical (Daily Backups)
**Cannot be recreated, essential for recovery**

1. **Docker Compose Configurations**
   - Location: `/home/eduard/homelab/`
   - Method: ✅ **Git (GitHub)** - Already implemented!
   - Frequency: On every change (git push)
   - Size: ~100KB
   - Priority: HIGHEST

2. **Actual Budget Data**
   - Location: `/home/eduard/actual/actual-data/` → `/home/eduard/homelab/services/actual/data/`
   - Method: Automated backup script + cloud sync
   - Frequency: Daily
   - Size: ~50MB (estimated)
   - Priority: HIGH

3. **Application Configs & Databases**
   - Locations:
     - Portainer data volume
     - *arr apps configs (Sonarr, Radarr, etc.)
     - Grafana dashboards and data sources
     - PhotoPrism database
   - Method: Docker volume backup script
   - Frequency: Daily
   - Size: ~2-5GB (estimated)
   - Priority: HIGH

### Tier 2: Important (Weekly Backups)
**Can be partially recreated, but time-consuming**

4. **Plex Metadata & Watch History**
   - Location: `/mnt/Data/Plex/`
   - Method: Incremental backup to external drive
   - Frequency: Weekly
   - Size: ~20-50GB (estimated)
   - Priority: MEDIUM
   - Note: Media files NOT backed up (can be re-acquired)

5. **PhotoPrism Library Metadata**
   - Location: TBD (identify in PhotoPrism config)
   - Method: Backup script
   - Frequency: Weekly
   - Size: ~10-20GB (estimated)
   - Priority: MEDIUM
   - Note: Original photos should already be backed up separately

6. **Game Server Saves**
   - Locations:
     - `/mnt/Data/Zomboid/` - Project Zomboid
     - `/mnt/Data/Vrising_crack/` - V Rising (after migration)
     - `/mnt/Data/Minecraft/` - Minecraft worlds
   - Method: Backup script with compression
   - Frequency: Weekly (or before major updates)
   - Size: ~5-15GB (estimated)
   - Priority: MEDIUM

### Tier 3: Optional (Monthly or Manual)
**Can be easily recreated or not critical**

7. **Download History**
   - Location: qBittorrent data
   - Method: Optional
   - Frequency: Monthly or skip
   - Priority: LOW

8. **Container Images**
   - Method: Not backed up (can be re-pulled)
   - Note: Keep docker-compose.yml with specific versions
   - Priority: LOW

9. **Media Files (Movies, TV, Music)**
   - Location: `/mnt/Data/` (various)
   - Method: Not backed up (can be re-acquired)
   - Size: ~5.9TB
   - Priority: SKIP (too large, replaceable)

---

## Backup Methods

### Method 1: Git/GitHub (Configs) ✅ ACTIVE
**For:** Docker compose files, documentation

```bash
# Already configured!
cd /home/eduard/homelab
git add .
git commit -m "Update configs"
git push origin main
```

**Status:** ✅ Implemented  
**Frequency:** On every change  
**Storage:** GitHub (remote, offsite)  
**Restore:** `git clone`

### Method 2: Automated Backup Script (Data)
**For:** Application data, databases, configs

**Script Location:** `/home/eduard/homelab/scripts/backup.sh`

**Features:**
- Backup Docker volumes
- Backup critical data directories
- Compression (tar.gz)
- Timestamped backups
- Automatic cleanup of old backups (30 day retention)
- Logging

**Storage:**
- Local: `/mnt/FastStorage/backups/` (NVMe for speed)
- Offsite: Sync to cloud storage (Backblaze B2 or AWS S3)

**Schedule:** Daily via cron at 2 AM

### Method 3: Cloud Sync (Offsite)
**For:** Critical backups offsite storage

**Options:**
1. **Backblaze B2** (Recommended)
   - $6/TB/month
   - S3-compatible
   - Free downloads up to 3x storage
   
2. **AWS S3 Glacier Deep Archive**
   - $1/TB/month
   - Cheaper but slow retrieval
   
3. **External Drive Rotation**
   - Free (one-time cost)
   - Manual process
   - Take offsite weekly/monthly

**Tools:** 
- `rclone` for cloud sync
- Encryption: GPG before upload

---

## Backup Schedule

### Daily (2:00 AM)
```
- Actual Budget data
- Docker volumes (Portainer, *arr configs)
- Application databases
- Sync to local NVMe storage
```

### Weekly (Sunday 3:00 AM)
```
- Plex metadata
- PhotoPrism metadata
- Game server saves
- Cloud sync of daily backups
```

### Monthly (1st of month)
```
- Full system backup verification
- Test restore procedure
- Cleanup old backups (>30 days)
```

### On-Demand
```
- Before major updates
- Before configuration changes
- Before Docker container updates
```

---

## Storage Allocation

### Local Backups
- **Location:** `/mnt/FastStorage/backups/`
- **Capacity:** 400GB available
- **Retention:** 30 days
- **Estimated Usage:** ~50-100GB

### Offsite Backups
- **Location:** Cloud storage (Backblaze B2)
- **Capacity:** 100GB plan
- **Retention:** 90 days (compressed)
- **Estimated Cost:** ~$0.60/month

---

## Backup Script Implementation

### Directory Structure
```
/home/eduard/homelab/
├── scripts/
│   ├── backup.sh              # Main backup script
│   ├── backup-docker-volumes.sh
│   ├── backup-configs.sh
│   └── restore.sh             # Restore script
├── backups/                   # Local temp (excluded from git)
└── docs/
    └── RESTORE-GUIDE.md       # Restoration procedures
```

### Cron Schedule
```cron
# Daily backup at 2 AM
0 2 * * * /home/eduard/homelab/scripts/backup.sh daily >> /var/log/homelab-backup.log 2>&1

# Weekly backup at 3 AM on Sunday
0 3 * * 0 /home/eduard/homelab/scripts/backup.sh weekly >> /var/log/homelab-backup.log 2>&1

# Monthly backup at 4 AM on 1st
0 4 1 * * /home/eduard/homelab/scripts/backup.sh monthly >> /var/log/homelab-backup.log 2>&1
```

---

## Recovery Time Objectives (RTO)

### Complete System Loss
- **RTO:** 2-4 hours
- **Steps:**
  1. Reinstall OS and Docker (30 min)
  2. Clone homelab repo (5 min)
  3. Restore data from cloud backup (1-2 hours)
  4. Deploy services (30 min)
  5. Verify functionality (30 min)

### Service-Specific Recovery
- **Actual Budget:** 10 minutes
- **Plex:** 1-2 hours (metadata restore + rescan)
- **Game Servers:** 30 minutes
- **Docker configs:** 5 minutes (git clone)

---

## Testing & Verification

### Monthly Tests
1. Test git restore: Clone repo to temp directory
2. Test data restore: Restore one backup file
3. Verify backup integrity: Check tar.gz files
4. Check backup sizes: Ensure not growing unexpectedly

### Quarterly Tests
1. Full disaster recovery drill
2. Restore to test VM or spare hardware
3. Document any issues
4. Update procedures

---

## Critical Data Inventory

| Data Type | Location | Size | Backup Method | Frequency |
|-----------|----------|------|---------------|-----------|
| Docker Configs | `/home/eduard/homelab/` | ~100KB | Git | On change |
| Actual Budget | `./services/actual/data/` | ~50MB | Script | Daily |
| Portainer Data | Docker volume | ~100MB | Script | Daily |
| *arr Configs | Docker volumes | ~2GB | Script | Daily |
| Grafana | Docker volume | ~500MB | Script | Daily |
| Plex Metadata | `/mnt/Data/Plex/` | ~30GB | Script | Weekly |
| PhotoPrism DB | Docker volume | ~5GB | Script | Weekly |
| Game Saves | `/mnt/Data/*` | ~10GB | Script | Weekly |

**Total Critical Data:** ~50GB  
**Backup Storage Needed:** ~100GB (with retention)

---

## Implementation Status

- ✅ **Phase 1:** Git backup for configs (COMPLETE)
- ⏳ **Phase 2:** Create backup scripts (NEXT)
- ⏳ **Phase 3:** Set up cron automation
- ⏳ **Phase 4:** Configure cloud storage
- ⏳ **Phase 5:** Test restore procedures
- ⏳ **Phase 6:** Document recovery guide

---

## Next Actions

1. Create backup scripts in `/home/eduard/homelab/scripts/`
2. Test scripts manually
3. Set up Backblaze B2 or similar cloud storage
4. Configure rclone for cloud sync
5. Add cron jobs
6. Document restore procedures
7. Run first full backup
8. Test restore process

---

## Notes

- **Git backup already working!** Configs are safe.
- Most critical data is small (<50GB)
- Media files intentionally NOT backed up (too large, replaceable)
- NVMe storage underutilized - perfect for local backup cache
- Cloud storage costs minimal (~$1-2/month for critical data)
- Consider Vaultwarden for storing backup credentials

**Estimated Monthly Cost:** $1-2 for cloud storage  
**Estimated Setup Time:** 4-6 hours  
**Maintenance:** ~30 min/month
