#!/bin/bash
#
# Homelab Backup Script
# Backs up critical configurations and data
#
# Usage: ./backup.sh [daily|weekly|monthly]
#

set -euo pipefail

# Configuration
BACKUP_BASE="/mnt/FastStorage/backups"
HOMELAB_DIR="/home/eduard/homelab"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_TYPE="${1:-daily}"
LOG_FILE="/var/log/homelab-backup.log"

# Retention (days)
DAILY_RETENTION=7
WEEKLY_RETENTION=30
MONTHLY_RETENTION=90

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

# Create backup directories
create_backup_dirs() {
    log "Creating backup directory structure..."
    mkdir -p "$BACKUP_BASE"/{daily,weekly,monthly}/{configs,data,volumes}
}

# Backup homelab configurations (already in git, but belt-and-suspenders)
backup_configs() {
    log "Backing up homelab configurations..."
    local dest="$BACKUP_BASE/$BACKUP_TYPE/configs/homelab_$TIMESTAMP.tar.gz"
    
    tar -czf "$dest" \
        -C /home/eduard \
        homelab \
        --exclude='homelab/backups' \
        --exclude='homelab/*/data' \
        --exclude='*.log' \
        2>/dev/null || warn "Some files couldn't be backed up"
    
    log "Config backup saved to: $dest ($(du -h "$dest" | cut -f1))"
}

# Backup Actual Budget data
backup_actual_budget() {
    if [ -d "/home/eduard/actual/actual-data" ] || [ -d "/home/eduard/homelab/services/actual/data" ]; then
        log "Backing up Actual Budget data..."
        local dest="$BACKUP_BASE/$BACKUP_TYPE/data/actual-budget_$TIMESTAMP.tar.gz"
        
        # Try new location first, fall back to old
        if [ -d "/home/eduard/homelab/services/actual/data" ]; then
            tar -czf "$dest" -C /home/eduard/homelab/services/actual data 2>/dev/null
        elif [ -d "/home/eduard/actual/actual-data" ]; then
            tar -czf "$dest" -C /home/eduard/actual actual-data 2>/dev/null
        fi
        
        if [ -f "$dest" ]; then
            log "Actual Budget backup: $dest ($(du -h "$dest" | cut -f1))"
        fi
    else
        warn "Actual Budget data directory not found"
    fi
}

# Backup Docker volumes
backup_docker_volumes() {
    log "Backing up Docker volumes..."
    local dest_dir="$BACKUP_BASE/$BACKUP_TYPE/volumes"
    
    # Get list of important volumes (excluding large media volumes)
    local volumes=$(docker volume ls -q | grep -v "^_")
    
    for volume in $volumes; do
        log "  Backing up volume: $volume"
        local dest="$dest_dir/${volume}_$TIMESTAMP.tar.gz"
        
        # Use a temporary container to access the volume
        docker run --rm \
            -v "$volume:/volume" \
            -v "$dest_dir:/backup" \
            alpine \
            tar -czf "/backup/$(basename "$dest")" -C /volume . \
            2>/dev/null || warn "Failed to backup volume: $volume"
            
        if [ -f "$dest" ]; then
            log "  Volume $volume backed up ($(du -h "$dest" | cut -f1))"
        fi
    done
}

# Backup game server saves
backup_game_servers() {
    if [ "$BACKUP_TYPE" = "weekly" ] || [ "$BACKUP_TYPE" = "monthly" ]; then
        log "Backing up game server data..."
        local dest_dir="$BACKUP_BASE/$BACKUP_TYPE/data"
        
        # Zomboid
        if [ -d "/mnt/Data/Zomboid" ]; then
            log "  Backing up Project Zomboid..."
            tar -czf "$dest_dir/zomboid_$TIMESTAMP.tar.gz" -C /mnt/Data Zomboid 2>/dev/null || warn "Zomboid backup failed"
        fi
        
        # V Rising
        if [ -d "/mnt/Data/Vrising_crack" ]; then
            log "  Backing up V Rising..."
            tar -czf "$dest_dir/vrising_$TIMESTAMP.tar.gz" -C /mnt/Data Vrising_crack 2>/dev/null || warn "V Rising backup failed"
        fi
        
        # Minecraft
        if [ -d "/mnt/Data/Minecraft" ]; then
            log "  Backing up Minecraft..."
            tar -czf "$dest_dir/minecraft_$TIMESTAMP.tar.gz" -C /mnt/Data Minecraft 2>/dev/null || warn "Minecraft backup failed"
        fi
    fi
}

# Backup Plex metadata (weekly/monthly only)
backup_plex() {
    if [ "$BACKUP_TYPE" = "weekly" ] || [ "$BACKUP_TYPE" = "monthly" ]; then
        if [ -d "/mnt/Data/Plex" ]; then
            log "Backing up Plex metadata..."
            local dest="$BACKUP_BASE/$BACKUP_TYPE/data/plex_metadata_$TIMESTAMP.tar.gz"
            
            # Only backup Library directory, not the media
            tar -czf "$dest" \
                -C /mnt/Data/Plex \
                Library \
                --exclude='Library/Application Support/Plex Media Server/Cache' \
                --exclude='Library/Application Support/Plex Media Server/Logs' \
                2>/dev/null || warn "Plex backup incomplete"
                
            if [ -f "$dest" ]; then
                log "Plex metadata backed up ($(du -h "$dest" | cut -f1))"
            fi
        fi
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."
    
    # Daily backups
    find "$BACKUP_BASE/daily" -type f -name "*.tar.gz" -mtime +$DAILY_RETENTION -delete 2>/dev/null || true
    
    # Weekly backups
    find "$BACKUP_BASE/weekly" -type f -name "*.tar.gz" -mtime +$WEEKLY_RETENTION -delete 2>/dev/null || true
    
    # Monthly backups
    find "$BACKUP_BASE/monthly" -type f -name "*.tar.gz" -mtime +$MONTHLY_RETENTION -delete 2>/dev/null || true
    
    log "Old backups cleaned up"
}

# Generate backup report
generate_report() {
    log "=== Backup Report ==="
    log "Type: $BACKUP_TYPE"
    log "Timestamp: $TIMESTAMP"
    log "Disk usage:"
    du -sh "$BACKUP_BASE"/{daily,weekly,monthly} 2>/dev/null || true
    log "===================="
}

# Main execution
main() {
    log "Starting $BACKUP_TYPE backup..."
    
    create_backup_dirs
    backup_configs
    backup_actual_budget
    backup_docker_volumes
    backup_game_servers
    backup_plex
    cleanup_old_backups
    generate_report
    
    log "Backup completed successfully!"
}

# Run main function
main "$@"
