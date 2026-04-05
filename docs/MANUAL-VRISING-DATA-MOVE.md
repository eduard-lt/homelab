# Mount Path Fix - Manual Action Required

## ⚠️ Action Needed: Move V Rising Data

The V Rising server data is currently in `/DATA/` (root filesystem) but should be in `/mnt/Data/` (main storage drive).

### Run These Commands:

```bash
# Move V Rising data to correct location (requires password)
sudo mv /DATA/Vrising /mnt/Data/
sudo mv /DATA/Vrising_crack /mnt/Data/

# Verify the move
ls -la /mnt/Data/ | grep -i vrising

# Optional: Archive old /DATA directory
sudo mv /DATA /DATA.old.backup
```

### What This Fixes:

- ✅ V Rising data moved to main 7.3TB storage drive
- ✅ Consistent paths across all services (`/mnt/Data/`)
- ✅ Updated docker-compose.yml already created at: `/home/eduard/homelab/gaming/vrising/docker-compose.yml`

### After Moving:

Test the V Rising server with the new configuration:
```bash
cd /home/eduard/homelab/gaming/vrising
docker-compose up -d
docker logs vrising
```

### Current Status:

- ✅ V Rising compose file migrated to homelab repo
- ✅ Paths updated to use `/mnt/Data/`
- ⚠️ Data still needs to be moved (manual sudo command required)
- ⚠️ Old `/home/eduard/docker-compose.yml` should be removed after testing

---

**Note:** The new V Rising configuration is ready and will work correctly once the data is moved to `/mnt/Data/`.
