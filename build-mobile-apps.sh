#!/bin/bash

# GIS2026 Complete Mobile App Build Script
# Builds Android APK and iOS IPA for production
# Usage: bash build-mobile-apps.sh

set -e

echo "📱 GIS2026 Mobile App Build Script"
echo "=================================="
echo ""

# Configuration
APP_NAME="GIS2026 Dashboard"
APP_VERSION="1.0.0"
DOMAIN="gisconnect.online"
MOBILE_PATH="./MobileApp"
BUILD_OUTPUT="./MobileApp/dist"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_section() {
    echo -e "${BLUE}→${NC} $1"
}

echo "Step 1: Checking Prerequisites..."
echo "=================================="

if [ ! -d "$MOBILE_PATH" ]; then
    log_error "MobileApp directory not found: $MOBILE_PATH"
    exit 1
fi

log_info "MobileApp directory found"

if ! command -v expo &> /dev/null; then
    log_warn "Expo CLI not found. Installing globally..."
    npm install -g expo-cli
fi

EXPO_VERSION=$(expo --version)
log_info "Expo CLI version: $EXPO_VERSION"

echo ""

echo "Step 2: Verifying Production Configuration..."
echo "=============================================="

if grep -q "https://gisconnect.online/api" "$MOBILE_PATH/src/config/environment.js"; then
    log_info "Production API URL correctly configured"
else
    log_error "Production API URL not configured correctly!"
    log_warn "Expected: https://gisconnect.online/api"
    log_warn "Please update: $MOBILE_PATH/src/config/environment.js"
    exit 1
fi

log_info "App version: $APP_VERSION"
log_info "App name: $APP_NAME"

echo ""

echo "Step 3: Installing Dependencies..."
echo "===================================="

cd "$MOBILE_PATH"

log_info "Installing npm packages..."
npm install --quiet

log_info "Dependencies installed"

echo ""

echo "Step 4: Verifying Expo Account..."
echo "=================================="

log_section "Please ensure you're logged in to Expo"
log_section "Run: expo login (if not already logged in)"
log_warn "Note: You need an Expo account to build"
log_warn "Signup at: https://expo.dev/signup"

echo ""
echo "Proceed with builds? (y/n)"
read -r PROCEED

if [ "$PROCEED" != "y" ]; then
    log_warn "Build cancelled"
    exit 0
fi

echo ""

echo "Step 5: Build Android APK..."
echo "============================="

log_section "Building Android APK for production..."
log_info "This will take 10-15 minutes..."
log_info "Check your email for download link when complete"

expo build:android -t apk

log_info "Android APK build submitted!"
log_warn "Monitor progress: expo build:status"

echo ""

echo "Step 6: Build iOS IPA (if on Mac)..."
echo "===================================="

log_section "Building iOS IPA for production..."
log_info "This will take 15-30 minutes..."
log_info "Check your email for download link when complete"

# Check if running on Mac
if [[ "$OSTYPE" == "darwin"* ]]; then
    expo build:ios
    log_info "iOS IPA build submitted!"
else
    log_warn "iOS builds require Mac. Use EAS cloud build instead:"
    log_warn "npm install -g eas-cli"
    log_warn "eas build --platform ios"
fi

echo ""

echo "Step 7: Build Summary"
echo "===================="

echo ""
log_info "✅ Mobile app builds submitted!"
echo ""
echo "Build Information:"
echo "  App Name: $APP_NAME"
echo "  Version: $APP_VERSION"
echo "  API Domain: $DOMAIN"
echo ""

log_warn "Next Steps:"
log_warn "1. Check email for build links (check spam folder)"
log_warn "2. Monitor progress: expo build:status"
log_warn "3. Download APK when ready"
log_warn "4. Download IPA when ready (iOS)"
log_warn "5. Test on Android device: adb install app.apk"
log_warn "6. Test on iOS device via TestFlight or direct install"
echo ""

log_section "Useful Commands:"
echo "  Status:    expo build:status"
echo "  Download:  expo build:download"
echo "  Logs:      expo logs"
echo ""
