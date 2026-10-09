@echo off
title Home Automation - Status
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0status.ps1"
pause
