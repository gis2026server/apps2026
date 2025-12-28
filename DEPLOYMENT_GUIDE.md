# Complete Deployment Guide for gisconnect.online

## Overview
This guide covers deploying a complete distributed system with:
- **Backend API Server** (Node.js/Express + SQLite)
- **Database** (SQLite in production)
- **Web Dashboard** (React 18 + Vite)
- **Mobile Apps** (React Native/Expo - iOS/Android)
- **Real-time Sync** (Socket.IO WebSocket)
- **Domain**: gisconnect.online

## Architecture

```
gisconnect.online (Root Domain)
├── api.gisconnect.online → Backend API (Port 3000)
├── app.gisconnect.online → Web Dashboard (Port 5173/Build)
├── database → SQLite (./databases/)
└── Mobile Apps → Direct API connection to api.gisconnect.online
```

---

## Phase 1: DNS Configuration

### DNS Records Setup
Add these DNS A records with your DNS provider (currently dns-parking.com):

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | gisconnect.online | YOUR_SERVER_IP | 3600 |
| A | api.gisconnect.online | YOUR_SERVER_IP | 3600 |
| A | app.gisconnect.online | YOUR_SERVER_IP | 3600 |
| CNAME | www.gisconnect.online | gisconnect.online | 3600 |

**Steps with dns-parking.com:**
1. Login to your dns-parking.com account
2. Navigate to **DNS Settings** → **Edit DNS Records**
3. Add the above A records pointing to your server's IP
4. Wait 5-15 minutes for DNS propagation

### Verify DNS Propagation
```bash
nslookup gisconnect.online
nslookup api.gisconnect.online
```

---

## Phase 2: Server Setup (Linux/Ubuntu 20.04 LTS)

### Prerequisites
Ensure you have root/sudo access to a Linux server with:
- **OS**: Ubuntu 20.04 LTS or later
- **RAM**: 2GB minimum (4GB recommended)
- **Storage**: 20GB minimum
- **Ports**: 80, 443 (HTTP/HTTPS), 3000 (Backend)

### System Update
```bash
sudo apt update && sudo apt upgrade -y
```

### Install Required Tools
```bash
# Node.js & npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Nginx (Web Server & Reverse Proxy)
sudo apt install -y nginx

# Certbot (Let's Encrypt HTTPS)
sudo apt install -y certbot python3-certbot-nginx

# Git
sudo apt install -y git

# PM2 (Process Manager)
sudo npm install -g pm2

# SQLite (Optional - comes with Node sqlite3 module)
sudo apt install -y sqlite3

# Check versions
node --version  # v18.x.x
npm --version   # 9.x.x
nginx -v
certbot --version
pm2 --version
```

---

## Phase 3: Project Setup on Server

### Clone/Upload Project
```bash
# Create app directory
sudo mkdir -p /var/www/gisconnect
cd /var/www/gisconnect

# Option A: Clone from Git
git clone https://github.com/your-username/apps2026.git .

# Option B: Upload via SFTP/SCP
scp -r /local/path/to/apps2026/* user@server:/var/www/gisconnect/
```

### Setup Backend
```bash
cd /var/www/gisconnect

# Install dependencies
npm install

# Create production .env file
cat > .env << 'EOF'
# Server Configuration
NODE_ENV=production
PORT=3000

# CORS Configuration
CORS_ORIGIN=https://gisconnect.online,https://app.gisconnect.online,https://api.gisconnect.online

# Database Configuration
DB_PATH=/var/www/gisconnect/databases

# JWT Secret (CHANGE THIS!)
JWT_SECRET=your-super-secret-jwt-key-change-this-to-random-string-min-32-chars

# Upload Configuration
UPLOAD_PATH=/var/www/gisconnect/uploads

# Sync Scheduler (Cron format)
SYNC_SCHEDULE_1=0 12 * * *  # 12:00 PM
SYNC_SCHEDULE_2=0 18 * * *  # 6:00 PM

# Enable HTTPS
HTTPS_ENABLED=true
EOF

# Create necessary directories
mkdir -p databases uploads uploads/images

# Initialize database
node server/database/init.js

# Test the backend
npm run dev  # Press Ctrl+C after confirming it starts on port 3000
```

### Setup Dashboard
```bash
cd /var/www/gisconnect/dashboard

# Install dependencies
npm install

# Create .env for production
cat > .env.production << 'EOF'
VITE_API_URL=https://api.gisconnect.online
VITE_SOCKET_URL=https://api.gisconnect.online
EOF

# Build the dashboard
npm run build

# Verify build output
ls -la dist/
```

