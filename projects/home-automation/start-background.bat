@echo off
title Home Automation - Start Background
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-background.ps1"
pause
