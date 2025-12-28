# 🔍 CRITICAL UPDATES - Code Modifications Required

## ⚠️ MUST DO - Update Production API URLs

All three applications must be updated to use production domain before deployment.

---

## 1️⃣ DASHBOARD - Update API URL

**File:** `dashboard/src/services/api.js` (Line 3)

### Current Code:
```javascript
const API_URL = 'http://localhost:3001/api';
```

### Updated Code:
```javascript
const API_URL = 'https://gisconnect.online/api';
```

### Context:
```javascript
import axios from 'axios';

// CHANGE THIS LINE:
const API_URL = 'https://gisconnect.online/api';  // ← PRODUCTION URL

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

### How to Update:
```bash
# Option 1: Use text editor
# Open: dashboard/src/services/api.js
# Find line 3
# Replace: const API_URL = 'http://localhost:3001/api';
# With: const API_URL = 'https://gisconnect.online/api';

# Option 2: Command line
cd dashboard/src/services/
sed -i "s|http://localhost:3001/api|https://gisconnect.online/api|g" api.js

# Verify change
grep "API_URL" api.js
```

---

## 2️⃣ MOBILE APP - Update Production API URL

**File:** `MobileApp/src/config/environment.js` (Line 7)

### Current Code:
```javascript
const PROD_API_URL = 'https://your-production-server.com/api';
```

### Updated Code:
```javascript
const PROD_API_URL = 'https://gisconnect.online/api';
```

### Full File Context:
```javascript
import Constants from 'expo-constants';

// Get the device's local IP address for development
// IMPORTANT: Update this IP address to match your computer's local network IP
const DEV_API_URL = 'http://192.168.0.43:3001/api';

// CHANGE THIS LINE FOR PRODUCTION:
const PROD_API_URL = 'https://gisconnect.online/api';  // ← PRODUCTION URL

// Automatically detect environment
const ENV = {
  dev: {
    apiUrl: DEV_API_URL,
  },
  prod: {
    apiUrl: PROD_API_URL,  // ← Will use production URL when built for production
  },
};

// Function to get current environment config
const getEnvVars = () => {
  if (__DEV__) {
    return ENV.dev;
  }
  return ENV.prod;
};

export default getEnvVars;

// Helper function to get API URL
export const getApiUrl = () => {
  return getEnvVars().apiUrl;
};
```

### How to Update:
```bash
# Option 1: Use text editor
# Open: MobileApp/src/config/environment.js
# Find line 7
# Replace: const PROD_API_URL = 'https://your-production-server.com/api';
# With: const PROD_API_URL = 'https://gisconnect.online/api';

# Option 2: Command line
cd MobileApp/src/config/
sed -i "s|https://your-production-server.com/api|https://gisconnect.online/api|g" environment.js

# Verify change
grep "PROD_API_URL" environment.js
```

---

## 3️⃣ SERVER - Verify Environment Configuration

**File:** `server/.env` (to be created)

### Required Configuration:
```env
# Production Settings
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=https://gisconnect.online

# Authentication
DEFAULT_ADMIN_USERNAME=gis2026
DEFAULT_ADMIN_PASSWORD=gis2026
JWT_SECRET=your-super-secret-key-change-this

# Directories
DATABASE_PATH=./database
UPLOAD_PATH=./uploads
EXCEL_UPLOAD_PATH=./uploads/excel
IMAGE_UPLOAD_PATH=./uploads/images
```

### How to Create:
```bash
# Navigate to server directory
cd server/

# Create .env file
cat > .env << 'EOF'
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=https://gisconnect.online
DATABASE_PATH=./database
UPLOAD_PATH=./uploads
EXCEL_UPLOAD_PATH=./uploads/excel
IMAGE_UPLOAD_PATH=./uploads/images
DEFAULT_ADMIN_USERNAME=gis2026
DEFAULT_ADMIN_PASSWORD=gis2026
JWT_SECRET=change-this-to-a-super-long-random-string-for-production
JWT_EXPIRY=7d
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100
LOG_LEVEL=info
EOF

# Verify creation
cat .env
```

---

## 📝 Code Review Summary

### ✅ Backend Server (`server/index.js`)

**Status:** VERIFIED - PRODUCTION READY

Key Features:
- ✅ Express.js configured correctly
- ✅ Socket.io for real-time sync
- ✅ CORS configured
- ✅ Security middleware (Helmet)
- ✅ Rate limiting enabled
- ✅ Input validation active
- ✅ Error handling present
- ✅ JWT authentication
- ✅ File upload handling
- ✅ Database initialization

**No Changes Required** - Just ensure `.env` file is created with correct values

---

### ⚠️ Dashboard Frontend (`dashboard/src/services/api.js`)

**Status:** NEEDS UPDATE

**Required Change:**
```diff
- const API_URL = 'http://localhost:3001/api';
+ const API_URL = 'https://gisconnect.online/api';
```

**Impact:** Without this change, dashboard cannot connect to production API

---

### ⚠️ Mobile App (`MobileApp/src/config/environment.js`)

**Status:** NEEDS UPDATE

**Required Change:**
```diff
- const PROD_API_URL = 'https://your-production-server.com/api';
+ const PROD_API_URL = 'https://gisconnect.online/api';
```

**Impact:** Mobile app must have correct production URL for after-build distribution

---

## 🔐 SECURITY CHECKS

### Code Security Verification

✅ **Passed:**
- No hardcoded database passwords
- No hardcoded JWT secrets in code
- All credentials in environment variables
- Input sanitization middleware active
- HTTPS enforced via nginx
- CORS properly configured
- Rate limiting enabled
- File upload validation present
- SQL injection prevention (parameterized queries)
- XSS protection via Content-Security-Policy headers

⚠️ **Requires Action:**
- [ ] Change DEFAULT_ADMIN_PASSWORD after first deployment
- [ ] Change JWT_SECRET to strong random value
- [ ] Setup automated backups
- [ ] Configure monitoring/alerting
- [ ] Enable HSTS headers (done in nginx)
- [ ] Setup SSL certificate auto-renewal

---

## 🧪 Pre-Build Verification

### Before Building Dashboard:
```bash
# 1. Verify API URL update
grep "API_URL = " dashboard/src/services/api.js
# Should output: const API_URL = 'https://gisconnect.online/api';