### Setup Mobile App
```bash
cd /var/www/gisconnect/MobileApp

# Install dependencies
npm install

# Create production config
cat > src/config/api.js << 'EOF'
export const API_CONFIG = {
  API_BASE_URL: 'https://api.gisconnect.online/api',
  SOCKET_URL: 'https://api.gisconnect.online',
  TIMEOUT: 30000,
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 2000
};

export const APP_VERSION = '1.0.0';
export const ENVIRONMENT = 'production';
EOF

# Test build
npm run build:android  # Or build:ios
```

---

## Phase 4: Nginx Configuration

### Create Nginx Configuration
```bash
sudo cat > /etc/nginx/sites-available/gisconnect.online << 'EOF'
# Upstream backend
upstream backend {
    server localhost:3000;
    keepalive 64;
}

# HTTP to HTTPS Redirect
server {
    listen 80;
    listen [::]:80;
    server_name gisconnect.online api.gisconnect.online app.gisconnect.online www.gisconnect.online;
    
    location / {
        return 301 https://$server_name$request_uri;
    }
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}

# Main HTTPS Server (API + Web)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.gisconnect.online;
    
    # SSL Configuration (Will be populated by Certbot)
    ssl_certificate /etc/letsencrypt/live/gisconnect.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gisconnect.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;
    
    # API Routes
    location /api/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
        proxy_connect_timeout 30s;
    }
    
    # WebSocket for Real-time Sync
    location /socket.io {
        proxy_pass http://backend/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # Uploads
    location /uploads/ {
        alias /var/www/gisconnect/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Health Check
    location /health {
        proxy_pass http://backend/health;
        proxy_read_timeout 5s;
        proxy_connect_timeout 5s;
    }
}

# Dashboard HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name app.gisconnect.online gisconnect.online www.gisconnect.online;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/gisconnect.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gisconnect.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml;
    
    root /var/www/gisconnect/dashboard/dist;
    index index.html;
    
    # Cache busting for SPA
    location ~* \.(?:html)$ {
        expires -1;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }
    
    # Cache assets
    location ~* \.(?:js|css|svg|gif|png|jpg|jpeg|eot|ttf|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # SPA Fallback
    location / {
        try_files $uri /index.html;
    }
}
EOF
```

### Enable Nginx Site
```bash
# Create symlink
sudo ln -s /etc/nginx/sites-available/gisconnect.online /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## Phase 5: SSL/HTTPS Setup (Let's Encrypt)

### Get SSL Certificate
```bash
# Get certificate for all domains
sudo certbot certonly --nginx -d gisconnect.online -d api.gisconnect.online -d app.gisconnect.online -d www.gisconnect.online

# Follow prompts:
# - Enter email for notifications
# - Agree to terms
# - Choose "Agree" for EFF sharing

# Auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Verify auto-renewal
sudo certbot renew --dry-run
```

### Verify HTTPS
```bash
curl -I https://gisconnect.online
curl -I https://api.gisconnect.online
curl -I https://app.gisconnect.online
```

---

## Phase 6: Process Management with PM2

### Create PM2 Ecosystem Config
```bash
cat > /var/www/gisconnect/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'backend-api',
      script: '/var/www/gisconnect/server/index.js',
      cwd: '/var/www/gisconnect',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      instances: 'max',
      exec_mode: 'cluster',
      max_memory_restart: '512M',
      error_file: '/var/www/gisconnect/logs/backend-error.log',
      out_file: '/var/www/gisconnect/logs/backend-out.log',
      log_file: '/var/www/gisconnect/logs/backend-combined.log',
      time_format: 'YYYY-MM-DD HH:mm:ss Z',
      autorestart: true,
      watch: false,
      max_restarts: 10,
      min_uptime: '10s'
    }
  ]
};
EOF

# Create logs directory
mkdir -p /var/www/gisconnect/logs

# Start with PM2
cd /var/www/gisconnect
pm2 start ecosystem.config.js

# Save PM2 process list
pm2 save

# Setup auto-start on system reboot
sudo pm2 startup systemd -u $(whoami) --hp /home/$(whoami)
sudo pm2 startup

