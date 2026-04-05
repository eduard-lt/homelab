# Monitoring Setup Review

**Date:** 2026-04-05  
**Systems:** Netdata v1.45.3, Grafana 11.1.5

## Current State

### Netdata (Port 19999)
**Status:** ✅ Running, Healthy  
**Container Age:** 23 months  
**Uptime:** 33 minutes (recent restart)

**What's Monitored:**
- ✅ System metrics (CPU, RAM, disk, network)
- ✅ Docker containers (per-container metrics)
- ✅ Disk I/O and space
- ✅ Network traffic
- ✅ System processes

**Alarms:**
- Normal: 245
- Warning: 1 ⚠️
- Critical: 0

**Gaps:**
- No custom alerts configured
- No notification channels set up
- Running in default configuration
- No authentication (anyone on network can access)

### Grafana (Port 3003)
**Status:** ✅ Running, Healthy  
**Version:** 11.1.5  
**Container Age:** 14 months

**What's Monitored:**
- Unknown (no accessible config - need to check dashboards)
- Likely minimal or default setup
- No data sources visible from API

**Gaps:**
- Unknown configuration (needs login to verify)
- No known alert rules
- No notification channels configured
- Unclear what dashboards exist

## Issues Identified

### High Priority
1. **No Alerting** - Monitoring data exists but no notifications
2. **No Authentication** - Netdata accessible without auth
3. **No Alert Channels** - Nowhere to send alerts
4. **Unknown Grafana State** - Need to audit dashboards/datasources

### Medium Priority
5. **Old Containers** - 14-23 months old, should update
6. **No Centralized Logs** - Just metrics, no log aggregation
7. **No Prometheus** - Limited metrics retention
8. **No Backup** - Grafana dashboards not backed up

### Low Priority
9. **No SSL** - Plain HTTP access
10. **Port Exposure** - Directly exposed, not behind reverse proxy

## Recommendations

### Phase 1: Immediate (Alerts & Notifications)
1. **Set up Netdata alert notifications**
   - Configure Discord/Email/Slack webhooks
   - Enable critical alerts (disk space, container down, high CPU/memory)

2. **Secure Netdata**
   - Add authentication
   - Restrict to localhost or VPN only

3. **Audit Grafana**
   - Log in and document existing dashboards
   - Configure data sources (Netdata, future Prometheus)
   - Set up notification channels

### Phase 2: Enhanced Monitoring
4. **Add Prometheus**
   - Better metrics retention
   - More flexible querying
   - Industry standard for containers

5. **Create Unified Dashboard**
   - System overview
   - Per-service metrics
   - Storage usage trends
   - Network traffic

6. **Alert Rules**
   - Disk space < 10%
   - Container stopped unexpectedly
   - CPU > 90% for 5 minutes
   - Memory > 90% for 5 minutes
   - Docker daemon issues
   - Backup failures

### Phase 3: Advanced
7. **Log Aggregation**
   - Add Loki for centralized logging
   - Correlate logs with metrics

8. **Application Metrics**
   - Plex stats
   - Download queue status
   - Game server player counts

## Alert Configuration Plan

### Critical Alerts (Immediate Notification)
- Disk space < 5%
- Container crash/restart loop
- Docker daemon down
- Backup failed
- System load > 20 (sustained)

### Warning Alerts (Daily Digest)
- Disk space < 15%
- Container high memory (>80%)
- High CPU sustained (>80% for 10 min)
- Certificate expiring (< 7 days)

### Info Alerts (Weekly Summary)
- Container updates available
- Disk space trends
- Resource usage patterns

## Notification Channels

### Recommended Setup
1. **Discord Webhook** (Free, easy)
   - Critical alerts: @mention
   - Warnings: Regular message
   - Daily/weekly summaries

2. **Email** (Backup channel)
   - Critical alerts only
   - Uses SMTP

3. **Optional: Telegram/Slack**
   - If preferred over Discord

## Monitoring Gaps to Fill

### Currently NOT Monitored
- ❌ Backup success/failure status
- ❌ SSL certificate expiration
- ❌ Service-specific health (Plex, *arr apps)
- ❌ Application logs
- ❌ Security events
- ❌ Network intrusion attempts

### Nice to Have
- Game server player counts
- Media library growth trends
- Download speeds and ratios
- Service update availability
- Container vulnerability scanning

## Implementation Priority

1. ✅ **This review** (COMPLETE)
2. ⏳ **Configure Netdata alerts** (NEXT)
3. ⏳ **Set up Discord webhook**
4. ⏳ **Create Grafana dashboards**
5. ⏳ **Test alert delivery**
6. ⏳ **Document alert playbooks**

## Next Steps

1. Create Discord webhook for notifications
2. Configure Netdata alert.conf
3. Set up critical alerts
4. Test alert delivery
5. Create Grafana unified dashboard
6. Document alert response procedures

---

**Status:** Monitoring infrastructure exists but needs configuration  
**Effort:** 2-3 hours to set up alerts and dashboards  
**Impact:** HIGH - Early detection of issues
