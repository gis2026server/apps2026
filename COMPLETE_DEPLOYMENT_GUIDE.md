# 🚀 COMPLETE DEPLOYMENT AUTOMATION GUIDE
## GIS2026 System - Production Ready

**Status: READY FOR FULL DEPLOYMENT** ✅

This guide contains ALL commands and scripts needed to deploy your entire GIS2026 system.

---

## 📋 QUICK START CHECKLIST

Choose your path based on what you need:

### Path 1: Windows Local Preparation (Do This First!)
```powershell
# Run this on your Windows machine to prepare everything locally
powershell -ExecutionPolicy Bypass -File prepare-deployment.ps1
```
**What it does:**
- ✅ Verifies all configuration is correct
- ✅ Installs dependencies
- ✅ Builds dashboard
- ✅ Creates .env file

**Time: 10-15 minutes**

---

### Path 2: Backend Deployment (Run on Linux Server)
```bash
# Upload server folder to aapanel, then run this
bash deploy-backend.sh
```
**What it does:**
- ✅ Verifies Node.js and npm
- ✅ Creates directories
- ✅ Installs dependencies
- ✅ Sets up PM2 process manager
- ✅ Starts backend server

**Time: 5-10 minutes**

---

### Path 3: Dashboard Deployment (Run on Linux Server)
```bash
# Run this after backend is deployed
bash deploy-dashboard.sh
```
**What it does:**
- ✅ Builds dashboard from source
- ✅ Deploys to web root
- ✅ Configures permissions
- ✅ Verifies deployment

**Time: 5-10 minutes**

---

### Path 4: Mobile App Build (Run on Your Machine)
```bash
# Build Android APK and iOS IPA
bash build-mobile-apps.sh
```
**What it does:**
- ✅ Installs Expo CLI
- ✅ Submits Android build
- ✅ Submits iOS build
- ✅ Provides download links

**Time: 30-60 minutes (cloud builds)**

---

## 🔧 MANUAL DEPLOYMENT COMMANDS

### For Those Who Prefer Manual Steps

#### 1. LOCAL PREPARATION (Windows/Mac/Linux)

```bash
# Install dependencies - Dashboard
cd dashboard
npm install --production

# Install dependencies - Mobile App
cd ../MobileApp
npm install --production

# Install dependencies - Server
cd ../server
npm install --production

# Verify configuration files are correct
# ✓ dashboard/src/services/api.js should have: https://gisconnect.online/api
# ✓ MobileApp/src/config/environment.js should have: https://gisconnect.online/api
# ✓ server/.env should exist with all variables
```

#### 2. BUILD DASHBOARD (Windows/Mac/Linux)

```bash
# Build for production
cd dashboard
npm run build

# Output goes to: dashboard/dist/
# Ready for upload to web server
```

---

## 🖥️ SERVER DEPLOYMENT COMMANDS

**Run these commands on your aapanel Linux server via SSH**

### Login to Server
```bash
# SSH into your server (replace with your server IP)
ssh -i your_key.pem root@192.168.0.169
# OR use aapanel terminal directly
```

### Step 1: Create Web Root Directory
```bash
# Create directory structure
mkdir -p /home/www/gisconnect.online
mkdir -p /home/www/gisconnect.online/server
mkdir -p /home/www/gisconnect.online/public_html

# Set permissions
chmod -R 755 /home/www/gisconnect.online
```

### Step 2: Upload Server Files
```bash
# Using SFTP or aapanel file manager:
# Upload your local server/ folder to /home/www/gisconnect.online/server/

# Via SCP (from your local machine):
scp -r ./server root@192.168.0.169:/home/www/gisconnect.online/
```

### Step 3: Install Server Dependencies
```bash
cd /home/www/gisconnect.online/server
npm install --production
```

### Step 4: Setup Environment Variables
```bash
# Edit .env file
nano .env

# Key variables to update:
# NODE_ENV=production
# CORS_ORIGIN=https://gisconnect.online
# JWT_SECRET=generate-a-long-random-string-here
# DATABASE_PATH=/home/www/gisconnect.online/server/database
# UPLOAD_PATH=/home/www/gisconnect.online/server/uploads
```