# Verify PM2 status
pm2 status
pm2 logs backend-api
```

---

## Phase 7: Real-time Synchronization Setup

### Enable Socket.IO for Dashboard & Mobile
The backend already has Socket.IO configured. Ensure:

1. **Backend (server/index.js)** - Already configured:
   ```javascript
   const io = socketIo(server, {
     cors: {
       origin: process.env.CORS_ORIGIN,
       methods: ['GET', 'POST', 'PUT', 'DELETE']
     }
   });
   ```

2. **Dashboard** - Update API client:
   ```javascript
   // dashboard/src/services/api.js
   import io from 'socket.io-client';
   
   const socket = io(import.meta.env.VITE_SOCKET_URL, {
     transports: ['websocket', 'polling'],
     reconnection: true,
     reconnectionDelay: 1000,
     reconnectionDelayMax: 5000,
     reconnectionAttempts: 5
   });
   ```

3. **Mobile App** - Update config:
   ```javascript
   // MobileApp/src/config/api.js
   import io from 'socket.io-client';
   
   export const socket = io(API_CONFIG.SOCKET_URL, {
     transports: ['websocket'],
     reconnection: true,
     reconnectionDelay: 1000,
     reconnectionAttempts: 5,
     extraHeaders: {
       Authorization: `Bearer ${token}`
     }
   });
   ```

### Real-time Event Flow
```
Mobile App (Field)
    ↓
  GPS Capture + Photos
    ↓
  Send to Backend (api.gisconnect.online)
    ↓
  Backend stores + broadcasts via Socket.IO
    ↓
  Dashboard receives update (real-time)
    ↓
  Display updated visit status immediately
```

---

## Phase 8: Mobile-Responsive Dashboard

### Update Dashboard for Mobile Devices
See [MOBILE_DASHBOARD_GUIDE.md](./MOBILE_DASHBOARD_GUIDE.md) for:
- Responsive design improvements
- Touch-friendly UI
- Mobile navigation
- Optimized for iOS & Android browsers

---

## Phase 9: Firewall & Security

### Configure Firewall (UFW)
```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS
sudo ufw allow 443/tcp

# Verify rules
sudo ufw status

# Output should show:
# 22/tcp                     ALLOW
# 80/tcp                     ALLOW
# 443/tcp                    ALLOW
```

### Backup Configuration
```bash
# Create backup directory
mkdir -p /var/backups/gisconnect

# Daily database backup script
cat > /usr/local/bin/backup-gisconnect.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/gisconnect"
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf "$BACKUP_DIR/gisconnect_$DATE.tar.gz" /var/www/gisconnect/databases/
find "$BACKUP_DIR" -name "gisconnect_*.tar.gz" -mtime +30 -delete
EOF

chmod +x /usr/local/bin/backup-gisconnect.sh

# Add to crontab
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/backup-gisconnect.sh
```

---

## Phase 10: Monitoring & Logs

### View Logs
```bash
# Backend logs
pm2 logs backend-api

# Nginx access logs
tail -f /var/log/nginx/access.log

# Nginx error logs
tail -f /var/log/nginx/error.log

# System logs
journalctl -u pm2-root -f
```

### Health Check
```bash
# Check backend
curl -I https://api.gisconnect.online/health

# Check dashboard
curl -I https://app.gisconnect.online

# Check SSL
echo | openssl s_client -servername gisconnect.online -connect gisconnect.online:443 2>/dev/null | openssl x509 -noout -dates
```

---

## Deployment Checklist

- [ ] DNS records configured (gisconnect.online + subdomains)
- [ ] DNS propagation verified (5-15 minutes)
- [ ] Linux server provisioned (Ubuntu 20.04+)
- [ ] All tools installed (Node, Nginx, PM2, Certbot)
- [ ] Project cloned/uploaded to server
- [ ] Backend .env configured with production values
- [ ] Database initialized
- [ ] Dashboard built for production
- [ ] Mobile app config updated
- [ ] Nginx configured and tested
- [ ] SSL certificates obtained (Let's Encrypt)
- [ ] PM2 started and auto-startup configured
- [ ] Firewall rules configured
- [ ] HTTPS verified (all domains)
- [ ] Real-time sync tested (Socket.IO)
- [ ] Mobile access tested from external network
- [ ] Backups configured

---

## Rollback Procedure

If something goes wrong:

```bash
# Stop PM2
pm2 stop backend-api

# View previous working state
git log --oneline

# Restore from backup
cd /var/www/gisconnect
tar -xzf /var/backups/gisconnect/gisconnect_TIMESTAMP.tar.gz

# Restart
pm2 start ecosystem.config.js
```

---

## Contact & Support

For issues:
1. Check logs: `pm2 logs backend-api`
2. Verify DNS: `nslookup api.gisconnect.online`
3. Test API: `curl -I https://api.gisconnect.online/health`
4. Check SSL: `sudo certbot certificates`

---

**Deployment completed! Your system is now live at:**
- 🌐 **Dashboard**: https://gisconnect.online or https://app.gisconnect.online
- 📱 **Mobile Apps**: Connected to https://api.gisconnect.online
- 🔌 **Real-time Sync**: WebSocket via https://api.gisconnect.online
