# Discord Notifications Setup

## Webhook URL
Store webhook securely in services that need it.

## 1. Overseerr - Media Request Notifications

**Setup via Web UI:**
1. Access Overseerr: `https://100.70.106.23:8443` (navigate to Overseerr)
2. Go to **Settings** → **Notifications** → **Discord**
3. Enable Discord notifications
4. Webhook URL: `https://discord.com/api/webhooks/1491141708472385641/qVjC2FhBtnEFEVdxtFhrfaJmu5myEbj_47omWfgiYRgOs_Jk2fFjjgHu4p7qMxm4UPOW`
5. Select notification types:
   - ✅ Media Requested
   - ✅ Media Approved
   - ✅ Media Available
   - ✅ Media Failed
   - ✅ Issue Created
6. Test and Save

## 2. Grafana - System Monitoring Alerts

**Configure via Web UI:**
1. Access Grafana: `https://100.70.106.23:8443` (navigate to Grafana)
2. Go to **Alerting** → **Contact points**
3. Add new contact point:
   - Name: `Discord Homelab`
   - Integration: `Webhook`
   - URL: `https://discord.com/api/webhooks/1491141708472385641/qVjC2FhBtnEFEVdxtFhrfaJmu5myEbj_47omWfgiYRgOs_Jk2fFjjgHu4p7qMxm4UPOW`
   - HTTP Method: `POST`
   - Content-Type: `application/json`

**Alert Rules to Create:**
- High CPU usage (>80% for 5 minutes)
- High memory usage (>85%)
- Low disk space (<10% free)
- Container down/unhealthy
- Docker daemon issues

## 3. Netdata - Real-time Health Monitoring

**Configured via health_alarm_notify.conf:**
- Already configured (see services/netdata/health_alarm_notify.conf)
- Alerts for CPU, memory, disk, network issues
- Real-time notifications within 10 seconds

## 4. Discord Bot (Optional)

Interactive bot for homelab management coming soon!
- Start/stop services
- View service status
- Check system resources
- Manage media downloads

## Notification Types

### Overseerr
- 🎬 New movie/TV show requested
- ✅ Request approved/available
- ❌ Download failed
- 🔧 Issue reported

### Grafana
- ⚠️ System resource alerts
- 🔴 Critical service down
- 📊 Performance warnings

### Netdata
- 🚨 Real-time health alerts
- 💾 Storage warnings
- 🌐 Network issues
- 🔥 Temperature alerts

