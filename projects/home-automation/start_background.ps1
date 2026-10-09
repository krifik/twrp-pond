# start_background.ps1 - Menjalankan Home Automation Backend & Cloudflare Tunnel di Background
$ErrorActionPreference = "SilentlyContinue"
$Root = $PSScriptRoot
if (-not $Root) { $Root = (Resolve-Path .).Path }

$LogsDir = Join-Path $Root "backend\logs"
if (-not (Test-Path $LogsDir)) { New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null }

$ServerLog = Join-Path $LogsDir "server.log"
$TunnelLog = Join-Path $LogsDir "tunnel.log"
$PidFile = Join-Path $LogsDir "daemon_pids.json"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  BARA-Sense - Menjalankan Deployment di Background        " -ForegroundColor Cyan
Write-Host "  (Building Automation & Realtime Analytics)               " -ForegroundColor DarkCyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Hentikan proses lama
Write-Host "Membersihkan proses lama..." -ForegroundColor Gray
Stop-Process -Name "server" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "cloudflared" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# 1b. Memastikan PostgreSQL Server Aktif
Write-Host "Memeriksa layanan database PostgreSQL..." -ForegroundColor Gray
$pgCtl = "C:\Program Files\PostgreSQL\16\bin\pg_ctl.exe"
$pgData = "C:\Users\fiqri\postgres_data"
$pgLog = "C:\Users\fiqri\postgres.log"
if (Test-Path $pgCtl) {
    & $pgCtl -D $pgData -l $pgLog start | Out-Null
}

# 2. Jalankan Backend Server (server.exe) di background
Write-Host "[1/2] Memulai Backend Server (Port 3000)..." -ForegroundColor Yellow
$serverExe = Join-Path $Root "backend\server.exe"
$backendDir = Join-Path $Root "backend"

$wmiServer = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
    CommandLine = "cmd.exe /c `"`"$serverExe`" > `"$ServerLog`" 2>&1`""
    CurrentDirectory = $backendDir
}
$serverPid = $wmiServer.ProcessId

# Tunggu sampai port 3000 siap via loopback IPv4
$ready = $false
for ($i = 0; $i -lt 12; $i++) {
    Start-Sleep -Seconds 1
    $sp = Get-Process -Name "server" -ErrorAction SilentlyContinue | Select-Object -Last 1
    if ($sp) { $serverPid = $sp.Id }
    try {
        $res = Invoke-RestMethod -Uri "http://127.0.0.1:3000/api/devices" -TimeoutSec 2 -ErrorAction Stop
        if ($res) { $ready = $true; break }
    } catch {}
}

if ($ready) {
    Write-Host "  -> Backend Server BERHASIL aktif (PID: $serverPid, Local: http://127.0.0.1:3000)" -ForegroundColor Green
} else {
    Write-Host "  -> Backend Server aktif di PID: $serverPid" -ForegroundColor Yellow
}

# 3. Jalankan Cloudflare Tunnel ke http://127.0.0.1:3000 di background
Write-Host "[2/2] Memulai Cloudflare Tunnel Publik..." -ForegroundColor Yellow

# Baca konfigurasi Token Tunnel & Custom Domain jika ada
$tunnelToken = ""
$customDomain = "bara-sense.my.id"
$envPath = Join-Path $Root "backend\.env"
if (Test-Path $envPath) {
    Get-Content $envPath | ForEach-Object {
        if ($_ -match '^\s*CLOUDFLARE_TUNNEL_TOKEN\s*=\s*(.+)$') {
            $tunnelToken = $matches[1].Trim().Trim('"').Trim("'")
        }
        if ($_ -match '^\s*CUSTOM_DOMAIN\s*=\s*(.+)$') {
            $customDomain = $matches[1].Trim().Trim('"').Trim("'")
        }
    }
}

$tunnelPid = $null
$tunnelUrl = ""

if ($tunnelToken) {
    Write-Host "  -> Menggunakan Cloudflare Tunnel Token untuk https://$customDomain" -ForegroundColor Cyan
    $wmiTunnel = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
        CommandLine = "cmd.exe /c `"cloudflared tunnel run --token $tunnelToken > `"$TunnelLog`" 2>&1`""
        CurrentDirectory = $Root
    }
    $tunnelPid = $wmiTunnel.ProcessId
    $tunnelUrl = "https://$customDomain"
    Start-Sleep -Seconds 2
} else {
    $wmiTunnel = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
        CommandLine = "cmd.exe /c `"cloudflared tunnel --url http://127.0.0.1:3000 > `"$TunnelLog`" 2>&1`""
        CurrentDirectory = $Root
    }
    $tunnelPid = $wmiTunnel.ProcessId
    # Tunggu URL publik terbentuk di log
    for ($i = 0; $i -lt 15; $i++) {
        Start-Sleep -Seconds 1
        $tp = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue | Select-Object -Last 1
        if ($tp) { $tunnelPid = $tp.Id }
        if (Test-Path $TunnelLog) {
            $content = Get-Content $TunnelLog -Raw
            if ($content -match "https://[a-zA-Z0-9\-]+\.trycloudflare\.com") {
                $tunnelUrl = $matches[0]
                break
            }
        }
    }
}

# Simpan informasi status ke file JSON
$pidsData = @{
    server_pid = $serverPid
    tunnel_pid = $tunnelPid
    tunnel_url = $tunnelUrl
    started_at = (Get-Date).ToString("s")
}
$pidsData | ConvertTo-Json | Set-Content $PidFile

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT BERHASIL AKTIF DI BACKGROUND!                " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Local URL    : http://127.0.0.1:3000" -ForegroundColor White
if ($tunnelUrl) {
    Write-Host "Public URL   : $tunnelUrl" -ForegroundColor Cyan
} else {
    Write-Host "Public URL   : Inisialisasi... cek dengan .\status_background.ps1" -ForegroundColor Yellow
}
Write-Host "Log Server   : $ServerLog" -ForegroundColor Gray
Write-Host "Log Tunnel   : $TunnelLog" -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Perintah Cepat:" -ForegroundColor White
Write-Host "  Status  : .\status_background.ps1  (atau klik status_background.bat)" -ForegroundColor Yellow
Write-Host "  Berhenti: .\stop_background.ps1    (atau klik stop_background.bat)" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
