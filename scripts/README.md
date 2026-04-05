# Backup Scripts Documentation

## Overview

Automated backup system for homelab configurations and critical data.

## Scripts

### backup.sh
Main backup script that creates compressed archives of:
- Homelab configurations (docker-compose files, docs)
- Docker volumes (Portainer, monitoring, etc.)
- Actual Budget data
- Game server saves (weekly/monthly)
- Plex metadata (weekly/monthly)

**Usage:**
```bash
cd /home/eduard/homelab/scripts
./backup.sh daily    # Daily backup (configs, volumes, Actual Budget)
./backup.sh weekly   # Weekly backup (includes game servers)
./backup.sh monthly  # Monthly backup (full backup)
```

### restore.sh
Restore script for recovering data from backups.

**Usage:**
```bash
# List available backups
./restore.sh list

# Restore homelab configs
./restore.sh config /path/to/backup.tar.gz

# Restore Docker volume
./restore.sh volume /path/to/volume_backup.tar.gz

# Restore game server data
./restore.sh game /path/to/game_backup.tar.gz
```

## Backup Schedule

Configured in crontab (see backup-automation todo):

- **Daily (2 AM):** Configs, volumes, Actual Budget
- **Weekly (3 AM Sunday):** Everything including game servers
- **Monthly (4 AM 1st):** Full backup with extended retention

## Storage Locations

- **Local backups:** `/mnt/FastStorage/backups/`
  - `daily/` - 7 day retention
  - `weekly/` - 30 day retention
  - `monthly/` - 90 day retention

- **Offsite:** Sync to cloud storage (to be configured)

## What's Backed Up

### Daily
- ✅ Homelab configurations (all docker-compose.yml, .env.template, docs)
- ✅ Docker volumes (ollama, open-webui, etc.)
- ✅ Actual Budget data

### Weekly
- ✅ Everything from daily, plus:
- ✅ Project Zomboid saves
- ✅ V Rising saves
- ✅ Minecraft worlds
- ✅ Plex metadata and watch history

### Monthly
- ✅ Everything (full backup with longer retention)

## What's NOT Backed Up

- ❌ Media files (movies, TV shows, music) - too large, replaceable
- ❌ Download cache - temporary data
- ❌ Container images - can be re-pulled
- ❌ Log files - rotating logs handled separately

## Testing Backups

**Test the backup script:**
```bash
# Dry run to verify paths
./backup.sh daily

# Check backup created
ls -lh /mnt/FastStorage/backups/daily/
```

**Test restore:**
```bash
# List backups
./restore.sh list

# Test restore to temp location (modify script)
# Always test restores in non-production first!
```

## Backup Sizes (Estimated)

| Item | Size | Frequency |
|------|------|-----------|
| Homelab configs | ~10MB | Daily |
| Docker volumes | ~2GB | Daily |
| Actual Budget | ~50MB | Daily |
| Game servers | ~5GB | Weekly |
| Plex metadata | ~20GB | Weekly |

**Total storage needed:** ~100GB for full retention

## Monitoring

Logs are written to `/var/log/homelab-backup.log`

Check backup status:
```bash
tail -f /var/log/homelab-backup.log

# Check latest backup
ls -lt /mnt/FastStorage/backups/daily/ | head
```

## Recovery Scenarios

### Lost homelab configs
```bash
# Clone from GitHub (primary method)
git clone https://github.com/your-username/homelab.git

# OR restore from backup
./restore.sh config /path/to/latest/homelab_backup.tar.gz
```

### Lost Actual Budget data
```bash
./restore.sh actual /path/to/actual-budget_backup.tar.gz
cd /home/eduard/homelab/services/actual
docker-compose up -d
```

### Lost game save
```bash
./restore.sh game /path/to/zomboid_backup.tar.gz
cd /home/eduard/homelab/gaming/zomboid
docker-compose up -d
```

### Complete disaster recovery
1. Reinstall OS and Docker
2. Clone homelab repo from GitHub
3. Run restore script for data
4. Deploy services with docker-compose
5. Verify functionality

**Estimated RTO:** 2-4 hours

## Future Enhancements

- [ ] Encrypt backups before cloud sync
- [ ] Set up rclone for automatic cloud sync
- [ ] Add backup verification checksums
- [ ] Email/Discord notifications on backup completion
- [ ] Backup health monitoring dashboard

## Notes

- Backups use NVMe storage for speed
- Git already backs up configs to GitHub (primary method)
- These scripts are belt-and-suspenders for data
- Test restores quarterly to verify integrity
- Keep backup credentials in Vaultwarden
