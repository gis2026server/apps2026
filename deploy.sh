#!/bin/bash
# Automated Deployment Script for gisconnect.online
# Run this on your Linux server to deploy the entire system

set -e  # Exit on any error

echo "=========================================="
echo "GIS Connect Deployment Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/var/www/gisconnect"
BACKUP_DIR="/var/backups/gisconnect"
DOMAIN="gisconnect.online"
EMAIL="admin@gisconnect.online"  # Change this

echo -e "${YELLOW}=== PRE-DEPLOYMENT CHECKS ===${NC}"
echo ""

# Check if running as sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

echo -e "${GREEN}✓ Running as root${NC}"

# Check if app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo -e "${RED}✗ Directory $APP_DIR does not exist${NC}"
    echo "Please clone the project first:"
    echo "  sudo mkdir -p $APP_DIR"
    echo "  cd $APP_DIR"
    echo "  git clone https://github.com/your-repo/apps2026.git ."
    exit 1
fi

echo -e "${GREEN}✓ App directory exists: $APP_DIR${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js is not installed${NC}"
    echo "Install Node.js:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
    echo "  sudo apt install -y nodejs"
    exit 1
fi
NODE_VERSION=$(node --version)
echo -e "${GREEN}✓ Node.js installed: $NODE_VERSION${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}✗ npm is not installed${NC}"
    exit 1
fi
NPM_VERSION=$(npm --version)
echo -e "${GREEN}✓ npm installed: $NPM_VERSION${NC}"

# Check Nginx
if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}⚠ Nginx not installed, installing now...${NC}"
    apt update && apt install -y nginx
fi
echo -e "${GREEN}✓ Nginx is installed${NC}"

# Check PM2
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}⚠ PM2 not installed, installing now...${NC}"
    npm install -g pm2
fi
echo -e "${GREEN}✓ PM2 is installed${NC}"

# Check Certbot
if ! command -v certbot &> /dev/null; then
    echo -e "${YELLOW}⚠ Certbot not installed, installing now...${NC}"
    apt install -y certbot python3-certbot-nginx
fi
echo -e "${GREEN}✓ Certbot is installed${NC}"

echo ""
echo -e "${YELLOW}=== INSTALLING DEPENDENCIES ===${NC}"
echo ""

# Backend dependencies
cd "$APP_DIR"
echo "Installing backend dependencies..."
npm install

# Dashboard dependencies
echo "Installing dashboard dependencies..."
cd dashboard
npm install

# Mobile app dependencies
echo "Installing mobile app dependencies..."
cd ../MobileApp
npm install

cd "$APP_DIR"

echo -e "${GREEN}✓ All dependencies installed${NC}"

echo ""
echo -e "${YELLOW}=== BUILDING DASHBOARD ===${NC}"
echo ""

cd dashboard
npm run build
cd "$APP_DIR"

if [ -d "dashboard/dist" ]; then
    echo -e "${GREEN}✓ Dashboard built successfully${NC}"
else
    echo -e "${RED}✗ Dashboard build failed${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}=== SETTING UP DIRECTORIES ===${NC}"
echo ""

# Create necessary directories
mkdir -p "$APP_DIR/databases"
mkdir -p "$APP_DIR/uploads/images"
mkdir -p "$APP_DIR/logs"
mkdir -p "$BACKUP_DIR"

# Set permissions
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"
chmod -R 775 "$APP_DIR/databases"
chmod -R 775 "$APP_DIR/uploads"
chmod -R 775 "$APP_DIR/logs"

echo -e "${GREEN}✓ Directories created${NC}"

echo ""
echo -e "${YELLOW}=== INITIALIZING DATABASE ===${NC}"
echo ""

# Initialize database if not exists
if [ ! -f "$APP_DIR/databases/datauser.db" ]; then
    echo "Running database initialization..."
    cd "$APP_DIR"
    node server/database/init.js
    echo -e "${GREEN}✓ Database initialized${NC}"
else
    echo -e "${GREEN}✓ Database already exists${NC}"
fi

echo ""
echo -e "${YELLOW}=== SETTING UP ENVIRONMENT ===${NC}"
echo ""

# Check if .env.production exists
if [ ! -f "$APP_DIR/.env.production" ]; then
    echo -e "${RED}✗ .env.production file not found${NC}"
    echo "Please create it with production values"
    exit 1
fi

# Copy .env.production to .env for production
cp "$APP_DIR/.env.production" "$APP_DIR/.env"

# Generate JWT_SECRET if not set
if grep -q "your-super-secret-jwt-key-change-this" "$APP_DIR/.env"; then
    echo -e "${YELLOW}⚠ Generating new JWT_SECRET...${NC}"
    JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    sed -i "s/your-super-secret-jwt-key-change-this.*/JWT_SECRET=$JWT_SECRET/" "$APP_DIR/.env"
    echo -e "${GREEN}✓ JWT_SECRET generated and saved${NC}"
fi

echo -e "${GREEN}✓ Environment configured${NC}"

echo ""
echo -e "${YELLOW}=== CONFIGURING NGINX ===${NC}"
echo ""

# Copy Nginx configuration
cp "$APP_DIR/nginx-gisconnect.conf" /etc/nginx/sites-available/gisconnect.online