**Generate JWT_SECRET:**
```bash
# On server terminal, run:
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Copy the output and paste it as JWT_SECRET in .env
```

### Step 5: Install and Setup PM2
```bash
# Install PM2 globally
npm install -g pm2

# Start server
cd /home/www/gisconnect.online
pm2 start server/index.js --name gis2026-server --instances 2 --exec-mode cluster

# Configure startup
pm2 startup systemd -u root --hp /root
pm2 save

# View status
pm2 status
```

### Step 6: Upload Dashboard Files
```bash
# From your local machine, build dashboard:
cd dashboard
npm run build

# Upload built files to web root:
scp -r ./dist/* root@192.168.0.169:/home/www/gisconnect.online/public_html/

# Or via aapanel file manager:
# Upload contents of dashboard/dist/ to /public_html/
```

### Step 7: Configure nginx (in aapanel)
```
# In aapanel → Sites → Create Site
Website name: gisconnect.online
Root directory: /home/www/gisconnect.online/public_html
PHP version: Static
SSL: Let's Encrypt (auto)
```

**Add nginx configuration:**
```bash
# Edit site configuration in aapanel → nginx config
# Add this location block:

location /api {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location / {
    try_files $uri $uri/ /index.html;
}
```

---

## 📱 MOBILE APP DEPLOYMENT

### Prerequisites
- Expo account: https://expo.dev/signup
- For Android: EAS (Expo Application Services)
- For iOS: Mac with Xcode (or use EAS cloud build)

### Build Android APK
```bash
# Install Expo CLI
npm install -g expo-cli

# Navigate to MobileApp
cd MobileApp

# Login to Expo
expo login

# Build APK
expo build:android -t apk

# Monitor progress
expo build:status

# Download when ready
expo build:download --android
```

### Build iOS IPA
```bash
# Same steps as Android
cd MobileApp
expo login

# For Mac users:
expo build:ios

# For cloud build (all platforms):
npm install -g eas-cli
eas build --platform ios
```

### Test Mobile Apps
```bash
# Install on Android device
adb install path/to/app.apk

# Test API connection
# Use login: gis2026 / gis2026
# Verify real-time sync works
```

---

## ✅ VERIFICATION CHECKLIST

### Backend Verification
```bash
# SSH into server, then:

# 1. Check PM2 status
pm2 status

# 2. Check API is responding
curl -X GET https://gisconnect.online/api/health
# or
curl -X POST https://gisconnect.online/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"gis2026","password":"gis2026"}'

# 3. Check logs
pm2 logs gis2026-server

# 4. Monitor system
pm2 monit
```

### Dashboard Verification
```bash
# Open browser
https://gisconnect.online

# 1. Login page loads
# 2. Login with gis2026 / gis2026
# 3. Dashboard displays
# 4. Data loads correctly
# 5. Check browser console for errors
```

### Mobile App Verification
```
1. Install APK on Android device
2. Install IPA on iOS device
3. Login with gis2026 / gis2026
4. Verify location services work
5. Verify data sync works
6. Check real-time updates
```

### SSL/HTTPS Verification
```bash
# Check SSL certificate
openssl s_client -connect gisconnect.online:443

# Or in browser:
https://www.ssllabs.com/ssltest/analyze.html?d=gisconnect.online
```

---

## 🔐 SECURITY CHECKLIST

Before Going Live:

