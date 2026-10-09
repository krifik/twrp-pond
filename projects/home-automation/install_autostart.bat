@echo off
title BARA-Sense - Install Windows Autostart
powershell -ExecutionPolicy Bypass -Command "$WshShell = New-Object -ComObject WScript.Shell; $Startup = [Environment]::GetFolderPath('Startup'); $Shortcut = $WshShell.CreateShortcut((Join-Path $Startup 'BARA-Sense-Background.lnk')); $Shortcut.TargetPath = 'wscript.exe'; $Shortcut.Arguments = '\"' + (Join-Path (Resolve-Path .).Path 'run_background_silent.vbs') + '\"'; $Shortcut.WorkingDirectory = (Resolve-Path .).Path; $Shortcut.Description = 'BARA-Sense IoT Background Daemon'; $Shortcut.Save(); Write-Host 'Berhasil memasang BARA-Sense ke Windows Startup!' -ForegroundColor Green"
echo.
echo ========================================================
echo  BARA-Sense sekarang akan otomatis aktif di background
echo  setiap kali komputer dinyalakan / login ke Windows.
echo ========================================================
pause
