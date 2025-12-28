# 🚀 Quick Deployment Guide - gisconnect.online

## Timeline: ~1-2 hours for complete deployment

### Prerequisites
- Linux server (Ubuntu 20.04+) with root access
- Domain "gisconnect.online" registered
- Server IP address (from hosting provider)
- SSH access to server

---

## Step 1: Server Setup (10 minutes)

### Get Server IP
Ask your hosting provider for your **public IP address**.

### Connect via SSH
```bash
ssh root@YOUR_SERVER_IP
# or with key file
ssh -i /path/to/key.pem root@YOUR_SERVER_IP
```

---

## Step 2: Upload Project (5 minutes)

### Option A: Clone from GitHub
```bash
sudo mkdir -p /var/www/gisconnect
cd /var/www/gisconnect
git clone https://github.com/your-repo/apps2026.git .
```

### Option B: Upload via SFTP
```bash
# From your local machine
scp -r C:\path\to\apps2026\* root@YOUR_SERVER_IP:/var/www/gisconnect/
```

---

## Step 3: Run Deployment Script (45 minutes)

### Make script executable and run
```bash
cd /var/www/gisconnect
chmod +x deploy.sh
sudo ./deploy.sh
```

The script will:
- ✅ Install Node.js, Nginx, PM2, Certbot
- ✅ Install all dependencies
- ✅ Build dashboard
- ✅ Initialize database
- ✅ Configure Nginx
- ✅ Get SSL certificate from Let's Encrypt
- ✅ Start backend with PM2
- ✅ Setup auto-backup
- ✅ Configure firewall

---

## Step 4: Configure DNS (5 minutes)

### Add these DNS A Records at dns-parking.com

| Name | Type | Value | TTL |
|------|------|-------|-----|
| gisconnect.online | A | YOUR_SERVER_IP | 3600 |
| api.gisconnect.online | A | YOUR_SERVER_IP | 3600 |
| app.gisconnect.online | A | YOUR_SERVER_IP | 3600 |
| www.gisconnect.online | A | YOUR_SERVER_IP | 3600 |

### Steps:
1. Login to dns-parking.com
2. Go to Domain Management → Your Domain
3. Click Edit DNS Records or DNS Settings
4. Add 4 A Records (copy table above)
5. Save changes
6. Wait 5-15 minutes for propagation

---

## Step 5: Verify Everything (10 minutes)

### Test DNS (after 5-15 min wait)
```bash
nslookup gisconnect.online
nslookup api.gisconnect.online
# Should return YOUR_SERVER_IP
```

### Test HTTPS
```bash
curl -I https://api.gisconnect.online/health
curl -I https://gisconnect.online
```

### Test in Browser
- **Dashboard**: https://gisconnect.online
- **API**: https://api.gisconnect.online
- Should show login page

### Test Mobile Access
- From iPhone: Open Safari → https://gisconnect.online
- From Android: Open Chrome → https://gisconnect.online

---

## Step 6: Create Admin Account

### Connect to backend
```bash
ssh root@YOUR_SERVER_IP
cd /var/www/gisconnect
node
```

### Add admin user
```javascript
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./databases/menulogin.db');

db.run(
  'INSERT INTO menulogin (username, password, access_level) VALUES (?, ?, ?)',
  ['admin', 'hashedpassword', 'admin'],
  (err) => {
    if (err) console.error(err);
    else console.log('Admin user created');
    process.exit(0);
  }
);
```

### Or use dashboard registration (if enabled)
Login URL: https://gisconnect.online/register

---

## Step 7: Configure Mobile App

### Update mobile config file

Edit [MobileApp/src/config/api.js](MobileApp/src/config/api.js):

```javascript
export const API_CONFIG = {
  API_BASE_URL: 'https://api.gisconnect.online/api',
  SOCKET_URL: 'https://api.gisconnect.online',
  TIMEOUT: 30000,
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 2000
};

export const APP_VERSION = '1.0.0';
export const ENVIRONMENT = 'production';
```

### Build and Deploy Mobile App

```bash
cd MobileApp

# For Android
npm run build:android

# For iOS
npm run build:ios

# Or use Expo Cloud Build
expo publish
```

---

## Troubleshooting

### "DNS not resolving"
- Wait another 5-10 minutes
- Clear browser cache: Ctrl+Shift+Delete
- Try another device

### "Connection refused on :3000"
```bash
ssh root@YOUR_SERVER_IP
pm2 logs gisconnect-api  # Check logs
pm2 restart gisconnect-api  # Restart
```

