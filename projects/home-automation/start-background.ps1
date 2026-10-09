# start-background.ps1
# Script untuk menjalankan Home Automation Server di background secara persisten (Windows Service-like)

$ErrorActionPreference = "Stop"
$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $rootDir "backend"
$frontendDir = Join-Path $rootDir "frontend"
$logsDir = Join-Path $backendDir "logs"
$logFile = Join-Path $logsDir "server.log"
$pidFile = Join-Path $backendDir ".server.pid"
$serverExe = Join-Path $backendDir "server.exe"

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "    Home Automation - Start Background Deployment    " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# 1. Pastikan folder logs tersedia
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

# 2. Cek apakah frontend sudah di-build, jika belum lakukan build
$distDir = Join-Path $frontendDir "dist"
if (-not (Test-Path (Join-Path $distDir "index.html"))) {
    Write-Host "[1/3] Frontend belum di-build. Menjalankan npm run build..." -ForegroundColor Yellow
    Push-Location $frontendDir
    npm run build
    Pop-Location
} else {
    Write-Host "[1/3] Frontend bundle sudah siap di dist/." -ForegroundColor Green
}

# 3. Cek apakah binary server.exe tersedia, jika belum lakukan go build
if (-not (Test-Path $serverExe)) {
    Write-Host "[2/3] Binary server.exe belum ada. Mengompilasi Go backend..." -ForegroundColor Yellow
    Push-Location $backendDir
    go build -o server.exe main.go
    Pop-Location
} else {
    Write-Host "[2/3] Binary server.exe siap." -ForegroundColor Green
}

# 4. Hentikan instance lama jika masih berjalan
if (Test-Path $pidFile) {
    $oldPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if ($oldPid) {
        $p = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
        if ($p) {
            Write-Host "Menghentikan instance lama (PID: $oldPid)..." -ForegroundColor Yellow
            Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
        }
    }
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}

# Periksa juga jika ada proses server.exe lain yang berjalan
$runningServers = Get-Process -Name "server" -ErrorAction SilentlyContinue
if ($runningServers) {
    foreach ($p in $runningServers) {
        Write-Host "Menghentikan server berjalan (PID: $($p.Id))..." -ForegroundColor Yellow
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 1
}

# Pastikan port 3000 bebas
$conn = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue
if ($conn) {
    foreach ($c in $conn) {
        $p = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
        if ($p) {
            Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        }
    }
    Start-Sleep -Seconds 1
}

# 5. Jalankan server.exe di background melalui WMI (Detach penuh dari terminal)
Write-Host "[3/3] Meluncurkan server.exe di background..." -ForegroundColor Yellow

$result = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
    CommandLine = $serverExe
    CurrentDirectory = $backendDir
}

if ($result.ReturnValue -ne 0) {
    Write-Host "[ERROR] Gagal meluncurkan server melalui WMI. Return code: $($result.ReturnValue)" -ForegroundColor Red
    exit 1
}

$serverPid = $result.ProcessId
Set-Content -Path $pidFile -Value $serverPid

# Tunggu inisialisasi server
Start-Sleep -Seconds 2

# Verifikasi proses aktif
$verifyProc = Get-Process -Id $serverPid -ErrorAction SilentlyContinue
if (-not $verifyProc) {
    Write-Host "[ERROR] Server tidak terdeteksi aktif setelah dimulai." -ForegroundColor Red
    Write-Host "Silakan cek log: $logFile" -ForegroundColor Red
    if (Test-Path $logFile) {
        Get-Content $logFile -Tail 15
    }
    exit 1
}

# Verifikasi respon HTTP
$port = 3000
$statusText = "Online"
try {
    $resp = Invoke-WebRequest -Uri "http://localhost:$port" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    $statusText = "Online (HTTP $($resp.StatusCode))"
} catch {
    $statusText = "Berjalan (Inisialisasi)"
}

Write-Host "=====================================================" -ForegroundColor Green
Write-Host " [SUCCESS] Server berhasil berjalan di background!    " -ForegroundColor Green
Write-Host " PID          : $serverPid" -ForegroundColor Cyan
Write-Host " Status       : $statusText" -ForegroundColor Cyan
Write-Host " Web App URL  : http://localhost:$port" -ForegroundColor Cyan
Write-Host " API Docs     : http://localhost:$port/docs" -ForegroundColor Cyan
Write-Host " WebSocket    : ws://localhost:$port/ws" -ForegroundColor Cyan
Write-Host " File Log     : $logFile" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Perintah Cepat:" -ForegroundColor Gray
Write-Host "  - Cek Status   : .\status.bat" -ForegroundColor White
Write-Host "  - Matikan      : .\stop-background.bat" -ForegroundColor White
Write-Host "  - Restart      : .\restart-background.bat" -ForegroundColor White
