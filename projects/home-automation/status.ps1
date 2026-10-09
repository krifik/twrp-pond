# status.ps1
# Script untuk memeriksa status background deployment Home Automation

$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $rootDir "backend"
$logFile = Join-Path $backendDir "logs\server.log"
$pidFile = Join-Path $backendDir ".server.pid"
$serverExe = Join-Path $backendDir "server.exe"

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "      Home Automation - Background Service Status     " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

$runningProc = $null

if (Test-Path $pidFile) {
    $savedPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if ($savedPid) {
        $runningProc = Get-Process -Id $savedPid -ErrorAction SilentlyContinue
    }
}

if (-not $runningProc) {
    $runningProc = Get-Process -Name "server" -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -eq $serverExe
    } | Select-Object -First 1
    if ($runningProc) {
        Set-Content -Path $pidFile -Value $runningProc.Id
    }
}

if ($runningProc) {
    $memMB = [math]::Round($runningProc.WorkingSet64 / 1MB, 2)
    $cpuSec = [math]::Round($runningProc.TotalProcessorTime.TotalSeconds, 2)
    $startTime = $runningProc.StartTime.ToString("dd MMM yyyy HH:mm:ss")

    Write-Host " Status         : " -NoNewline; Write-Host "ONLINE (BERJALAN)" -ForegroundColor Green
    Write-Host " PID            : $($runningProc.Id)" -ForegroundColor Yellow
    Write-Host " Memory (RAM)   : $memMB MB" -ForegroundColor Yellow
    Write-Host " CPU Usage      : $cpuSec s" -ForegroundColor Yellow
    Write-Host " Dimulai Sejak  : $startTime" -ForegroundColor Yellow

    # Cek Port 3000
    $conn = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue
    if ($conn) {
        Write-Host " Port 3000      : " -NoNewline; Write-Host "LISTENING (Aktif)" -ForegroundColor Green
    } else {
        Write-Host " Port 3000      : " -NoNewline; Write-Host "BELUM TERDETEKSI" -ForegroundColor Red
    }

    # Cek Health HTTP
    try {
        $resp = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host " HTTP Response  : 200 OK (Aplikasi Siap Diakses)" -ForegroundColor Green
        Write-Host " Web App URL    : http://localhost:3000" -ForegroundColor Cyan
        Write-Host " Swagger Docs   : http://localhost:3000/docs" -ForegroundColor Cyan
    } catch {
        Write-Host " HTTP Response  : Belum merespon..." -ForegroundColor Yellow
    }
} else {
    Write-Host " Status         : " -NoNewline; Write-Host "OFFLINE (TIDAK BERJALAN)" -ForegroundColor Red
    Write-Host " Info           : Jalankan .\start-background.bat untuk menyalakan." -ForegroundColor Gray
}

Write-Host "-----------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Log Terakhir (10 Baris Terbaru):" -ForegroundColor Magenta
if (Test-Path $logFile) {
    Get-Content $logFile -Tail 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "  (Belum ada file log)" -ForegroundColor DarkGray
}
Write-Host "=====================================================" -ForegroundColor Cyan