### "SSL certificate issue"
```bash
ssh root@YOUR_SERVER_IP
sudo certbot renew --dry-run  # Test renewal
sudo certbot certificates  # Check status
```

### "Nginx error"
```bash
ssh root@YOUR_SERVER_IP
sudo nginx -t  # Test config
sudo systemctl restart nginx  # Restart
tail -f /var/log/nginx/error.log  # View errors
```

### "Database locked"
```bash
ssh root@YOUR_SERVER_IP
cd /var/www/gisconnect
# Stop backend
pm2 stop gisconnect-api

# Check database files
ls -la databases/

# Clear locks (if necessary)
rm -f databases/*.db-journal

# Restart
pm2 start gisconnect-api
```

---

## System Commands

### Check Backend Status
```bash
ssh root@YOUR_SERVER_IP
pm2 status
pm2 logs gisconnect-api
```

### View Logs
```bash
# Backend logs
tail -f /var/www/gisconnect/logs/combined.log

# Nginx access logs
tail -f /var/log/nginx/gisconnect-*-access.log

# Nginx error logs
tail -f /var/log/nginx/gisconnect-*-error.log
```

### Restart Services
```bash
# Restart backend
pm2 restart gisconnect-api

# Restart Nginx
sudo systemctl restart nginx

# Full restart
pm2 restart gisconnect-api && sudo systemctl restart nginx
```

### Manual Backup
```bash
cd /var/www/gisconnect
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz databases/
```

---

## Access Points

### For Office Staff
- **Dashboard**: https://gisconnect.online
- **Admin Panel**: https://gisconnect.online/admin
- **Reports**: https://gisconnect.online/reports

### For Field Staff
- **Mobile App**: Install from app store or Expo
  - iPhone: Open Safari → https://gisconnect.online → Share → Add to Home Screen
  - Android: Open Chrome → https://gisconnect.online → Menu → Install app

### For Developers
- **API Documentation**: https://api.gisconnect.online
- **API Base URL**: https://api.gisconnect.online/api
- **WebSocket URL**: https://api.gisconnect.online/socket.io

---

## Real-time Sync Setup

The system automatically syncs in real-time:

1. **Mobile App** captures visit data (GPS, photos)
2. **Backend** receives and stores in database
3. **Socket.IO** broadcasts update to all connected clients
4. **Dashboard** displays update instantly (no page refresh needed)

### To manually trigger sync:
- **Mobile**: Pull-down refresh or auto-sync every 30 seconds
- **Dashboard**: Click "Sync Now" button or auto-refresh every 5 seconds

---

## Mobile-Responsive Dashboard

The dashboard automatically adapts to device size:

- **Mobile** (< 480px): Bottom navigation, card layout
- **Tablet** (480-768px): Side drawer, 2-column layout
- **Desktop** (> 768px): Full sidebar, 3+ column layout

### Test Responsive Design:
1. Open https://gisconnect.online in browser
2. Press F12 → DevTools
3. Click "Toggle Device Toolbar" (Ctrl+Shift+M)
4. Select device (iPhone 12, Galaxy S21, etc.)
5. Test navigation and forms

---

## Monitoring Dashboard

Check system health:

```bash
ssh root@YOUR_SERVER_IP

# Backend health
curl https://api.gisconnect.online/health

# Check disk space
df -h

# Check memory usage
free -h

# Check database integrity
sqlite3 /var/www/gisconnect/databases/datauser.db "PRAGMA integrity_check;"
```

---

## Next Steps

1. ✅ Upload project files
2. ✅ Run deployment script
3. ✅ Configure DNS records
4. ✅ Test system accessibility
5. ✅ Create admin account
6. ✅ Configure mobile app
7. ✅ Import field staff (users, outlets)
8. ✅ Create visit schedules
9. ✅ Distribute mobile app to field teams
10. ✅ Monitor live tracking and syncing

---

## Support

For detailed information, see:
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Complete deployment guide
- [DNS_SETUP_GUIDE.md](./DNS_SETUP_GUIDE.md) - Detailed DNS setup
- [MOBILE_DASHBOARD_GUIDE.md](./MOBILE_DASHBOARD_GUIDE.md) - Mobile responsiveness
- [SYSTEM_ARCHITECTURE.md](./SYSTEM_ARCHITECTURE.md) - System architecture

---

**Estimated Total Time: 1-2 hours**

✅ **Your gisconnect.online system is now live!**
