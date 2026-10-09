@echo off
title Home Automation - Restart Background
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0stop-background.ps1'; Start-Sleep -Seconds 1; & '%~dp0start-background.ps1'"
pause
