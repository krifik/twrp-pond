# stop_background.ps1 - Menghentikan Deployment Background
$ErrorActionPreference = "SilentlyContinue"
$Root = $PSScriptRoot
if (-not $Root) { $Root = Get-Location }

$LogsDir = Join-Path $Root "backend\logs"
$PidFile = Join-Path $LogsDir "daemon_pids.json"

Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host "  BARA-Sense - Menghentikan Deployment Background          " -ForegroundColor Yellow
Write-Host "  (Building Automation & Realtime Analytics)               " -ForegroundColor DarkYellow
Write-Host "==========================================================" -ForegroundColor Yellow

if (Test-Path $PidFile) {
    try {
        $pids = Get-Content $PidFile | ConvertFrom-Json
        if ($pids.server_pid) {
            Write-Host "Menghentikan Backend Server (PID $($pids.server_pid))..." -ForegroundColor Gray
            Stop-Process -Id $pids.server_pid -Force -ErrorAction SilentlyContinue
        }
        if ($pids.tunnel_pid) {
            Write-Host "Menghentikan Cloudflare Tunnel (PID $($pids.tunnel_pid))..." -ForegroundColor Gray
            Stop-Process -Id $pids.tunnel_pid -Force -ErrorAction SilentlyContinue
        }
    } catch {}
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}

# Pastikan proses server.exe tidak tertinggal
Get-Process -Name "server" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Deployment di background berhasil dihentikan." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Yellow
