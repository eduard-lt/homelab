# Mount Path Standardization Report

## Issue Identified

Two separate directories are being used:
- `/DATA` - Small directory (15GB) in root, contains only V Rising data
- `/mnt/Data` - Actual mounted drive (7.3TB), contains main homelab data

## Current State

### `/mnt/Data` (CORRECT - Main Storage)
- **Device:** `/dev/sdb1`
- **Size:** 7.3TB (5.9TB used, 1.3TB free)
- **Mount Point:** `/mnt/Data`
- **Contents:**
  - Apps/, Backup/, Books/, Downloads/ (main downloads)
  - Minecraft/, Music/, Photos/, Plex/
  - Github/, Files/, Server_data_drive/
  - **Zomboid/** ✅ (correct location)

### `/DATA` (INCORRECT - Root Directory)
- **Type:** Regular directory (NOT mounted, NOT a symlink)
- **Size:** ~15GB
- **Location:** Root filesystem
- **Contents:**
  - AppData/, Documents/, Downloads/ (duplicate)
  - Gallery/, Media/, presentation.txt
  - **Vrising/** and **Vrising_crack/** ❌ (wrong location)

## Services Using Wrong Path

### V Rising Server
- **Current:** `/DATA/Vrising_crack/` 
- **Should be:** `/mnt/Data/Vrising/`
- **Config:** `/home/eduard/docker-compose.yml`
- **Status:** Not currently running

## Recommendation

### Option 1: Move V Rising Data (RECOMMENDED)
Move V Rising data from `/DATA/` to `/mnt/Data/` and update compose file:
```bash
# Move data
sudo mv /DATA/Vrising /mnt/Data/
sudo mv /DATA/Vrising_crack /mnt/Data/

# Update docker-compose.yml to use /mnt/Data/
```

**Pros:**
- Consistent with all other services
- Data on proper storage drive (not root filesystem)
- Simple and clean

**Cons:**
- Requires moving ~15GB of data
- V Rising needs reconfiguration

### Option 2: Create Symlink
Create symlink `/DATA` → `/mnt/Data`:
```bash
# Backup old /DATA
sudo mv /DATA /DATA.old

# Create symlink
sudo ln -s /mnt/Data /DATA
```

**Pros:**
- No need to move data
- Works immediately

**Cons:**
- V Rising data would still be in wrong location
- Duplicate Downloads folders would conflict
- Not a clean solution

### Option 3: Bind Mount
Mount `/mnt/Data` at `/DATA`:
```bash
# Add to /etc/fstab
/mnt/Data /DATA none bind 0 0
```

**Pros:**
- Both paths work
- No data movement

**Cons:**
- Confusing to have two paths to same location
- Still doesn't fix V Rising being in root filesystem

## Chosen Solution: Option 1 (Move & Update)

1. Move V Rising data to proper location
2. Update docker-compose.yml
3. Remove or archive old /DATA directory
4. Document the change

## Implementation Steps

1. ✅ Identify issue
2. ⏳ Move V Rising data to `/mnt/Data/`
3. ⏳ Update V Rising docker-compose.yml
4. ⏳ Test V Rising server starts correctly
5. ⏳ Archive old `/DATA` directory
6. ⏳ Update documentation

---

**Decision:** Move V Rising to `/mnt/Data/` for consistency
**Impact:** Low (V Rising not currently running)
**Downtime:** None (service already stopped)
