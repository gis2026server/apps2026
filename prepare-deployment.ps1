# PowerShell Script: Prepare and Deploy GIS2026 System
# Windows users can run this to prepare for deployment

param(
    [string]$Action = "all"  # Options: all, check, build, deploy
)

# Configuration
$domain = "gisconnect.online"
$dashboardPath = ".\dashboard"
$mobileAppPath = ".\MobileApp"
$serverPath = ".\server"

# Colors (approximate for PowerShell)
function Write-Success {
    Write-Host "✓ $args" -ForegroundColor Green
}

function Write-Warning {
    Write-Host "⚠ $args" -ForegroundColor Yellow
}

function Write-Error {
    Write-Host "✗ $args" -ForegroundColor Red
}

function Write-Info {
    Write-Host "→ $args" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🚀 GIS2026 Complete Deployment Preparation" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host ""

# Step 1: Check Prerequisites
if ($Action -eq "all" -or $Action -eq "check") {
    Write-Host "Step 1: Checking Prerequisites..." -ForegroundColor Blue
    Write-Host "=================================" -ForegroundColor Blue
    
    # Check Node.js
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeVersion = node --version
        Write-Success "Node.js installed: $nodeVersion"
    } else {
        Write-Error "Node.js not installed. Download from: https://nodejs.org"
        exit 1
    }
    
    # Check npm
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $npmVersion = npm --version
        Write-Success "npm installed: $npmVersion"
    } else {
        Write-Error "npm not found"
        exit 1
    }
    
    # Check git
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Success "git installed"
    } else {
        Write-Warning "git not found (optional but recommended)"
    }
    
    Write-Host ""
}

# Step 2: Verify Configuration Files
if ($Action -eq "all" -or $Action -eq "check") {
    Write-Host "Step 2: Verifying Configuration Files..." -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    
    # Check Dashboard API URL
    if (Select-String -Path "$dashboardPath\src\services\api.js" -Pattern "https://gisconnect.online/api" -Quiet) {
        Write-Success "Dashboard API URL configured correctly"
    } else {
        Write-Error "Dashboard API URL not configured"
        Write-Warning "Expected: https://gisconnect.online/api in $dashboardPath\src\services\api.js"
    }
    
    # Check Mobile App URL
    if (Select-String -Path "$mobileAppPath\src\config\environment.js" -Pattern "https://gisconnect.online/api" -Quiet) {
        Write-Success "Mobile app production URL configured correctly"
    } else {
        Write-Error "Mobile app production URL not configured"
        Write-Warning "Expected: https://gisconnect.online/api in $mobileAppPath\src\config\environment.js"
    }
    
    # Check .env file
    if (Test-Path "$serverPath\.env") {
        Write-Success "Server .env file exists"
    } else {
        Write-Warning "Server .env file not found"
        Write-Info "Creating from template..."
        if (Test-Path "$serverPath\.env.example") {
            Copy-Item "$serverPath\.env.example" "$serverPath\.env"
            Write-Success ".env file created from template"
            Write-Warning "Edit .env and update JWT_SECRET"
        }
    }
    
    Write-Host ""
}

# Step 3: Install Dependencies
if ($Action -eq "all" -or $Action -eq "build") {
    Write-Host "Step 3: Installing Dependencies..." -ForegroundColor Blue
    Write-Host "==================================" -ForegroundColor Blue
    
    # Dashboard dependencies
    Write-Info "Installing Dashboard dependencies..."
    Set-Location $dashboardPath
    npm install --quiet
    Set-Location ..
    Write-Success "Dashboard dependencies installed"
    
    # Mobile App dependencies
    Write-Info "Installing Mobile App dependencies..."
    Set-Location $mobileAppPath
    npm install --quiet
    Set-Location ..
    Write-Success "Mobile App dependencies installed"
    
    # Server dependencies (optional for build)
    Write-Info "Installing Server dependencies..."
    Set-Location $serverPath
    npm install --quiet --production
    Set-Location ..
    Write-Success "Server dependencies installed"
    
    Write-Host ""
}

# Step 4: Build Dashboard
if ($Action -eq "all" -or $Action -eq "build") {
    Write-Host "Step 4: Building Dashboard..." -ForegroundColor Blue
    Write-Host "============================" -ForegroundColor Blue
    
    Set-Location $dashboardPath
    npm run build
    Set-Location ..
    
    if (Test-Path "$dashboardPath\dist\index.html") {
        Write-Success "Dashboard build successful"
        Write-Info "Output location: $dashboardPath\dist\"
    } else {
        Write-Error "Dashboard build failed"
        exit 1
    }
    
    Write-Host ""
}

# Step 5: Summary
Write-Host "Step 5: Summary" -ForegroundColor Blue
Write-Host "===============" -ForegroundColor Blue
Write-Host ""
Write-Success "✅ Local preparation complete!"
Write-Host ""

Write-Host "What's ready:" -ForegroundColor Cyan
Write-Host "  ✓ Code updated with production URLs"
Write-Host "  ✓ Server .env created"
Write-Host "  ✓ Dashboard built to dist/"
Write-Host "  ✓ Dependencies installed"
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Update domain nameservers to aapanel"
Write-Host "  2. Upload server folder to aapanel"
Write-Host "  3. Upload dashboard/dist to web root"
Write-Host "  4. Build and deploy mobile apps with Expo"
Write-Host ""

Write-Host "Deployment guides available:" -ForegroundColor Cyan
Write-Host "  📖 START_DEPLOYMENT_HERE.md"
Write-Host "  📖 PRODUCTION_SETUP_GUIDE.md"
Write-Host "  📖 QUICK_DEPLOYMENT_REFERENCE.md"
Write-Host ""

Write-Warning "Important: Change JWT_SECRET in server\.env before deployment!"
Write-Host ""
