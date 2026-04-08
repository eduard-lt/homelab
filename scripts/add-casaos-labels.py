#!/usr/bin/env python3
"""
CasaOS Label Injection Script

Adds CasaOS management labels to docker-compose.yml files while preserving
existing labels (Traefik, resource limits, etc.)

Usage:
    python3 add-casaos-labels.py --file path/to/docker-compose.yml --dry-run
    python3 add-casaos-labels.py --scan /home/eduard/homelab/ --apply
"""

import argparse
import sys
import os
import uuid
import yaml
from pathlib import Path
from typing import Dict, List, Any, Optional

# CasaOS icon URLs from official app store
ICON_URLS = {
    'actual': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/ActualBudget/icon.png',
    'sonarr': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Sonarr/icon.png',
    'radarr': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Radarr/icon.png',
    'lidarr': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Lidarr/icon.png',
    'readarr': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Readarr/icon.png',
    'prowlarr': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Prowlarr/icon.png',
    'overseerr': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Overseerr/icon.png',
    'tautulli': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Tautulli/icon.png',
    'qbittorrent': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/qBittorrent/icon.png',
    'grafana': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Grafana/icon.png',
    'netdata': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Netdata/icon.png',
    'traefik': 'https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@main/Apps/Traefik/icon.png',
}

# App descriptions
DESCRIPTIONS = {
    'actual': 'Personal finance and budgeting tool',
    'sonarr': 'TV series management and automation',
    'radarr': 'Movie collection manager and downloader',
    'lidarr': 'Music collection manager',
    'readarr': 'Book and audiobook collection manager',
    'prowlarr': 'Indexer manager for *arr apps',
    'overseerr': 'Media request and discovery platform',
    'tautulli': 'Plex monitoring and tracking',
    'qbittorrent': 'BitTorrent client with web interface',
    'grafana': 'Metrics visualization and dashboards',
    'netdata': 'Real-time system monitoring',
    'traefik': 'Modern HTTP reverse proxy and load balancer',
    'discord-bot': 'Custom Discord bot for server management',
}

# Default ports for apps (extracted from compose files)
DEFAULT_PORTS = {
    'actual': 5006,
    'sonarr': 8989,
    'radarr': 7878,
    'lidarr': 8686,
    'readarr': 8787,
    'prowlarr': 9696,
    'overseerr': 5055,
    'tautulli': 8181,
    'qbittorrent': 8081,
    'grafana': 3003,
    'netdata': 19999,
    'traefik': 9080,  # Dashboard
}

# LAN IP for CasaOS (from environment or default)
# Note: CasaOS needs LAN IP for click-through, not Tailscale IP
LAN_IP = os.getenv('LAN_IP', '172.26.1.31')