- [ ] Change default admin password (gis2026 / gis2026)
- [ ] Generate and set JWT_SECRET in .env
- [ ] Enable SSL/HTTPS certificate
- [ ] Configure CORS correctly (should be https://gisconnect.online)
- [ ] Setup firewall rules
- [ ] Configure rate limiting
- [ ] Enable database backups
- [ ] Setup monitoring alerts
- [ ] Review security logs
- [ ] Test with OWASP ZAP or similar tool

---

## 📊 MONITORING & MAINTENANCE

### Daily Monitoring
```bash
# SSH into server
ssh root@192.168.0.169

# Check server status
pm2 status
pm2 monit

# Check disk space
df -h

# Check memory
free -h

# Check logs for errors
pm2 logs gis2026-server --lines 50
```

### Backup Database
```bash
# SSH into server
cd /home/www/gisconnect.online/server/database

# Backup SQLite database
cp db.sqlite3 db.sqlite3.backup.$(date +%Y%m%d_%H%M%S)

# Or use automated backup script
# Create cron job: 0 2 * * * /path/to/backup-script.sh
```

### Restart Services
```bash
# Restart backend
pm2 restart gis2026-server

# Restart nginx
systemctl restart nginx

# Restart all services
pm2 restart all
pm2 restart gis2026-server
systemctl restart nginx
```

### View Real-time Logs
```bash
# Backend logs
pm2 logs gis2026-server --lines 100 --follow

# Nginx error logs
tail -f /var/log/nginx/error.log

# Nginx access logs
tail -f /var/log/nginx/access.log
```

---

## 🆘 TROUBLESHOOTING

### Server Won't Start
```bash
# Check logs
pm2 logs gis2026-server --lines 50

# Check .env file exists
cat /home/www/gisconnect.online/server/.env

# Check port 3000 is not in use
netstat -tulpn | grep :3000

# Restart PM2
pm2 stop gis2026-server
pm2 start /home/www/gisconnect.online/server/index.js --name gis2026-server
```

### Dashboard Shows 404
```bash
# Check nginx config
# Make sure try_files $uri $uri/ /index.html; is configured

# Check files are in place
ls -la /home/www/gisconnect.online/public_html/

# Check permissions
chmod -R 755 /home/www/gisconnect.online/public_html/
```

### API Connection Fails
```bash
# Check backend is running
pm2 status

# Check CORS is configured
# In server/.env: CORS_ORIGIN=https://gisconnect.online

# Test API directly
curl -X GET https://gisconnect.online/api/health

# Check nginx proxy config
cat /usr/local/nginx/conf/vhost/gisconnect.online.conf
```

### Real-time Sync Not Working
```bash
# Check Socket.io is enabled in server/index.js
grep -n "io\|socket" /home/www/gisconnect.online/server/index.js

# Check WebSocket connections in browser DevTools
# Network tab → Filter for "ws://" or "wss://"

# Restart server
pm2 restart gis2026-server
```

---

## 📞 SUPPORT INFORMATION

### Key Files and Paths
- Backend: `/home/www/gisconnect.online/server/`
- Frontend: `/home/www/gisconnect.online/public_html/`
- Database: `/home/www/gisconnect.online/server/database/`
- Uploads: `/home/www/gisconnect.online/server/uploads/`
- Logs: `pm2 logs gis2026-server`

### Important Configuration Files
- Server: `/home/www/gisconnect.online/server/.env`
- Nginx: `/usr/local/nginx/conf/vhost/gisconnect.online.conf`
- PM2: `pm2 show gis2026-server`

### Recovery Commands
```bash
# Full restart
pm2 restart gis2026-server
systemctl restart nginx

# Database reset (careful!)
rm /home/www/gisconnect.online/server/database/db.sqlite3
# Database will be recreated on next server start

# Complete cleanup and restart
pm2 stop gis2026-server
pm2 delete gis2026-server
rm -rf /home/www/gisconnect.online/server/database
pm2 start /home/www/gisconnect.online/server/index.js --name gis2026-server
```

---

## 🎉 FINAL CHECKLIST

When everything is deployed:

- [ ] Domain resolves (nslookup gisconnect.online)
- [ ] HTTPS works (https://gisconnect.online)
- [ ] Dashboard loads (https://gisconnect.online)
- [ ] Login works (username: gis2026, password: gis2026)
- [ ] API responds (curl to /api/auth/login)
- [ ] Real-time sync works (check browser console)
- [ ] Mobile apps build (APK and IPA available)
- [ ] Mobile apps connect (test on devices)
- [ ] Database backups configured
- [ ] Monitoring/alerts setup
- [ ] SSL certificate valid (check expiration)
- [ ] Security hardened

---

**System Status: PRODUCTION READY** ✅

All code is updated, all scripts are prepared, and you have everything needed to deploy!

Next Step: Run `prepare-deployment.ps1` on Windows to start!
