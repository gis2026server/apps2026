#!/bin/bash

# GIS2026 Complete Backend Deployment Script
# Deploys backend server to production aapanel
# Usage: bash deploy-backend.sh

set -e

echo "🚀 GIS2026 Backend Deployment Script"
echo "===================================="
echo ""

# Configuration
DOMAIN="gisconnect.online"
DEPLOY_PATH="/home/www/gisconnect.online"
SERVER_PORT=3000
NODE_VERSION="v14.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: Check Prerequisites
echo "Step 1: Checking Prerequisites..."
echo "=================================="

if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed"
    exit 1
fi
NODE_VERSION=$(node -v)
log_info "Node.js version: $NODE_VERSION"

if ! command -v npm &> /dev/null; then
    log_error "npm is not installed"
    exit 1
fi
NPM_VERSION=$(npm -v)
log_info "npm version: $NPM_VERSION"

if ! command -v pm2 &> /dev/null; then
    log_warn "PM2 is not installed globally. Installing..."
    npm install -g pm2
fi
PM2_VERSION=$(pm2 -v)
log_info "PM2 version: $PM2_VERSION"

echo ""

# Step 2: Prepare Server Directory
echo "Step 2: Preparing Server Directory..."
echo "===================================="

if [ ! -d "$DEPLOY_PATH/server" ]; then
    log_error "Server directory not found at $DEPLOY_PATH/server"
    exit 1
fi

log_info "Server directory exists: $DEPLOY_PATH/server"

# Create necessary directories
mkdir -p "$DEPLOY_PATH/server/database"
mkdir -p "$DEPLOY_PATH/server/uploads/excel"
mkdir -p "$DEPLOY_PATH/server/uploads/images"
mkdir -p "$DEPLOY_PATH/logs"

log_info "Created necessary directories"

# Set permissions
chmod -R 755 "$DEPLOY_PATH/server/database"
chmod -R 755 "$DEPLOY_PATH/server/uploads"
chmod -R 755 "$DEPLOY_PATH/logs"

log_info "Set directory permissions"

echo ""

# Step 3: Install Dependencies
echo "Step 3: Installing Dependencies..."
echo "===================================="

cd "$DEPLOY_PATH/server"

log_info "Installing npm packages..."
npm install --production --quiet

log_info "Dependencies installed"

echo ""

# Step 4: Verify Environment File
echo "Step 4: Verifying Environment File..."
echo "===================================="

if [ ! -f "$DEPLOY_PATH/server/.env" ]; then
    log_warn ".env file not found. Creating from template..."
    
    if [ ! -f "$DEPLOY_PATH/server/.env.example" ]; then
        log_error "No .env or .env.example file found"
        exit 1
    fi
    
    cp "$DEPLOY_PATH/server/.env.example" "$DEPLOY_PATH/server/.env"
    log_info "Created .env from template"
    log_warn "⚠️  IMPORTANT: Edit .env and update the following:"
    log_warn "  - JWT_SECRET (change to a long random string)"
    log_warn "  - DATABASE credentials if needed"
    log_warn "  - CORS_ORIGIN (should be https://gisconnect.online)"
else
    log_info ".env file exists"
fi

echo ""

# Step 5: Setup PM2
echo "Step 5: Setting Up PM2 Process Manager..."
echo "=========================================="

# Stop existing process if running
pm2 stop gis2026-server 2>/dev/null || true

# Delete from PM2 list
pm2 delete gis2026-server 2>/dev/null || true

# Copy ecosystem config if exists
if [ -f "$DEPLOY_PATH/ecosystem.config.js" ]; then
    log_info "Using ecosystem.config.js for PM2"
    cd "$DEPLOY_PATH"
    pm2 start ecosystem.config.js
else
    log_warn "ecosystem.config.js not found. Starting with default config..."
    cd "$DEPLOY_PATH/server"
    pm2 start index.js --name gis2026-server --instances 2 --exec-mode cluster
fi

log_info "PM2 process started"

echo ""

# Step 6: Setup PM2 Startup
echo "Step 6: Setting Up PM2 Auto-Startup..."
echo "======================================"

pm2 startup systemd -u www-data --hp /var/www 2>/dev/null || true
pm2 save

log_info "PM2 startup configured"

echo ""

# Step 7: Verify Server Status
echo "Step 7: Verifying Server Status..."
echo "=================================="

# Wait a moment for server to start
sleep 2

if pm2 status | grep -q "gis2026-server.*online"; then
    log_info "✅ Server is running!"
else
    log_error "Server failed to start"
    echo ""
    log_info "Checking logs:"
    pm2 logs gis2026-server --lines 20
    exit 1
fi

echo ""

# Step 8: Display Summary
echo "Step 8: Deployment Summary"
echo "=========================="

echo ""
log_info "✅ Backend deployment complete!"
echo ""
echo "Server Information:"
echo "  Domain: $DOMAIN"
echo "  Port: $SERVER_PORT"
echo "  Path: $DEPLOY_PATH/server"
echo ""
echo "Useful Commands:"
echo "  View status:  pm2 status"
echo "  View logs:    pm2 logs gis2026-server"
echo "  Monitor:      pm2 monit"
echo "  Restart:      pm2 restart gis2026-server"
echo "  Stop:         pm2 stop gis2026-server"
echo ""
echo "Test the API:"
echo "  curl -X POST https://$DOMAIN/api/auth/login \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"username\":\"gis2026\",\"password\":\"gis2026\"}'"
echo ""
log_warn "Next Steps:"
log_warn "1. Verify server is running: pm2 status"
log_warn "2. Check logs: pm2 logs gis2026-server"
log_warn "3. Test API endpoint"
log_warn "4. Deploy dashboard frontend"
echo ""