# Create symlink if not exists
if [ ! -L /etc/nginx/sites-enabled/gisconnect.online ]; then
    ln -s /etc/nginx/sites-available/gisconnect.online /etc/nginx/sites-enabled/gisconnect.online
fi

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
if nginx -t 2>&1 | grep -q "successful"; then
    echo -e "${GREEN}✓ Nginx configuration valid${NC}"
else
    echo -e "${RED}✗ Nginx configuration invalid${NC}"
    nginx -t
    exit 1
fi

# Restart Nginx
systemctl restart nginx
echo -e "${GREEN}✓ Nginx restarted${NC}"

echo ""
echo -e "${YELLOW}=== SETTING UP SSL CERTIFICATE ===${NC}"
echo ""

# Check if certificate already exists
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo -e "${GREEN}✓ SSL certificate already exists${NC}"
else
    echo "Requesting SSL certificate from Let's Encrypt..."
    certbot certonly --nginx -d "$DOMAIN" -d "api.$DOMAIN" -d "app.$DOMAIN" -d "www.$DOMAIN" -m "$EMAIL" --agree-tos -n
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ SSL certificate obtained${NC}"
        systemctl restart nginx
    else
        echo -e "${RED}✗ Failed to obtain SSL certificate${NC}"
        echo "Run manually: sudo certbot certonly --nginx -d $DOMAIN"
        exit 1
    fi
fi

# Setup auto-renewal
systemctl enable certbot.timer
systemctl start certbot.timer
echo -e "${GREEN}✓ SSL auto-renewal configured${NC}"

echo ""
echo -e "${YELLOW}=== STARTING BACKEND WITH PM2 ===${NC}"
echo ""

# Create PM2 ecosystem config
cat > "$APP_DIR/ecosystem.config.js" << 'EOF'
module.exports = {
  apps: [
    {
      name: 'gisconnect-api',
      script: '/var/www/gisconnect/server/index.js',
      cwd: '/var/www/gisconnect',
      env: {
        NODE_ENV: 'production'
      },
      instances: 'max',
      exec_mode: 'cluster',
      max_memory_restart: '512M',
      error_file: '/var/www/gisconnect/logs/error.log',
      out_file: '/var/www/gisconnect/logs/out.log',
      log_file: '/var/www/gisconnect/logs/combined.log',
      time_format: 'YYYY-MM-DD HH:mm:ss Z',
      autorestart: true,
      watch: false,
      max_restarts: 10,
      min_uptime: '10s',
      merge_logs: true
    }
  ]
};
EOF

# Start PM2
cd "$APP_DIR"
pm2 delete gisconnect-api 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

# Setup auto-startup
pm2 startup systemd -u root --hp /root
echo -e "${GREEN}✓ PM2 configured for auto-startup${NC}"

# Wait for backend to start
sleep 3

# Verify backend is running
if pm2 list | grep -q "gisconnect-api"; then
    echo -e "${GREEN}✓ Backend started with PM2${NC}"
else
    echo -e "${RED}✗ Failed to start backend${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}=== SETTING UP BACKUPS ===${NC}"
echo ""

# Create backup script
cat > /usr/local/bin/backup-gisconnect.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/gisconnect"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/gisconnect_$DATE.tar.gz" /var/www/gisconnect/databases/ 2>/dev/null || true
find "$BACKUP_DIR" -name "gisconnect_*.tar.gz" -mtime +30 -delete
EOF

chmod +x /usr/local/bin/backup-gisconnect.sh

# Add to crontab
(crontab -l 2>/dev/null | grep -v "backup-gisconnect" || true; echo "0 2 * * * /usr/local/bin/backup-gisconnect.sh") | crontab -

echo -e "${GREEN}✓ Backup script configured${NC}"

echo ""
echo -e "${YELLOW}=== CONFIGURING FIREWALL ===${NC}"
echo ""

# Enable UFW if not already
ufw --force enable 2>/dev/null || true

# Allow required ports
ufw allow 22/tcp > /dev/null 2>&1 || true
ufw allow 80/tcp > /dev/null 2>&1 || true
ufw allow 443/tcp > /dev/null 2>&1 || true

echo -e "${GREEN}✓ Firewall configured${NC}"

echo ""
echo -e "${GREEN}=========================================="
echo "✓ DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Verify DNS records are set up:"
echo "   - gisconnect.online → YOUR_SERVER_IP"
echo "   - api.gisconnect.online → YOUR_SERVER_IP"
echo "   - app.gisconnect.online → YOUR_SERVER_IP"
echo ""
echo "2. Wait 5-15 minutes for DNS propagation"
echo ""
echo "3. Test the system:"
echo "   - Dashboard: https://gisconnect.online"
echo "   - API: https://api.gisconnect.online/health"
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo "View backend logs:       pm2 logs gisconnect-api"
echo "PM2 status:              pm2 status"
echo "Restart backend:         pm2 restart gisconnect-api"
echo "View Nginx logs:         tail -f /var/log/nginx/gisconnect-*-access.log"
echo "Check SSL cert:          sudo certbot certificates"
echo ""
echo -e "${YELLOW}Admin Panel:${NC}"
echo "Login to dashboard with your credentials"
echo "URL: https://gisconnect.online"
echo ""
