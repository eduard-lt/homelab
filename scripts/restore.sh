#!/bin/bash
#
# Homelab Restore Script
# Restores configurations and data from backups
#
# Usage: ./restore.sh [config|volume|game|plex|all] [backup_file]
#

set -euo pipefail

# Configuration
BACKUP_BASE="/mnt/FastStorage/backups"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# List available backups
list_backups() {
    local type=$1
    info "Available $type backups:"
    find "$BACKUP_BASE" -name "*$type*.tar.gz" -type f -printf "%T@ %p\n" | sort -rn | head -10 | while read timestamp file; do
        echo "  $(date -d @${timestamp%.*} '+%Y-%m-%d %H:%M') - $(basename "$file") ($(du -h "$file" | cut -f1))"
    done
}

# Restore homelab configs
restore_config() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        list_backups "homelab"
        error "Backup file not found: $backup_file"
    fi
    
    log "Restoring homelab configuration from: $backup_file"
    warn "This will overwrite existing configurations. Continue? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        error "Restore cancelled"
    fi
    
    tar -xzf "$backup_file" -C /home/eduard/
    log "Configuration restored successfully"
}

# Restore Docker volume
restore_volume() {
    local backup_file=$1
    local volume_name=$(basename "$backup_file" | sed 's/_[0-9]*\.tar\.gz//')
    
    if [ ! -f "$backup_file" ]; then
        list_backups "volume"
        error "Backup file not found: $backup_file"
    fi
    
    log "Restoring Docker volume: $volume_name"
    
    # Create volume if it doesn't exist
    docker volume create "$volume_name" 2>/dev/null || true
    
    # Restore data
    docker run --rm \
        -v "$volume_name:/volume" \
        -v "$(dirname "$backup_file"):/backup" \
        alpine \
        tar -xzf "/backup/$(basename "$backup_file")" -C /volume
    
    log "Volume $volume_name restored successfully"
}

# Restore game server data
restore_game() {
    local backup_file=$1
    local game=$(basename "$backup_file" | cut -d'_' -f1)
    
    if [ ! -f "$backup_file" ]; then
        list_backups "zomboid\|vrising\|minecraft"
        error "Backup file not found: $backup_file"
    fi
    
    log "Restoring $game data from: $backup_file"
    warn "This will overwrite existing game data. Continue? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        error "Restore cancelled"
    fi
    
    tar -xzf "$backup_file" -C /mnt/Data/
    log "Game data restored successfully"
}

# Show usage
usage() {
    cat << EOF
Usage: $0 <restore_type> [backup_file]

Restore Types:
  config          Restore homelab configurations
  volume          Restore a Docker volume
  game            Restore game server data
  actual          Restore Actual Budget data
  list            List available backups

Examples:
  $0 list
  $0 config /mnt/FastStorage/backups/daily/configs/homelab_20260405_120000.tar.gz
  $0 volume /mnt/FastStorage/backups/daily/volumes/portainer_20260405_120000.tar.gz
  $0 game /mnt/FastStorage/backups/weekly/data/zomboid_20260405_120000.tar.gz

EOF
    exit 1
}

# Main execution
main() {
    if [ $# -lt 1 ]; then
        usage
    fi
    
    case "$1" in
        list)
            echo "=== Available Backups ==="
            echo
            list_backups "homelab"
            echo
            list_backups "actual"
            echo
            list_backups "volume"
            echo
            list_backups "zomboid\|vrising\|minecraft"
            ;;
        config)
            [ $# -lt 2 ] && usage
            restore_config "$2"
            ;;
        volume)
            [ $# -lt 2 ] && usage
            restore_volume "$2"
            ;;
        game)
            [ $# -lt 2 ] && usage
            restore_game "$2"
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
