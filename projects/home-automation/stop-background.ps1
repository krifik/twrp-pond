# stop-background.ps1
# Script untuk mematikan background deployment Home Automation

$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $rootDir "backend"
$pidFile = Join-Path $backendDir ".server.pid"
$serverExe = Join-Path $backendDir "server.exe"

Write-Host "=====================================================" -ForegroundColor Yellow
Write-Host "    Home Automation - Stop Background Deployment     " -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Yellow

$stopped = $false

# 1. Hentikan berdasarkan file PID jika ada
if (Test-Path $pidFile) {
    $targetPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if ($targetPid) {
        $p = Get-Process -Id $targetPid -ErrorAction SilentlyContinue
        if ($p) {
            Write-Host "Menghentikan proses server (PID: $targetPid)..." -ForegroundColor Yellow
            Stop-Process -Id $targetPid -Force -ErrorAction SilentlyContinue
            $stopped = $true
        }
    }
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}

# 2. Periksa apakah masih ada server.exe yang berjalan dari backend ini
$runningServers = Get-Process -Name "server" -ErrorAction SilentlyContinue | Where-Object {
    $_.Path -eq $serverExe
}

if ($runningServers) {
    foreach ($p in $runningServers) {
        Write-Host "Menghentikan proses server (PID: $($p.Id))..." -ForegroundColor Yellow
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        $stopped = $true
    }
}

# 3. Lepaskan port 3000 jika ada proses lain yang masih memegangnya
$conn = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue
if ($conn) {
    foreach ($c in $conn) {
        $p = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
        if ($p -and $p.ProcessName -eq "server") {
            Write-Host "Membebaskan port 3000 dari PID $($p.Id)..." -ForegroundColor Yellow
            Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
            $stopped = $true
        }
    }
}

Start-Sleep -Seconds 1

if ($stopped) {
    Write-Host "[SUCCESS] Server background berhasil dihentikan." -ForegroundColor Green
} else {
    Write-Host "[INFO] Tidak ada server background yang sedang berjalan." -ForegroundColor Cyan
}
Write-Host "=====================================================" -ForegroundColor Yellow
