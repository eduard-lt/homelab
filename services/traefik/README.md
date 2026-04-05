# Traefik Reverse Proxy

## What is Traefik?

Traefik is a modern reverse proxy and load balancer that:
- Automatically discovers services
- Manages SSL certificates (Let's Encrypt)
- Routes traffic based on hostnames
- Provides centralized authentication
- Has built-in dashboard

## Why Use It?

Instead of accessing services via:
- `http://server:8989` (Sonarr)
- `http://server:7878` (Radarr)
- `http://server:5006` (Actual Budget)

Access them via:
- `https://sonarr.yourdomain.com`
- `https://radarr.yourdomain.com`
- `https://actual.yourdomain.com`

**Benefits:**
- ✅ SSL/TLS encryption (HTTPS)
- ✅ No need to remember ports
- ✅ Centralized authentication
- ✅ Professional subdomain access
- ✅ Automatic certificate renewal

## Prerequisites

### 1. Domain Name
You need a domain name pointing to your server:
- **Option A:** Purchase domain ($10-15/year)
- **Option B:** Use free subdomain (DuckDNS, No-IP)
- **Option C:** Local DNS only (no external access)

### 2. DNS Configuration
Point wildcard DNS to your server:
```
A     @              YOUR_SERVER_IP
A     *              YOUR_SERVER_IP
```

Or individual subdomains:
```
A     sonarr         YOUR_SERVER_IP
A     radarr         YOUR_SERVER_IP
A     actual         YOUR_SERVER_IP
```

### 3. Port Forwarding (for external access)
Forward ports 80 and 443 to your server:
```
Port 80  (HTTP)  → YOUR_SERVER_IP:80
Port 443 (HTTPS) → YOUR_SERVER_IP:443
```

## Configuration Options

### Option 1: Full External Access with SSL
- Requires domain name
- Requires Let's Encrypt
- Accessible from anywhere
- Most secure setup

### Option 2: Local Access Only
- Use `.local` domain
- Self-signed certificates or HTTP
- Only accessible on LAN
- Simpler setup

### Option 3: Cloudflare Tunnel
- No port forwarding needed
- Cloudflare handles SSL
- Extra security layer
- Free tier available

## Deployment

See `docker-compose.yml` for configuration.

### Quick Start (Local Only)
```bash
cd /home/eduard/homelab/services/traefik
docker-compose up -d
```

Access dashboard: http://your-server:8080

### With SSL (External)
1. Set up DNS records
2. Configure Let's Encrypt email in .env
3. Deploy Traefik
4. Add labels to other services

## Adding Services to Traefik

Add labels to your docker-compose.yml:

```yaml
services:
  sonarr:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sonarr.rule=Host(`sonarr.yourdomain.com`)"
      - "traefik.http.routers.sonarr.entrypoints=websecure"
      - "traefik.http.routers.sonarr.tls.certresolver=letsencrypt"
      - "traefik.http.services.sonarr.loadbalancer.server.port=8989"
```

## Security

Traefik can add authentication to services:

```yaml
labels:
  - "traefik.http.middlewares.auth.basicauth.users=admin:$$apr1$$..."
  - "traefik.http.routers.service.middlewares=auth"
```

Generate password hash:
```bash
echo $(htpasswd -nb admin yourpassword) | sed -e s/\\$/\\$\\$/g
```

## Status

- ⏳ Traefik configured (ready to deploy)
- ⏳ Needs: Domain name decision
- ⏳ Needs: SSL certificate setup
- ⏳ Needs: Service migration with labels

## Next Steps

1. Decide on domain strategy (local vs external)
2. Deploy Traefik
3. Add labels to existing services
4. Test access via subdomains
5. Enable authentication
