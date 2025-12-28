# 📱 Mobile App Configuration & Build Guide

## Production Configuration Update

### Step 1: Update Production API URL

**File:** `MobileApp/src/config/environment.js`

Change line 7:
```javascript
// FROM:
const PROD_API_URL = 'https://your-production-server.com/api';

// TO:
const PROD_API_URL = 'https://gisconnect.online/api';
```

### Step 2: Verify App Configuration

**File:** `MobileApp/app.json`

Verify these settings:
```json
{
  "expo": {
    "name": "GIS2026 Dashboard",
    "slug": "gis2026-dashboard",
    "version": "1.0.0",
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

## 🤖 Android APK Build

### Prerequisites

```bash
# 1. Install Expo CLI globally
npm install -g expo-cli

# 2. Create Expo Account (if not already)
# Visit: https://expo.dev/signup
# Or login in terminal:
expo login

# 3. Verify Node.js version (14+)
node --version

# 4. Verify npm packages
npm --version
```

### Build Steps

```bash
# 1. Navigate to mobile app directory
cd /path/to/MobileApp

# 2. Install dependencies
npm install

# 3. Update production API URL (as shown above)
# Edit: src/config/environment.js

# 4. Build APK for Android
expo build:android -t apk

# This will:
# - Package your app
# - Sign with Expo's certificates
# - Upload to Expo's build servers
# - Build APK
# - Email download link when ready
```

### Monitor Build Progress

```bash
# Check build status
expo build:status

# Check specific build
expo build:status --show <build-id>
```

### Download & Install APK

```bash
# After build completes:
# 1. Check email for download link
# 2. Or download via dashboard at expo.dev
# 3. Transfer to Android device
# 4. Install with:
adb install path/to/app-release.apk

# Or manually on device:
# 1. Copy APK to device
# 2. Open File Manager
# 3. Find APK file
# 4. Tap to install
# 5. Grant permissions when prompted
```

### Android Device Testing

```bash
# Enable Developer Mode on Android:
# 1. Settings → About Phone
# 2. Tap Build Number 7 times
# 3. Back to Settings → Developer Options
# 4. Enable USB Debugging

# Connect device via USB and install:
adb devices
adb install app-release.apk
adb logcat  # View logs
```

---

## 🍎 iOS IPA Build

### Prerequisites

```bash
# iOS builds are more complex and require:
# Option 1: Mac computer (easiest)
# Option 2: EAS Build service (cloud-based)

# Install EAS CLI (alternative to Expo)
npm install -g eas-cli

# Login to EAS
eas login
```

### Build Steps (Using EAS)

```bash
# 1. Navigate to mobile app directory
cd /path/to/MobileApp

# 2. Configure EAS
eas build:configure
# Select: iOS (for iOS builds)
# Select: Internal (for testing)

# 3. Build IPA
eas build --platform ios --local

# Or for cloud build:
eas build --platform ios
```

### Build Steps (Traditional)

```bash
# 1. Navigate to project
cd /path/to/MobileApp

# 2. Build using Expo
expo build:ios

# 3. Monitor status
expo build:status

# 4. Distribute via:
# - TestFlight (for internal testing)
# - App Store (for production)
```

### iOS Device Testing

```bash
# Option 1: TestFlight (Recommended)
# 1. Upload IPA to App Store Connect
# 2. Add testers
# 3. Testers download via TestFlight app

# Option 2: Manual Install
# 1. Use Xcode to install on connected device
# 2. Or use ideviceinstaller command-line tool
```

---

## 🔄 Build Alternatives

### Using EAS Build (Cloud-based, Recommended for iOS)

```bash
# Install EAS CLI
npm install -g eas-cli

# Login
eas login

# Configure for your project
eas build:configure

# Build Android APK
eas build --platform android --local

# Build iOS IPA
eas build --platform ios

# View build history
eas build:list
```

### Using GitHub Actions (CI/CD)

Create `.github/workflows/build.yml`:
```yaml
name: Build APK

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: npm install -g expo-cli
      - run: cd MobileApp && npm install
      - run: expo build:android -t apk
```

---

## 📤 Distribution Methods

### Android Distribution

#### Google Play Store

```bash
# 1. Create Google Play Developer Account
# - Visit: https://play.google.com/console
# - Pay $25 registration fee
# - Create application entry

# 2. Generate signed APK
# Use EAS or Expo build (already signed)

# 3. Upload to Play Store
# - Go to Play Console
# - Select app
# - Go to Release → Production
# - Upload APK
# - Fill app details
# - Submit for review

# 4. Wait for approval (usually 2-4 hours)
```

#### Direct Distribution (Testing)

```bash
# 1. Build APK (already signed by Expo)
# 2. Share link with testers
# 3. Testers download and install
# 4. Grant permissions on first run
```

### iOS Distribution

#### App Store

```bash
# 1. Create Apple Developer Account
# - Visit: https://developer.apple.com
# - Annual subscription: $99
# - Create app in App Store Connect

