# status_background.ps1 - Memeriksa Status Deployment Background
$ErrorActionPreference = "SilentlyContinue"
$Root = $PSScriptRoot
if (-not $Root) { $Root = (Resolve-Path .).Path }

$LogsDir = Join-Path $Root "backend\logs"
$PidFile = Join-Path $LogsDir "daemon_pids.json"
$TunnelLog = Join-Path $LogsDir "tunnel.log"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  BARA-Sense - Status Deployment Background                " -ForegroundColor Cyan
Write-Host "  (Building Automation & Realtime Analytics)               " -ForegroundColor DarkCyan
Write-Host "==========================================================" -ForegroundColor Cyan

$serverProcess = Get-Process -Name "server" -ErrorAction SilentlyContinue | Select-Object -Last 1
$tunnelProcess = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue | Select-Object -Last 1

# Cek HTTP Health port 3000
$localHttpOk = $false
try {
    $res = Invoke-RestMethod -Uri "http://127.0.0.1:3000/api/devices" -TimeoutSec 3 -ErrorAction Stop
    if ($res) { $localHttpOk = $true }
} catch {}

if ($serverProcess -or $localHttpOk) {
    $pidStr = if ($serverProcess) { " (PID: $($serverProcess.Id))" } else { "" }
    Write-Host "● Backend Server   : BERJALAN$pidStr" -ForegroundColor Green
    Write-Host "  Local URL        : http://127.0.0.1:3000" -ForegroundColor White
} else {
    Write-Host "○ Backend Server   : NONAKTIF" -ForegroundColor Red
}

$tunnelUrl = ""
if (Test-Path $TunnelLog) {
    $content = Get-Content $TunnelLog -Raw
    if ($content -match "https://[a-zA-Z0-9\-]+\.trycloudflare\.com") {
        $tunnelUrl = $matches[0]
    }
}
if (-not $tunnelUrl -and (Test-Path $PidFile)) {
    try {
        $pData = Get-Content $PidFile -Raw | ConvertFrom-Json
        if ($pData.tunnel_url) { $tunnelUrl = $pData.tunnel_url }
    } catch {}
}

if ($tunnelProcess -or $tunnelUrl) {
    $tPidStr = if ($tunnelProcess) { " (PID: $($tunnelProcess.Id))" } else { "" }
    Write-Host "● Cloudflare Tunnel: BERJALAN$tPidStr" -ForegroundColor Green
    if ($tunnelUrl) {
        Write-Host "  Public URL       : $tunnelUrl" -ForegroundColor Cyan
    }
} else {
    Write-Host "○ Cloudflare Tunnel: NONAKTIF" -ForegroundColor Gray
}

Write-Host "==========================================================" -ForegroundColor Cyan
