# 🚀 Complete Production Setup Guide for GIS2026 with aapanel

**Project Domain:** `gisconnect.online`  
**aapanel Access:** `http://192.168.0.169:1122/gis2026`  
**Credentials:** `gis2026` / `gis2026`  

---

## 📋 Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [System Architecture Review](#system-architecture-review)
3. [Code Review & Verification](#code-review--verification)
4. [aapanel Setup & Configuration](#aapanel-setup--configuration)
5. [Database Setup](#database-setup)
6. [Backend Server Deployment](#backend-server-deployment)
7. [Dashboard Frontend Deployment](#dashboard-frontend-deployment)
8. [Mobile App Build & Deployment](#mobile-app-build--deployment)
9. [Real-Time Synchronization Setup](#real-time-synchronization-setup)
10. [Post-Deployment Testing](#post-deployment-testing)
11. [Troubleshooting Guide](#troubleshooting-guide)

---

## 📋 Pre-Deployment Checklist

### System Requirements
- [ ] Server with at least 2GB RAM, 2 CPU cores
- [ ] Ubuntu 20.04+ or similar Linux distribution
- [ ] Node.js v14+ installed
- [ ] SQLite3 support
- [ ] SSL certificate (Let's Encrypt via aapanel)
- [ ] Domain DNS configured to nameservers

### Backup & Testing
- [ ] All code committed to git
- [ ] Database backup created
- [ ] All environment variables documented
- [ ] Local testing completed
- [ ] API endpoints tested
- [ ] Mobile app tested in local environment

### Access & Credentials
- [ ] aapanel credentials: `gis2026` / `gis2026`
- [ ] Server SSH access credentials ready
- [ ] Database credentials prepared
- [ ] SSL certificate ready or Let's Encrypt configured

---

## 🏗️ System Architecture Review

### Current Project Structure

```
apps2026/
├── server/                    # Node.js Backend API
│   ├── index.js              # Server entry point
│   ├── controllers/          # API controllers
│   ├── routes/               # API routes
│   ├── middleware/           # Auth, validation, rate limiting
│   ├── database/             # Database initialization
│   └── utils/                # Utilities (sync, upload, etc.)
├── dashboard/                # React Frontend Dashboard
│   ├── src/
│   │   ├── components/       # Reusable components
│   │   ├── services/         # API services
│   │   └── App.jsx           # Main app component
│   └── package.json          # Dependencies
└── MobileApp/               # React Native Mobile App
    ├── src/
    │   ├── screens/         # App screens
    │   ├── services/        # API services
    │   ├── config/          # Environment config
    │   └── utils/           # Utilities
    └── package.json         # Dependencies
```

### Key Technologies
- **Backend:** Express.js, Node.js, SQLite
- **Dashboard:** React, Material-UI, Axios
- **Mobile:** React Native, Expo, Location/Camera APIs
- **Real-Time:** Socket.io
- **Security:** JWT, Helmet, Rate Limiting

---

## 🔍 Code Review & Verification

### Backend Server Analysis

**File:** `server/index.js`

✅ **Verified:**
- Express.js server with HTTP and WebSocket support
- CORS configured for cross-origin requests
- Helmet security middleware enabled
- Compression middleware for performance
- Socket.io setup for real-time sync
- Rate limiting middleware configured
- Input sanitization middleware active
- Static file serving for uploads

**Critical Configuration:**
```javascript
const PORT = process.env.PORT || 3000;
const CORS_ORIGIN = process.env.CORS_ORIGIN || '*';
```

**Required Environment Variables:**
```
PORT=3000
CORS_ORIGIN=https://gisconnect.online
NODE_ENV=production
DEFAULT_ADMIN_USERNAME=gis2026
DEFAULT_ADMIN_PASSWORD=gis2026
UPLOAD_PATH=./uploads
EXCEL_UPLOAD_PATH=./uploads/excel
IMAGE_UPLOAD_PATH=./uploads/images
```

### Database Schema Review

**File:** `server/database/schema.js`

**Tables Created:**
1. `menulogin` - User authentication
2. `datauser` - User profiles
3. `dataoutlet` - Store/outlet information
4. `datavisitmd` - MD visits
5. `datavisitsales` - Sales visits
6. `visitaction` - Check-in/check-out actions

**Verification:** ✅ All tables have proper schema and timestamps

### API Endpoints Review

**Authentication:**
- `POST /api/auth/login` - User login
- `GET /api/auth/users` - Get all users

**Users:**
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user
- `POST /api/users/upload-excel` - Bulk upload

**Outlets:**
- `GET /api/outlets` - List outlets
- `POST /api/outlets` - Create outlet
- `PUT /api/outlets/:id` - Update outlet
- `DELETE /api/outlets/:id` - Delete outlet
- `POST /api/outlets/upload-excel` - Bulk upload

**Visits:**
- `GET /api/visits` - List visits
- `POST /api/visits` - Create visit
- `GET /api/visits/date/:date` - Get visits by date

**Visit Actions:**
- `POST /api/visit-actions` - Check-in/check-out

**Reports:**
- `GET /api/reports/daily` - Daily reports
- `POST /api/reports/export` - Export to Excel

**Verification:** ✅ All endpoints properly documented

### Dashboard Configuration Review

**File:** `dashboard/src/services/api.js`

**API Configuration:**
```javascript
const API_URL = 'http://localhost:3001/api'; // LOCAL - needs update
```

⚠️ **ISSUE FOUND:** API_URL hardcoded to localhost
**ACTION REQUIRED:** Update to production URL

**File:** `dashboard/src/components/Login/Login.jsx`

✅ **Verified:**
- JWT token handling
- localStorage for persistence
- Error handling and validation
- Proper redirect after login

### Mobile App Configuration Review

**File:** `MobileApp/src/config/environment.js`

**Current Configuration:**
```javascript
const DEV_API_URL = 'http://192.168.0.43:3001/api'; // DEVELOPMENT
const PROD_API_URL = 'https://your-production-server.com/api'; // NEEDS UPDATE
```

⚠️ **ISSUE FOUND:** Production URL placeholder not updated

**File:** `MobileApp/app.json`

✅ **Verified:**
- Bundle IDs configured
- Permissions declared (Camera, Location, Storage)
- Expo configuration complete
- Android/iOS specific settings present

---

## ⚙️ aapanel Setup & Configuration

### Step 1: Domain Registration & DNS Configuration

**Current Domain:** `gisconnect.online`  
**Current Nameservers:**
- ns1.dns-parking.com
- ns2.dns-parking.com

### Step 2: Update Domain Nameservers to aapanel

**Your aapanel Server Nameservers:**
- Get these from aapanel panel (Settings > Nameservers)
- Typically: ns1.[server-ip], ns2.[server-ip]

**Update Steps:**
1. Log in to your domain registrar
2. Update nameservers from dns-parking to aapanel servers
3. Wait 24-48 hours for DNS propagation
4. Verify with `nslookup gisconnect.online`

### Step 3: Access aapanel Control Panel

**URL:** `http://192.168.0.169:1122/gis2026`  
**Username:** `gis2026`  
**Password:** `gis2026`

### Step 4: Add Domain in aapanel

1. Open aapanel control panel
2. Navigate to: **Websites** → **Add Website**
3. Fill in:
   - Domain: `gisconnect.online`
   - Root Directory: `/home/www/gisconnect.online`
   - Select PHP/Runtime: Node.js
4. Click **Submit**

### Step 5: Configure SSL Certificate

**Option A: Let's Encrypt (Recommended)**

1. Go to **Websites** → Select `gisconnect.online`
2. Click **SSL** → **Let's Encrypt**
3. Enter:
   - Email: your-email@example.com
   - Domains: `gisconnect.online, www.gisconnect.online`
4. Click **Apply Certificate**

**Option B: Manual Certificate**

1. Copy your existing SSL certificate files
2. Go to **Websites** → **gisconnect.online** → **SSL**
3. Upload certificate and key files

### Step 6: Configure Port & Reverse Proxy

**For Backend Server (Port 3000):**

1. Go to **Websites** → **gisconnect.online** → **Reverse Proxy**
2. Add reverse proxy:
   - **Name:** backend-api
   - **Target URL:** `http://127.0.0.1:3000`
   - **Path:** `/api`
3. Save configuration

**nginx Configuration:**
```nginx
server {
    listen 80;
    server_name gisconnect.online www.gisconnect.online;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name gisconnect.online www.gisconnect.online;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    # Dashboard Frontend
    location / {
        root /home/www/gisconnect.online/dashboard/dist;
        try_files $uri /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }
    
    # Socket.io for real-time sync
    location /socket.io {
        proxy_pass http://127.0.0.1:3000/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

---

## 💾 Database Setup

### Step 1: Create Database Directory

```bash
# On your aapanel server
mkdir -p /home/www/gisconnect.online/database
chmod -R 755 /home/www/gisconnect.online/database
```

### Step 2: Initialize Database

The backend server will automatically create SQLite databases:

```bash
# Navigate to backend directory
cd /home/www/gisconnect.online/server

# Database files will be created in ./database/ directory
# - menulogin.db
# - datauser.db
# - dataoutlet.db
# - datavisitmd.db
# - datavisitsales.db
# - visitaction.db
```

### Step 3: Set Database Permissions

```bash
chmod -R 755 /home/www/gisconnect.online/database
chmod -R 755 /home/www/gisconnect.online/server/database
```

### Step 4: Default Admin User

**Automatic Creation:**

When server starts, default admin user created:
- **Username:** `gis2026`
- **Password:** `gis2026`
- **Access Level:** `admin`

**Change Password After First Login:**

1. Log in to dashboard with `gis2026/gis2026`
2. Go to **Auth Users Management**
3. Edit admin user and change password
4. Save changes

---

## 🖥️ Backend Server Deployment

### Step 1: Upload Project Files

**Using SCP or aapanel File Manager:**

```bash
# From local machine
scp -r server/ user@192.168.0.169:/home/www/gisconnect.online/

# Or use aapanel File Manager:
# 1. Navigate to /home/www/gisconnect.online/
# 2. Upload server folder
```

### Step 2: Install Dependencies

```bash
cd /home/www/gisconnect.online/server
npm install --production
```

**Dependencies Summary:**
- `express` - Web framework
- `cors` - Cross-origin requests
- `socket.io` - Real-time communication
- `sqlite3` - Database
- `bcryptjs` - Password hashing
- `jsonwebtoken` - JWT tokens
- `multer` - File uploads
- `exceljs` - Excel export
- `helmet` - Security headers
- `compression` - Response compression
- `dotenv` - Environment variables

### Step 3: Create Environment File

**Create `.env` file:**

```bash
# /home/www/gisconnect.online/server/.env

# Server Configuration
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# CORS Configuration
CORS_ORIGIN=https://gisconnect.online

# Database Configuration
DATABASE_PATH=./database
UPLOAD_PATH=./uploads
EXCEL_UPLOAD_PATH=./uploads/excel
IMAGE_UPLOAD_PATH=./uploads/images

# Authentication
DEFAULT_ADMIN_USERNAME=gis2026
DEFAULT_ADMIN_PASSWORD=gis2026
JWT_SECRET=your-secret-key-change-this-in-production
JWT_EXPIRY=7d

# Rate Limiting
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info

# File Upload
MAX_FILE_SIZE=52428800
ALLOWED_UPLOAD_TYPES=xlsx,xls

# Mobile App
MOBILE_APP_VERSION=1.0.0
```

### Step 4: Create Upload Directories

```bash
mkdir -p /home/www/gisconnect.online/server/uploads
mkdir -p /home/www/gisconnect.online/server/uploads/excel
mkdir -p /home/www/gisconnect.online/server/uploads/images
chmod -R 755 /home/www/gisconnect.online/server/uploads
```

### Step 5: Start Backend Server with PM2

**Install PM2 globally:**

```bash
npm install -g pm2
```

**Create PM2 Ecosystem File:**

```bash
# /home/www/gisconnect.online/ecosystem.config.js

module.exports = {
  apps: [
    {
      name: 'gis2026-server',
      script: './server/index.js',
      instances: 4,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      restart_delay: 4000,
      max_restarts: 10,
      max_memory_restart: '1G'
    }
  ]
};
```

**Start Server:**

```bash
cd /home/www/gisconnect.online
pm2 start ecosystem.config.js
pm2 startup
pm2 save
```

**Monitor Server:**

```bash
pm2 logs gis2026-server
pm2 status
```

---

## 🎨 Dashboard Frontend Deployment

### Step 1: Build Dashboard for Production

```bash
cd /home/www/gisconnect.online/dashboard

# Install dependencies
npm install --production

# Build for production
npm run build
```

**Build Output:** `dashboard/dist/` directory

### Step 2: Configure API Base URL

**Before Building, Update API Configuration:**

**File:** `dashboard/src/services/api.js`

```javascript
import axios from 'axios';

// Production API URL
const API_URL = 'https://gisconnect.online/api';

// For development/testing with different domain
// const API_URL = process.env.REACT_APP_API_URL || 'https://gisconnect.online/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});
```

### Step 3: Update Dashboard in aapanel

**Deploy Built Files:**

```bash
# Copy built files to web root
cp -r /home/www/gisconnect.online/dashboard/dist/* \
      /home/www/gisconnect.online/public_html/

# Or if using aapanel File Manager:
# 1. Upload contents of dashboard/dist/
# 2. Place in domain root directory
```

### Step 4: Configure Dashboard in aapanel

**In aapanel Control Panel:**

1. Go to **Websites** → **gisconnect.online**
2. Set **Root Directory:** `/home/www/gisconnect.online/public_html`
3. Configure **Reverse Proxy** for `/api` → `http://127.0.0.1:3000`
4. Add rewrite rule for SPA routing

**nginx Rewrite Rules:**

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

---

## 📱 Mobile App Build & Deployment

### Android App Build

#### Prerequisites

1. **Install Expo CLI:**
   ```bash
   npm install -g expo-cli
   ```

2. **Create Expo Account:**
   ```bash
   expo login
   # Enter your email and password
   ```

3. **Update Environment Configuration:**

**File:** `MobileApp/src/config/environment.js`

```javascript
// Production API URL
const PROD_API_URL = 'https://gisconnect.online/api';

const ENV = {
  dev: {
    apiUrl: 'http://192.168.0.169:3001/api', // Development
  },
  prod: {
    apiUrl: PROD_API_URL, // Production
  },
};
```

#### Build APK for Android

**Option 1: Using Expo (Easiest)**

```bash
cd MobileApp

# Install dependencies
npm install

# Build APK
expo build:android -t apk

# Monitor build progress
expo build:status

# Download APK when ready
# Save APK file for installation on Android devices
```

**Option 2: Using EAS Build (Recommended)**

```bash
cd MobileApp

# Install EAS CLI
npm install -g eas-cli

# Configure EAS
eas build:configure

# Build APK
eas build --platform android --local

# APK will be available at: dist/ directory
```

#### Build IPA for iOS

**Option 1: Using Expo**

```bash
cd MobileApp

# Build IPA
expo build:ios -t ipa

# Monitor build
expo build:status

# Download IPA when ready
```

**Option 2: Using EAS Build**

```bash
cd MobileApp

# Build IPA
eas build --platform ios

# Upload to TestFlight or App Store
```

### Install on Physical Devices

#### Android Installation

```bash
# Using adb
adb install -r app-release.apk

# Or transfer APK and install manually on device
```

#### iOS Installation

**Option 1: TestFlight**

1. Build IPA using expo/EAS
2. Upload to App Store Connect
3. Add testers in TestFlight
4. Testers download from TestFlight app

**Option 2: Manual Installation**

```bash
# Using Xcode
open MobileApp
# Build and run on simulator or connected device
```

### Configure Mobile App for Production

**File:** `MobileApp/app.json`

```json
{
  "expo": {
    "name": "GIS2026 Dashboard",
    "slug": "gis2026-dashboard",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "ios": {
      "bundleIdentifier": "com.gis2026.dashboard"
    },
    "android": {
      "package": "com.gis2026.dashboard",
      "permissions": [
        "CAMERA",
        "ACCESS_FINE_LOCATION",
        "ACCESS_COARSE_LOCATION",
        "READ_EXTERNAL_STORAGE",
        "WRITE_EXTERNAL_STORAGE"
      ]
    }
  }
}
```

---

## 🔄 Real-Time Synchronization Setup

### Architecture

```
Mobile App ←→ [WebSocket] ←→ Backend Server
                               ↓
                          Database (SQLite)
                               ↑
Dashboard Browser ←→ [WebSocket] ←→ Same Server
```

### Backend Socket.io Configuration

**File:** `server/index.js`

✅ **Already Configured:**
```javascript
const socketIo = require('socket.io');
const io = socketIo(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE']
  }
});
```

### Socket.io Events

**Client → Server:**
- `connect` - Client connects
- `disconnect` - Client disconnects
- `visit-update` - Visit data changed
- `user-update` - User data changed
- `outlet-update` - Outlet data changed

**Server → Client (Broadcast):**
- `visit-updated` - Notify all clients of visit change
- `user-updated` - Notify of user change
- `outlet-updated` - Notify of outlet change
- `sync-complete` - Sync operation completed

### Frontend Socket.io Setup

**Dashboard:** Uses Socket.io in React components  
**Mobile App:** Uses Socket.io for real-time updates

### Testing Real-Time Sync

1. **Start Backend:**
   ```bash
   npm start
   ```

2. **Check Logs:**
   ```bash
   pm2 logs gis2026-server
   ```

3. **Connect Multiple Clients:**
   - Open dashboard in browser
   - Login with mobile app
   - Make changes in one client
   - Verify changes appear in other clients

### Sync Scheduler

**File:** `server/utils/syncScheduler.js`

Automatic sync scheduled to:
- Run every 5 minutes
- Sync user data
- Sync outlet data
- Clean up old temporary files

**Configuration:**
```javascript
// Sync interval in milliseconds (5 minutes)
const SYNC_INTERVAL = 5 * 60 * 1000;
```

---

## ✅ Post-Deployment Testing

### Backend API Testing

**Test Login Endpoint:**
```bash
curl -X POST https://gisconnect.online/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"gis2026","password":"gis2026"}'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGc...",
  "user": {
    "id": 1,
    "username": "gis2026",
    "access_level": "admin"
  }
}
```

### Dashboard Testing

1. **Open Dashboard:**
   - URL: `https://gisconnect.online`
   - Should load login page

2. **Login Test:**
   - Username: `gis2026`
   - Password: `gis2026`
   - Should redirect to dashboard

3. **Dashboard Features:**
   - [ ] Users page loads
   - [ ] Outlets page loads
   - [ ] Visits page loads
   - [ ] Reports page loads
   - [ ] Data loads correctly
   - [ ] Excel upload works
   - [ ] Export works

### Mobile App Testing

1. **Install APK/IPA**
2. **Verify API Connection:**
   - App should connect to API
   - Check device logs for connection
3. **Test Features:**
   - [ ] Login works
   - [ ] Dashboard displays
   - [ ] Can see visits
   - [ ] Check-in works with location
   - [ ] Check-out works
   - [ ] Photo capture works
   - [ ] Real-time sync works (make changes in dashboard, see in mobile)

### Real-Time Sync Testing

1. **Open dashboard in browser**
2. **Open mobile app**
3. **Make change in dashboard (add user, add outlet)**
4. **Verify change appears in mobile app within seconds**
5. **Make change in mobile (check-in visit)**
6. **Verify change appears in dashboard in real-time**

### SSL Certificate Verification

```bash
# Check certificate
openssl s_client -connect gisconnect.online:443

# Should show: "Verify return code: 0 (ok)"
```

### Performance Testing

```bash
# Test backend response time
ab -n 100 -c 10 https://gisconnect.online/api/auth/login

# Test dashboard load time
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://gisconnect.online
```

---

## 🔧 Troubleshooting Guide

### Backend Server Issues

**Problem: Port 3000 already in use**
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

**Problem: Database file locked**
```bash
# Check file permissions
ls -la /home/www/gisconnect.online/server/database/

# Fix permissions
chmod -R 755 /home/www/gisconnect.online/server/database/
```

**Problem: CORS errors in frontend**
- Verify `CORS_ORIGIN` in `.env` matches domain
- Check `socket.io` CORS configuration
- Ensure backend is accessible from frontend domain

### Dashboard Issues

**Problem: White screen on load**
- Check browser console for errors (F12)
- Verify API_URL in `services/api.js`
- Check backend server is running
- Verify SSL certificate is valid

**Problem: API calls fail**
- Verify backend is running: `pm2 status`
- Check logs: `pm2 logs gis2026-server`
- Verify reverse proxy configuration
- Check network tab in browser DevTools

### Mobile App Issues

**Problem: Cannot connect to server**
- Verify API URL in `environment.js`
- Check device is on same network
- Verify backend is accessible
- Check firewall allows connections
- Verify port 3000 is open

**Problem: Location services not working**
- Verify location permission granted
- Check location is enabled on device
- Test with GPS turned on
- Check logs for location errors

**Problem: Camera not working**
- Verify camera permission granted
- Test camera in other apps
- Restart app
- Reinstall if necessary

### Database Issues

**Problem: Database corrupted**
```bash
# Backup and recreate
cp -r database database.backup
rm -rf database/*
npm start  # Will recreate tables
```

**Problem: Slow queries**
- Check database file permissions
- Verify no file locks
- Consider database indexing
- Check query logs

### SSL Certificate Issues

**Problem: Certificate expired**
- Renew through aapanel Let's Encrypt
- Or upload new certificate

**Problem: Mixed content warning**
- Ensure all resources load over HTTPS
- Update API URLs to HTTPS
- Check external resources

### Sync Issues

**Problem: Real-time sync not working**
- Check Socket.io connection: `io connected`
- Verify firewall allows WebSocket
- Check CORS configuration
- Review server logs

**Problem: Data not syncing**
- Verify sync scheduler is running
- Check database permissions
- Review sync logs
- Manually trigger sync

---

## 📞 Support & Monitoring

### Essential Monitoring Commands

```bash
# Monitor server status
pm2 status

# View server logs
pm2 logs gis2026-server

# Monitor CPU/Memory
pm2 monit

# Check SSL certificate
echo | openssl s_client -servername gisconnect.online -connect gisconnect.online:443 2>/dev/null | openssl x509 -noout -dates

# Test API endpoint
curl -s https://gisconnect.online/api/auth/login | head

# Check database
sqlite3 /home/www/gisconnect.online/server/database/menulogin.db ".tables"
```

### Maintenance Tasks

**Weekly:**
- [ ] Check server logs
- [ ] Monitor disk space
- [ ] Verify backups working

**Monthly:**
- [ ] Review SSL certificate expiry
- [ ] Update dependencies
- [ ] Clean old upload files
- [ ] Monitor error logs

**Quarterly:**
- [ ] Test disaster recovery
- [ ] Review security settings
- [ ] Update Node.js and packages

---

## 🔐 Security Checklist

- [ ] Change default admin password
- [ ] Configure firewall rules
- [ ] Enable SSL/HTTPS
- [ ] Set strong JWT secret
- [ ] Configure CORS for specific domains
- [ ] Enable rate limiting
- [ ] Set file upload limits
- [ ] Configure backup strategy
- [ ] Monitor access logs
- [ ] Keep dependencies updated

---

## 📖 Additional Resources

- [Express.js Documentation](https://expressjs.com/)
- [React Documentation](https://react.dev/)
- [React Native Documentation](https://reactnative.dev/)
- [Socket.io Documentation](https://socket.io/)
- [SQLite Documentation](https://www.sqlite.org/)
- [Let's Encrypt Documentation](https://letsencrypt.org/)

---

## ✨ Deployment Completed!

After following all steps:
1. Your domain `gisconnect.online` points to aapanel server
2. Backend API running on port 3000 with SSL
3. Dashboard frontend accessible via HTTPS
4. Mobile apps built and ready for distribution
5. Real-time synchronization active
6. Database configured and synced

**Access Points:**
- Dashboard: `https://gisconnect.online`
- API: `https://gisconnect.online/api`
- Mobile Apps: Download APK/IPA and install

---

**Last Updated:** 2025-12-28  
**Version:** 1.0.0  
**Status:** Ready for Production Deployment
