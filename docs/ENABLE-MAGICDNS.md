# Enable MagicDNS - Step-by-Step Guide

**Goal:** Make `budget.thedarkurge.li-rattlesnake.ts.net` work on your devices!

---

## ✅ **Server Side (Already Done!)**

Your server is already configured:
- ✅ MagicDNS enabled: `li-rattlesnake.ts.net`
- ✅ Hostname: `thedarkurge.li-rattlesnake.ts.net`
- ✅ SSL certificates obtained

**No server changes needed!**

---

## 📱 **Step 1: Enable MagicDNS in Tailscale Admin Console**

### Go to Tailscale Admin Panel

1. Open browser and go to: **https://login.tailscale.com/admin/dns**
2. Log in with your Tailscale account

### Enable MagicDNS

Look for the **"MagicDNS"** section:

```
┌─────────────────────────────────────┐
│ MagicDNS                  [Toggle] │
│                                     │
│ Registers DNS names for devices     │
│ in your network                     │
└─────────────────────────────────────┘
```

**Make sure it's ON (blue/enabled)**

### Enable HTTPS Certificates

In the same DNS settings page, look for:

```
┌─────────────────────────────────────┐
│ HTTPS Certificates        [Toggle] │
│                                     │
│ Issue certificates for your         │
│ tailnet devices                     │
└─────────────────────────────────────┘
```

**Make sure it's ON (blue/enabled)**

### Check Global Nameservers (Optional)

Scroll down to **"Global nameservers"**:

```
┌─────────────────────────────────────┐
│ Global nameservers                  │
│                                     │
│ Add nameservers:                    │
│ [1.1.1.1] [Add]                    │
│                                     │
│ Current:                            │
│ • 1.1.1.1                          │
│ • 1.0.0.1                          │
└─────────────────────────────────────┘
```

**Add some public DNS** (like 1.1.1.1, 8.8.8.8) if not already there.

---

## 📱 **Step 2: Configure iPhone**

### Open Tailscale App

1. Open the **Tailscale** app on your iPhone
2. Make sure you're connected (should show green checkmark)

### Enable DNS Settings

**Tap the three dots (⋯)** or **Settings icon**

Look for one of these options:
- **"DNS Settings"**
- **"Use Tailscale DNS"**
- **"Accept DNS"**
- **"Override local DNS"**

### Enable the Option

```
┌─────────────────────────────────────┐
│ DNS Settings                        │
│                                     │
│ ☑️ Use Tailscale DNS                │
│ ☑️ Accept DNS                       │
│ ☐ Use custom nameservers            │
└─────────────────────────────────────┘
```

**Make sure it's CHECKED (✅)**

### Reconnect (Important!)

1. **Disconnect** from Tailscale (turn it off)
2. Wait 5 seconds
3. **Reconnect** (turn it back on)

This forces the iPhone to pick up the new DNS settings.

---

## 💻 **Step 3: Configure Windows PC**

### Open Tailscale

1. Click the **Tailscale icon** in system tray (bottom-right)
2. Make sure you're connected

### Check DNS Settings

**Right-click Tailscale icon** → **Settings** or **Preferences**

Look for:
- **"Use Tailscale DNS settings"** ✅
- **"Accept DNS"** ✅
- **"Override local DNS"** ✅

### Alternative: Check via Command Line

Open **PowerShell** or **Command Prompt**:

```powershell
# Check Tailscale status
tailscale status

# Check if you can resolve the hostname
nslookup thedarkurge.li-rattlesnake.ts.net

# Should return: 100.70.106.23
```

---

## 🧪 **Step 4: Test DNS Resolution**

### Test 1: Ping the Server

**On iPhone (using Ping app or Network Utility):**
```
ping thedarkurge.li-rattlesnake.ts.net
```

**Expected result:**
```
PING thedarkurge.li-rattlesnake.ts.net (100.70.106.23)
64 bytes from 100.70.106.23: icmp_seq=1 ttl=64 time=5 ms
```

**On Windows PC:**
```powershell
ping thedarkurge.li-rattlesnake.ts.net
```

**Expected result:**
```
Pinging thedarkurge.li-rattlesnake.ts.net [100.70.106.23]
Reply from 100.70.106.23: bytes=32 time=5ms TTL=64
```

### Test 2: Resolve Subdomain

**On iPhone (Safari address bar):**
```
Just type: thedarkurge.li-rattlesnake.ts.net
```

**On Windows PC (PowerShell):**
```powershell
nslookup budget.thedarkurge.li-rattlesnake.ts.net
```

**Expected result:**
```
Server:  100.100.100.100
Address: 100.100.100.100

Name:    budget.thedarkurge.li-rattlesnake.ts.net
Address: 100.70.106.23
```

---

## 🎯 **Step 5: Access Your Services!**

Once DNS is working, try these URLs:

