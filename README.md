# Homelab Configuration Repository

> **Last Updated:** 2026-04-05  
> **Purpose:** Version-controlled infrastructure for personal homelab

## Overview

This repository contains Docker Compose configurations and documentation for my homelab setup, running a comprehensive media server stack, game servers, monitoring tools, and various services.

## 🏗️ Infrastructure

### Storage
- **HDD (7.3TB):** `/mnt/Data` - Media files, game data, backups
- **NVMe (458GB):** `/mnt/FastStorage` - Performance-sensitive services

### Network
Services are organized into separate Docker networks for security and isolation:
- `media_net` - Media server stack
- `gaming_net` - Game servers
- `monitoring_net` - Monitoring tools
- `services_net` - General services

## 📦 Services

### Media Stack (`/media/`)
- **Plex** - Media server
- **Sonarr** - TV show management
- **Radarr** - Movie management
- **Lidarr** - Music management
- **Readarr** - Book management
- **Prowlarr** - Indexer manager
- **Overseerr** - Media request management
- **Tautulli** - Plex monitoring
- **qBittorrent** - Download client

### Gaming (`/gaming/`)
- **Crafty Controller** - Minecraft server management (Port: 8112)
- **Project Zomboid** - Multiplayer survival server
- **V Rising** - Vampire survival server

### Monitoring (`/monitoring/`)
- **Netdata** - Real-time system monitoring (Port: 19999)
- **Grafana** - Metrics visualization (Port: 3003)

### Services (`/services/`)
- **Portainer** - Docker management UI (Port: 9000)
- **PhotoPrism** - Photo management (Port: 2342)
- **Homebridge** - HomeKit integration
- **Actual Budget** - Personal finance (Port: 5006)
- **Vaultwarden** - Password manager

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Linux host with appropriate storage mounted
- Git installed

### Initial Setup

1. **Clone this repository:**
   ```bash
   git clone <your-github-repo-url> ~/homelab
   cd ~/homelab
   ```

2. **Create environment files:**
   Each service directory contains a `.env.template` file. Copy and customize:
   ```bash
   cd gaming/zomboid
   cp .env.template .env
   nano .env  # Edit with your passwords
   ```

3. **Start services:**
   ```bash
   cd <service-directory>
   docker-compose up -d
   ```

## 🔒 Security

### Environment Variables
All sensitive data (passwords, API keys) are stored in `.env` files that are **NOT** committed to git. 

- ✅ `.env.template` files are committed (with placeholder values)
- ❌ `.env` files are in `.gitignore`

### Before First Commit
Ensure you've created `.env` files from templates before deploying services.

## 📁 Directory Structure

```
homelab/
├── media/           # Media server stack configs
├── gaming/          # Game server configs
│   └── zomboid/     # Project Zomboid server
├── monitoring/      # Monitoring tool configs
├── services/        # General service configs
├── docs/            # Documentation and notes
├── .gitignore       # Excludes secrets and data
└── README.md        # This file
```

## 🔧 Maintenance

### Updating Services
```bash
cd <service-directory>
docker-compose pull
docker-compose up -d
```

### Viewing Logs
```bash
docker-compose logs -f <service-name>
```

### Backup Strategy
- **Configurations:** Versioned in this Git repository
- **Data:** Separate backup scripts for Docker volumes (see `/docs/`)

## 📊 Port Mappings

| Service | Port(s) | Protocol | Purpose |
|---------|---------|----------|---------|
| Portainer | 9000, 9443 | TCP | Docker management |
| Grafana | 3003 | TCP | Metrics dashboard |
| Netdata | 19999 | TCP | System monitoring |
| PhotoPrism | 2342 | TCP | Photo management |
| Actual Budget | 5006 | TCP | Finance management |
| Crafty | 8112, 8111 | TCP | Minecraft management |
| Minecraft | 19132, 25500-25600 | TCP/UDP | Game servers |
| Plex | Various | TCP | Media streaming |
| qBittorrent | 8181 | TCP | Download client |
| Sonarr | 8989 | TCP | TV management |
| Radarr | 7878 | TCP | Movie management |
| Lidarr | 8686 | TCP | Music management |
| Readarr | 8787 | TCP | Book management |
| Prowlarr | 9696 | TCP | Indexer manager |
| Overseerr | 5055 | TCP | Request management |
| Tautulli | 7979 | TCP | Plex stats |
| Zomboid | 16261-16262, 27015 | UDP/TCP | Game server |
| V Rising | 9876-9877 | UDP | Game server |

## 🐛 Troubleshooting

### Container won't start
1. Check logs: `docker-compose logs <service>`
2. Verify `.env` file exists and is properly formatted
3. Ensure storage paths exist and have correct permissions

### Network issues
1. Check if network exists: `docker network ls`
2. Recreate network: `docker network create <network-name>`

### Storage path issues
- Verify mounts exist: `df -h | grep /mnt`
- Check permissions: `ls -la /mnt/Data`

## 📝 Notes

- **Storage Paths:** Standardized to use `/mnt/Data` consistently
- **Restart Policies:** Most services use `unless-stopped`
- **Resource Limits:** Some services have memory limits configured
- **Networks:** Services isolated by function for security

## 🔄 Git Workflow

### Making Changes
```bash
# Make changes to configs
cd ~/homelab
git status
git add <changed-files>
git commit -m "Description of changes"
git push origin main
```

### Restoring from Git
```bash
git clone <your-github-repo-url> ~/homelab
cd ~/homelab
# Create .env files from templates
# Start services
```

## 📚 Additional Documentation

See `/docs/` directory for:
- Security audit reports
- Troubleshooting guides
- Service-specific notes
- Backup procedures

## ⚠️ Important

- **Never commit `.env` files** - They contain sensitive passwords
- **Test changes** in development before applying to production
- **Keep backups** of important data separate from this repo
- **Document changes** when modifying configurations

## 📞 Support

For issues or questions, check:
1. Service logs: `docker-compose logs`
2. Documentation in `/docs/`
3. Original service documentation

---

**Repository Structure:** Infrastructure as Code  
**Backup Strategy:** Git for configs, separate scripts for data  
**Recovery:** Clone repo + restore data volumes
