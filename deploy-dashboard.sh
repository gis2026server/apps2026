#!/bin/bash

# GIS2026 Complete Dashboard Deployment Script
# Builds and deploys React dashboard to production
# Usage: bash deploy-dashboard.sh

set -e

echo "🎨 GIS2026 Dashboard Deployment Script"
echo "====================================="
echo ""

# Configuration
DOMAIN="gisconnect.online"
SOURCE_PATH="./dashboard"
DEPLOY_PATH="/home/www/gisconnect.online/public_html"
BUILD_OUTPUT="dist"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

echo "Step 1: Checking Prerequisites..."
echo "=================================="

if [ ! -d "$SOURCE_PATH" ]; then
    log_error "Dashboard source directory not found: $SOURCE_PATH"
    exit 1
fi

log_info "Dashboard source directory found"

if [ ! -f "$SOURCE_PATH/package.json" ]; then
    log_error "package.json not found in dashboard directory"
    exit 1
fi

log_info "package.json found"

echo ""

echo "Step 2: Verifying API Configuration..."
echo "======================================="

if grep -q "https://gisconnect.online/api" "$SOURCE_PATH/src/services/api.js"; then
    log_info "API URL correctly configured for production"
else
    log_error "API URL not configured for production!"
    log_warn "Expected: https://gisconnect.online/api"
    log_warn "Please update: $SOURCE_PATH/src/services/api.js"
    exit 1
fi

echo ""

echo "Step 3: Installing Dependencies..."
echo "===================================="

cd "$SOURCE_PATH"

log_info "Installing npm packages..."
npm install --production --quiet

log_info "Dependencies installed"

echo ""

echo "Step 4: Building for Production..."
echo "=================================="

log_info "Running build process..."
npm run build

if [ ! -d "$BUILD_OUTPUT" ]; then
    log_error "Build failed - dist directory not created"
    exit 1
fi

log_info "Build completed successfully"

# Count files
FILE_COUNT=$(find "$BUILD_OUTPUT" -type f | wc -l)
log_info "Generated $FILE_COUNT files in dist/"

echo ""

echo "Step 5: Preparing Deployment..."
echo "==============================="

# Create backup of current deployment
if [ -d "$DEPLOY_PATH" ] && [ "$(ls -A $DEPLOY_PATH)" ]; then
    BACKUP_PATH="${DEPLOY_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
    log_warn "Creating backup of current deployment: $BACKUP_PATH"
    cp -r "$DEPLOY_PATH" "$BACKUP_PATH"
    log_info "Backup created"
fi

echo ""

echo "Step 6: Deploying Files..."
echo "=========================="

# Create deploy directory if it doesn't exist
mkdir -p "$DEPLOY_PATH"

# Copy build files to deployment location
log_info "Copying build files to: $DEPLOY_PATH"
cp -r "$BUILD_OUTPUT"/* "$DEPLOY_PATH/"

log_info "Files deployed"

# Set correct permissions
chmod -R 755 "$DEPLOY_PATH"
log_info "Permissions set"

echo ""

echo "Step 7: Verifying Deployment..."
echo "==============================="

# Check if index.html exists
if [ ! -f "$DEPLOY_PATH/index.html" ]; then
    log_error "Deployment verification failed - index.html not found"
    exit 1
fi

log_info "index.html exists"

# Count deployed files
DEPLOYED_COUNT=$(find "$DEPLOY_PATH" -type f | wc -l)
log_info "Deployed $DEPLOYED_COUNT files"

echo ""

echo "Step 8: Deployment Summary"
echo "=========================="

echo ""
log_info "✅ Dashboard deployment complete!"
echo ""
echo "Deployment Information:"
echo "  Domain: https://$DOMAIN"
echo "  Deploy Path: $DEPLOY_PATH"
echo "  Files: $DEPLOYED_COUNT"
echo "  Build Output: $BUILD_OUTPUT"
echo ""

log_warn "Next Steps:"
log_warn "1. Verify nginx is configured correctly"
log_warn "2. Test dashboard access: https://$DOMAIN"
log_warn "3. Login with: gis2026 / gis2026"
log_warn "4. Deploy backend server if not already done"
log_warn "5. Build and deploy mobile apps"
echo ""