# 2. Build IPA via EAS or Xcode

# 3. Upload to App Store Connect
# - Use Xcode or Application Loader
# - Add app screenshots
# - Add app description
# - Submit for review

# 4. Wait for review (1-3 days typical)
```

#### TestFlight (Testing)

```bash
# 1. Build IPA
# 2. Upload to TestFlight via App Store Connect
# 3. Add tester email addresses
# 4. Send invites to testers
# 5. Testers download via TestFlight app
# 6. Can share with up to 10,000 testers
```

---

## 📝 Build Troubleshooting

### APK Build Fails

```bash
# Clear build cache
rm -rf ~/.expo

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Try building again
expo build:android -t apk --wait

# Check logs for specific error
expo build:status
```

### API Connection Issues After Build

```
# If app can't connect to API after build:

1. Verify production API URL is correct
   - Check environment.js for correct URL
   - Should be: https://gisconnect.online/api

2. Verify SSL certificate is valid
   - Test with browser: https://gisconnect.online/api

3. Check CORS configuration on backend
   - Should allow https://gisconnect.online

4. Check network on device
   - Device must have internet connection
   - Can access https://gisconnect.online in browser

5. Check firewall rules
   - Port 443 (HTTPS) must be open
```

### Build Takes Too Long

```bash
# Build timeout? Try local build:
eas build --platform android --local

# Or increase timeout in Expo:
# Wait up to 30 minutes for build
expo build:status --wait=1800
```

### App Crashes on Launch

```bash
# Check logs on device:
# Android: adb logcat
# iOS: Xcode console or TestFlight logs

# Rebuild with verbose logging:
expo build:android --verbose

# Check environment.js for correct API URL
# Ensure all dependencies are installed
```

---

## ✅ Post-Build Checklist

After successfully building APK/IPA:

- [ ] Download APK/IPA file
- [ ] Verify file size is reasonable (> 50MB)
- [ ] Test on physical device
- [ ] Test all features:
  - [ ] Login works
  - [ ] API connection works
  - [ ] Dashboard loads
  - [ ] Can view visits
  - [ ] Check-in works
  - [ ] Location captured
  - [ ] Photos saved
  - [ ] Real-time sync works
- [ ] Test on slow network (3G)
- [ ] Test with offline mode
- [ ] Verify permissions requested
- [ ] Check app size is acceptable

---

## 🔐 Security for Builds

### Before Distribution

```
1. Update API URL to production
   - Not localhost
   - Not development IP
   - Use https://gisconnect.online/api

2. Update app version
   - Increment version in app.json
   - Update build number

3. Verify no debug code
   - Remove console.logs
   - Remove test credentials
   - Remove hardcoded passwords

4. Enable production mode
   - NODE_ENV=production
   - Disable verbose logging

5. Sign certificate
   - Expo handles signing automatically
   - Or provide your own certificate

6. Test thoroughly
   - Test all features
   - Test error handling
   - Test network failures
```

---

## 📊 Build Versioning

**Semantic Versioning:** MAJOR.MINOR.PATCH

Example: 1.0.0

- **MAJOR:** Breaking changes (1.0.0 → 2.0.0)
- **MINOR:** New features (1.0.0 → 1.1.0)
- **PATCH:** Bug fixes (1.0.0 → 1.0.1)

Update in `app.json`:
```json
{
  "expo": {
    "version": "1.0.0",
    "android": {
      "versionCode": 1
    },
    "ios": {
      "buildNumber": "1"
    }
  }
}
```

---

## 🚀 Continuous Delivery (Optional)

Setup automatic builds on code push:

1. Push code to GitHub
2. GitHub Actions triggers
3. Builds APK/IPA automatically
4. Uploads to TestFlight/Play Store
5. Notifies testers

See `.github/workflows` for examples.

---

## 📱 App Store Submission Checklist

### Required Before Submission

- [ ] App icon (1024x1024 PNG)
- [ ] Screenshots (at least 2)
- [ ] App description (200+ characters)
- [ ] Privacy policy URL
- [ ] Support email
- [ ] Category selected
- [ ] Content rating completed
- [ ] Age restrictions set
- [ ] Pricing tier selected
- [ ] Terms and conditions

### Android Play Store

- [ ] Fill app details
- [ ] Add screenshots
- [ ] Upload APK
- [ ] Add privacy policy
- [ ] Set content rating
- [ ] Submit for review

### iOS App Store

- [ ] Same as above plus:
- [ ] Apple Developer account ($99/year)
- [ ] Build signed with Apple certificate
- [ ] App ID created in App Store Connect
- [ ] Privacy policy required
- [ ] Likely IDFA disclosure

---

**Build Guide Complete!** 🎉

Your mobile app is ready for:
- Testing with APK/IPA
- Distribution via stores
- Sharing with users

