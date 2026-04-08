#!/bin/bash
#
# CasaOS App Registration Script
#
# Registers docker-compose apps with CasaOS by creating symlinks in /var/lib/casaos/apps/
# This preserves single source of truth while making apps visible to CasaOS.
#
# Usage: sudo ./register-with-casaos.sh [app-name] [compose-path]
#        sudo ./register-with-casaos.sh --all
#

set -e

CASAOS_APPS_DIR="/var/lib/casaos/apps"
HOMELAB_BASE="/home/eduard/homelab"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

register_app() {
    local app_name="$1"
    local compose_path="$2"
    
    log_info "Registering app: $app_name"
    
    # Validate compose file exists
    if [[ ! -f "$compose_path" ]]; then
        log_error "Compose file not found: $compose_path"
        return 1
    fi
    
    # Create app directory
    local app_dir="$CASAOS_APPS_DIR/$app_name"
    mkdir -p "$app_dir"
    
    # Create symlink to compose file
    local symlink_path="$app_dir/docker-compose.yml"
    
    if [[ -L "$symlink_path" ]]; then
        log_warn "Symlink already exists: $symlink_path"
        # Remove and recreate
        rm "$symlink_path"
    elif [[ -f "$symlink_path" ]]; then
        log_warn "Regular file exists, backing up: $symlink_path"
        mv "$symlink_path" "$symlink_path.backup.$(date +%s)"
    fi
    
    # Create symlink
    ln -s "$compose_path" "$symlink_path"
    
    # Set permissions
    chown -h root:root "$symlink_path"
    chmod 755 "$app_dir"
    
    log_info "✓ Registered: $app_name → $compose_path"
    
    return 0
}

register_all_apps() {
    log_info "Scanning for all docker-compose apps in $HOMELAB_BASE"
    
    local count=0
    
    # Media apps
    for app in sonarr radarr lidarr readarr prowlarr overseerr tautulli qbittorrent; do
        local compose_file="$HOMELAB_BASE/media/$app/docker-compose.yml"
        if [[ -f "$compose_file" ]]; then
            register_app "$app" "$compose_file" && ((count++))
        fi
    done
    
    # Monitoring apps
    for app in grafana netdata; do
        local compose_file="$HOMELAB_BASE/monitoring/$app/docker-compose.yml"
        if [[ -f "$compose_file" ]]; then
            register_app "$app" "$compose_file" && ((count++))
        fi
    done
    
    # Services
    register_app "actual-budget" "$HOMELAB_BASE/services/actual/docker-compose.yml" && ((count++))
    register_app "traefik" "$HOMELAB_BASE/services/traefik/docker-compose.yml" && ((count++))
    register_app "discord-bot" "$HOMELAB_BASE/services/discord-bot/docker-compose.yml" && ((count++))
    
    log_info "Registered $count apps"
}

show_help() {
    cat << EOF
Usage: sudo $0 [OPTIONS]

Register docker-compose apps with CasaOS

OPTIONS:
    --all                   Register all apps in homelab directory
    --app NAME PATH         Register specific app
    --unregister NAME       Remove app registration
    --list                  List registered apps
    --help                  Show this help

EXAMPLES:
    # Register all apps
    sudo $0 --all
    
    # Register specific app
    sudo $0 --app actual-budget /home/eduard/homelab/services/actual/docker-compose.yml
    
    # Unregister app
    sudo $0 --unregister actual-budget
    
    # List all registered
    sudo $0 --list

EOF
}

unregister_app() {
    local app_name="$1"
    local app_dir="$CASAOS_APPS_DIR/$app_name"
    
    if [[ ! -d "$app_dir" ]]; then
        log_error "App not registered: $app_name"
        return 1
    fi
    
    log_info "Unregistering: $app_name"
    
    # Check if it's a symlink (ours) or regular file (CasaOS managed)
    if [[ -L "$app_dir/docker-compose.yml" ]]; then
        log_info "Removing symlink..."
        rm "$app_dir/docker-compose.yml"
    else
        log_warn "Not a symlink, backing up instead of deleting"
        mv "$app_dir" "$app_dir.backup.$(date +%s)"
    fi
    
    # Remove directory if empty
    rmdir "$app_dir" 2>/dev/null || log_warn "Directory not empty: $app_dir"
    
    log_info "✓ Unregistered: $app_name"
}

list_registered() {
    log_info "Registered apps in $CASAOS_APPS_DIR:"
    echo ""
    
    for app_dir in "$CASAOS_APPS_DIR"/*; do
        if [[ -d "$app_dir" ]]; then
            local app_name=$(basename "$app_dir")
            local compose_file="$app_dir/docker-compose.yml"
            
            if [[ -L "$compose_file" ]]; then
                local target=$(readlink "$compose_file")
                echo "  $app_name → $target (symlink)"
            elif [[ -f "$compose_file" ]]; then
                echo "  $app_name (managed by CasaOS)"
            else
                echo "  $app_name (no compose file)"
            fi
        fi
    done
}

# Main logic
case "${1:-}" in
    --all)
        register_all_apps
        log_info "Done! Restart CasaOS to see changes: sudo systemctl restart casaos"
        ;;
    --app)
        if [[ -z "$2" || -z "$3" ]]; then
            log_error "Usage: $0 --app NAME PATH"
            exit 1
        fi
        register_app "$2" "$3"
        log_info "Done! Restart CasaOS to see changes: sudo systemctl restart casaos"
        ;;
    --unregister)
        if [[ -z "$2" ]]; then
            log_error "Usage: $0 --unregister NAME"
            exit 1
        fi
        unregister_app "$2"
        ;;
    --list)
        list_registered
        ;;
    --help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac

exit 0