### Traefik Dashboard

**OLD:** `http://100.70.106.23:9080/dashboard/`  
**NEW:** `http://traefik.thedarkurge.li-rattlesnake.ts.net:9080/dashboard/`

### Actual Budget

**OLD:** `https://100.70.106.23:8443` (certificate warning)  
**NEW:** `https://budget.thedarkurge.li-rattlesnake.ts.net:8443` (no warning!)

**Benefits:**
- ✅ No certificate warnings!
- ✅ Clean, memorable URLs
- ✅ SSL matches the hostname
- ✅ Looks professional!

---

## 🐛 **Troubleshooting**

### "Server Not Found" - Still can't resolve

**Problem:** DNS still not working after enabling

**Solutions:**

1. **Force reconnect to Tailscale:**
   - Turn off Tailscale
   - Wait 10 seconds
   - Turn on Tailscale
   - Try again

2. **Check DNS is really enabled:**
   - Tailscale app → Settings → DNS
   - Make sure "Use Tailscale DNS" is ON

3. **Check internet connection:**
   - Turn off Tailscale
   - Visit google.com (should work)
   - Turn on Tailscale
   - Try again

4. **Restart device:**
   - Sometimes iOS/Windows needs a restart
   - Restart phone/computer
   - Reconnect to Tailscale

5. **Check Tailscale version:**
   - Update Tailscale app to latest version
   - Older versions might have DNS bugs

### DNS Works But Certificate Warning

**Problem:** Domain resolves but still get certificate error

**Check:**
```
Certificate is for: thedarkurge.li-rattlesnake.ts.net
You're accessing:   budget.thedarkurge.li-rattlesnake.ts.net
```

**Solution:** The subdomain needs to be in the certificate!

**Our certificate covers:**
- ✅ `thedarkurge.li-rattlesnake.ts.net` (base)
- ✅ `*.thedarkurge.li-rattlesnake.ts.net` (wildcard - should work!)

If you still get warning, the cert might not be wildcard. Try:
```bash
# On server, check certificate
openssl x509 -in ~/homelab/services/traefik/thedarkurge.li-rattlesnake.ts.net.crt -noout -text | grep DNS
```

### Wildcard Not Working

**If certificate doesn't have wildcard:**

**Option 1:** Get wildcard certificate from Tailscale  
**Option 2:** Keep using IP for now  
**Option 3:** Get certificate for each subdomain

### Can Ping But Can't Access Website

**Problem:** `ping thedarkurge.li-rattlesnake.ts.net` works but website doesn't

**Check:**
1. Is Traefik running? `docker ps | grep traefik`
2. Is port 8443 accessible? `curl -k https://100.70.106.23:8443`
3. Firewall blocking? Check ufw rules

---

## 📋 **Quick Checklist**

Before asking for help, verify:

- [ ] MagicDNS enabled in Tailscale admin console
- [ ] HTTPS Certificates enabled in Tailscale admin console
- [ ] "Use Tailscale DNS" enabled on iPhone
- [ ] "Use Tailscale DNS" enabled on PC
- [ ] Reconnected after enabling DNS
- [ ] Can ping: `thedarkurge.li-rattlesnake.ts.net`
- [ ] Can resolve: `nslookup budget.thedarkurge.li-rattlesnake.ts.net`
- [ ] Traefik is running: `docker ps | grep traefik`

---

## 🎓 **Understanding MagicDNS**

### What It Does

MagicDNS is Tailscale's built-in DNS server that:
1. Gives each device a hostname (`thedarkurge`)
2. Automatically resolves within your network
3. Works with subdomains (`budget.thedarkurge...`)
4. No manual DNS configuration needed

### How It Works

```
Your iPhone → Looks up "budget.thedarkurge.li-rattlesnake.ts.net"
              ↓
Tailscale DNS → "That's 100.70.106.23"
              ↓
Your iPhone → Connects to 100.70.106.23:8443
              ↓
Traefik → Sees Host: budget.thedarkurge.li-rattlesnake.ts.net
        → Routes to Actual Budget
              ↓
🎉 It works!
```

### Why It's Better Than IP

**With IP:**
- `https://100.70.106.23:8443` ⚠️ Certificate warning
- Hard to remember
- If IP changes, bookmarks break

**With MagicDNS:**
- `https://budget.thedarkurge.li-rattlesnake.ts.net:8443` ✅ No warning
- Easy to remember
- IP can change, DNS updates automatically

---

## 🚀 **Next Steps After DNS Works**

Once MagicDNS is working:

1. **Update bookmarks** with pretty URLs
2. **Test from all devices** (iPhone, PC, iPad)
3. **Migrate more services** to Traefik
4. **Remove port numbers** (advanced: use port 443)
5. **Share URLs with family** (if they have Tailscale)

---

**Need help? Let me know which step isn't working!** 🎯

