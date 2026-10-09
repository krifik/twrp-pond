# deploy.ps1
# Script komprehensif: Build Frontend, Build Go Backend, & Jalankan di Background

$ErrorActionPreference = "Stop"
$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$frontendDir = Join-Path $rootDir "frontend"
$backendDir = Join-Path $rootDir "backend"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    Home Automation - Full Build & Deploy to Background   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Build Frontend React
Write-Host "[Tahap 1/3] Mengompilasi Frontend React (Vite Production Build)..." -ForegroundColor Yellow
Push-Location $frontendDir
try {
    npm run build
    Write-Host "Frontend build sukses!" -ForegroundColor Green
} finally {
    Pop-Location
}

# 2. Build Go Backend Binary
Write-Host "`n[Tahap 2/3] Mengompilasi Go Backend Binary (server.exe)..." -ForegroundColor Yellow
Push-Location $backendDir
try {
    go build -o server.exe main.go
    Write-Host "Backend binary compile sukses!" -ForegroundColor Green
} finally {
    Pop-Location
}

# 3. Restart Background Process
Write-Host "`n[Tahap 3/3] Meluncurkan aplikasi di background..." -ForegroundColor Yellow
& "$rootDir\start-background.ps1"