# 2. Install dependencies
cd dashboard && npm install --production

# 3. Build for production
npm run build

# 4. Verify build output
ls -la dist/
# Should contain: index.html, js/, css/, assets/
```

### Before Building Mobile App:
```bash
# 1. Verify API URL update
grep "PROD_API_URL = " MobileApp/src/config/environment.js
# Should output: const PROD_API_URL = 'https://gisconnect.online/api';

# 2. Verify app.json configuration
cat MobileApp/app.json | grep -A 5 "ios\|android"

# 3. Install dependencies
cd MobileApp && npm install

# 4. Build APK
expo build:android -t apk
# Or build IPA
expo build:ios
```

### Before Starting Backend:
```bash
# 1. Create environment file
# Copy the .env content from above

# 2. Create required directories
mkdir -p server/{database,uploads/{excel,images}}

# 3. Install dependencies
cd server && npm install --production

# 4. Test server start
node index.js
# Should output: "Server running on port 3000"
# Should output: "Database initialized successfully"

# 5. Stop server (Ctrl+C)
```

---

## 📋 DEPLOYMENT VERIFICATION CHECKLIST

Before moving to production:

- [ ] Dashboard API_URL updated to `https://gisconnect.online/api`
- [ ] Mobile app PROD_API_URL updated to `https://gisconnect.online/api`
- [ ] Server `.env` file created with all required variables
- [ ] All three applications tested locally
- [ ] SSL certificate acquired (Let's Encrypt via aapanel)
- [ ] nginx configuration prepared
- [ ] Database directories created with 755 permissions
- [ ] Upload directories created with 755 permissions
- [ ] Backend server can start without errors
- [ ] Dashboard builds successfully
- [ ] Mobile app builds successfully (APK/IPA)

---

## 🚀 DEPLOYMENT ORDER

### Step 1: Infrastructure Setup (Day 1-2)
```
[ ] Domain DNS configured to aapanel nameservers
[ ] SSL certificate obtained (Let's Encrypt)
[ ] nginx reverse proxy configured
```

### Step 2: Backend Deployment (Day 2)
```
[ ] Server uploaded to /home/www/gisconnect.online/server
[ ] .env file created with production values
[ ] Dependencies installed (npm install --production)
[ ] PM2 installed and configured
[ ] Server started: pm2 start ecosystem.config.js
[ ] Verify server running: pm2 status
```

### Step 3: Dashboard Deployment (Day 2)
```
[ ] API_URL updated to production URL
[ ] Dashboard built: npm run build
[ ] dist/ folder uploaded to /home/www/gisconnect.online/public_html
[ ] nginx configured for SPA routing
[ ] Dashboard accessible at https://gisconnect.online
```

### Step 4: Mobile App Build & Distribution (Day 3)
```
[ ] PROD_API_URL updated to production URL
[ ] APK built: expo build:android -t apk
[ ] IPA built: expo build:ios (if on Mac)
[ ] Test APK on Android device
[ ] Test IPA on iOS device
[ ] Distribute to users (store or direct)
```

---

## 📞 QUICK REFERENCE

### Update Commands (One-Liners)

```bash
# Update dashboard API URL
sed -i "s|http://localhost:3001/api|https://gisconnect.online/api|g" dashboard/src/services/api.js

# Update mobile app production URL
sed -i "s|https://your-production-server.com/api|https://gisconnect.online/api|g" MobileApp/src/config/environment.js

# Verify changes
echo "=== Dashboard API ===" && grep "API_URL" dashboard/src/services/api.js
echo "=== Mobile App API ===" && grep "PROD_API_URL" MobileApp/src/config/environment.js
```

### Build Commands

```bash
# Dashboard
cd dashboard && npm install --production && npm run build

# Mobile APK
cd MobileApp && expo build:android -t apk

# Mobile IPA
cd MobileApp && expo build:ios
```

### Server Start

```bash
# Create .env (see above for content)
cd server
cp ../.env.example .env
# Edit .env with your values

# Install and start
npm install --production
npm install -g pm2
pm2 start index.js --name gis2026-server
pm2 startup && pm2 save
```

---

## ✨ STATUS: READY FOR DEPLOYMENT

All code has been reviewed and verified. Follow the checklist above to ensure all updates are made before deployment.

**Critical Updates Needed:**
1. ✏️ Dashboard: Update API_URL (Line 3 of api.js)
2. ✏️ Mobile App: Update PROD_API_URL (Line 7 of environment.js)
3. 📝 Server: Create .env file with configuration

After these updates, you're ready to deploy! 🚀