class CasaOSLabeler:
    """Add CasaOS labels to docker-compose files"""
    
    def __init__(self, dry_run: bool = True, verbose: bool = True):
        self.dry_run = dry_run
        self.verbose = verbose
        self.changes = []
    
    def log(self, message: str, level: str = "INFO"):
        """Print log message if verbose"""
        if self.verbose:
            print(f"[{level}] {message}")
    
    def extract_port(self, ports: List) -> Optional[int]:
        """Extract main port from docker-compose ports config"""
        if not ports:
            return None
        
        # Handle both list and dict formats
        if isinstance(ports, list):
            first_port = ports[0]
            if isinstance(first_port, str):
                # Format: "8080:80" or "127.0.0.1:8080:80" or "${PORT:-5006}:5006"
                # Clean up environment variable syntax
                port_str = first_port.replace('${', '').replace('}', '')
                # Split and get the last numeric part before :
                parts = port_str.split(':')
                for part in parts:
                    # Try to extract number, skip non-numeric parts
                    try:
                        # Handle "PORT-5006" -> "5006"
                        if '-' in part:
                            part = part.split('-')[1]
                        port = int(part)
                        if 1 <= port <= 65535:  # Valid port range
                            return port
                    except (ValueError, IndexError):
                        continue
            elif isinstance(first_port, dict):
                return int(first_port.get('target', first_port.get('published', 0)))
        
        return None
    
    def generate_casaos_labels(self, service_name: str, service_config: Dict, 
                               container_name: str = None) -> List[str]:
        """Generate CasaOS labels for a service"""
        
        # Use container name or service name
        app_name = container_name or service_name
        
        # Extract port from existing config
        port = None
        if 'ports' in service_config:
            port = self.extract_port(service_config['ports'])
        
        # Fallback to known defaults
        if not port:
            port = DEFAULT_PORTS.get(app_name.lower().replace('-', '').replace('_', ''))
        
        # Get icon and description
        app_key = app_name.lower().replace('-', '').replace('_', '')
        icon = ICON_URLS.get(app_key, '')
        desc = DESCRIPTIONS.get(app_key, f'{app_name} service')
        
        # Generate unique ID
        custom_id = str(uuid.uuid4())
        
        # Build labels
        labels = [
            "casaos=casaos",
            f"custom_id={custom_id}",
            "origin=local",
            f"name={app_name}",
            f"desc={desc}",
            "protocol=http",
            "show_env=casaos",
            "io.casaos.v1.app.store.id=0",
        ]
        
        # Add icon if available
        if icon:
            labels.append(f"icon={icon}")
        
        # Add web/host if port available
        if port:
            labels.append(f"web={port}")
            labels.append(f"host={LAN_IP}:{port}")
        
        return labels
    
    def add_labels_to_service(self, service_name: str, service_config: Dict) -> bool:
        """Add CasaOS labels to a service configuration"""
        
        # Get container name
        container_name = service_config.get('container_name', service_name)
        
        # Check if labels already exist
        existing_labels = service_config.get('labels', [])
        
        # Convert dict labels to list format
        if isinstance(existing_labels, dict):
            existing_labels = [f"{k}={v}" for k, v in existing_labels.items()]
        elif existing_labels is None:
            existing_labels = []
        
        # Check if CasaOS labels already present
        has_casaos = any('casaos' in str(label) for label in existing_labels)
        
        if has_casaos:
            self.log(f"Service '{service_name}' already has CasaOS labels, skipping", "WARNING")
            return False
        
        # Generate new CasaOS labels
        casaos_labels = self.generate_casaos_labels(service_name, service_config, container_name)
        
        # Combine with existing labels
        all_labels = existing_labels + casaos_labels
        
        # Update service config
        service_config['labels'] = all_labels
        
        self.log(f"Added {len(casaos_labels)} CasaOS labels to '{service_name}'")
        self.changes.append(f"  - {service_name}: +{len(casaos_labels)} labels")
        
        return True
    
    def process_compose_file(self, file_path: Path) -> bool:
        """Process a single docker-compose.yml file"""
        
        self.log(f"Processing: {file_path}")
        
        try:
            # Read compose file
            with open(file_path, 'r') as f:
                compose_data = yaml.safe_load(f)
            
            if not compose_data or 'services' not in compose_data:
                self.log(f"No services found in {file_path}", "WARNING")
                return False
            
            # Process each service
            modified = False
            for service_name, service_config in compose_data['services'].items():
                if self.add_labels_to_service(service_name, service_config):
                    modified = True
            
            if not modified:
                self.log(f"No changes needed for {file_path}")
                return False
            
            # Write back (if not dry-run)
            if not self.dry_run:
                # Backup original
                backup_path = file_path.with_suffix('.yml.backup')
                if not backup_path.exists():
                    with open(backup_path, 'w') as f:
                        yaml.dump(compose_data, f, default_flow_style=False, sort_keys=False)
                
                # Write updated file
                with open(file_path, 'w') as f:
                    yaml.dump(compose_data, f, default_flow_style=False, sort_keys=False, indent=2)
                
                self.log(f"✓ Updated: {file_path}", "SUCCESS")
            else:
                self.log(f"[DRY-RUN] Would update: {file_path}")
            
            return True
            
        except Exception as e:
            self.log(f"Error processing {file_path}: {e}", "ERROR")
            return False
    
    def scan_directory(self, base_path: Path) -> List[Path]:
        """Scan directory for docker-compose.yml files"""
        
        compose_files = []
        
        # Scan services, media, monitoring directories
        for subdir in ['services', 'media', 'monitoring']:
            subdir_path = base_path / subdir
            if subdir_path.exists():
                for compose_file in subdir_path.rglob('docker-compose.yml'):
                    compose_files.append(compose_file)
        
        return sorted(compose_files)
    
    def print_summary(self):
        """Print summary of changes"""
        if self.changes:
            print("\n" + "=" * 50)
            print("SUMMARY OF CHANGES")
            print("=" * 50)
            for change in self.changes:
                print(change)
            print("=" * 50)
        else:
            print("\n[INFO] No changes made")


def main():
    parser = argparse.ArgumentParser(
        description='Add CasaOS labels to docker-compose files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Dry-run on single file
  %(prog)s --file /home/eduard/homelab/services/actual/docker-compose.yml --dry-run
  
  # Apply to single file
  %(prog)s --file /home/eduard/homelab/services/actual/docker-compose.yml --apply
  
  # Scan and apply to all files
  %(prog)s --scan /home/eduard/homelab --apply
  
  # Scan with dry-run (default)
  %(prog)s --scan /home/eduard/homelab
        """
    )
    
    parser.add_argument('--file', type=Path, help='Path to single docker-compose.yml file')
    parser.add_argument('--scan', type=Path, help='Scan directory for docker-compose files')
    parser.add_argument('--dry-run', action='store_true', default=True, help='Show what would be changed (default)')
    parser.add_argument('--apply', action='store_true', help='Actually apply changes')
    parser.add_argument('--quiet', action='store_true', help='Minimal output')
    
    args = parser.parse_args()
    
    # Validate arguments
    if not args.file and not args.scan:
        parser.error("Must specify either --file or --scan")
    
    # Determine dry-run mode
    dry_run = not args.apply
    verbose = not args.quiet
    
    # Create labeler
    labeler = CasaOSLabeler(dry_run=dry_run, verbose=verbose)
    
    if dry_run and verbose:
        print("[DRY-RUN MODE] No files will be modified. Use --apply to make changes.\n")
    
    # Process files
    if args.file:
        if not args.file.exists():
            print(f"Error: File not found: {args.file}", file=sys.stderr)
            return 1
        
        labeler.process_compose_file(args.file)
    
    elif args.scan:
        if not args.scan.exists():
            print(f"Error: Directory not found: {args.scan}", file=sys.stderr)
            return 1
        
        compose_files = labeler.scan_directory(args.scan)
        
        if not compose_files:
            print(f"No docker-compose.yml files found in {args.scan}")
            return 0
        
        print(f"Found {len(compose_files)} docker-compose files\n")
        
        for compose_file in compose_files:
            labeler.process_compose_file(compose_file)
            print()  # Blank line between files
    
    # Print summary
    labeler.print_summary()
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
