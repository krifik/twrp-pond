@echo off
title Home Automation - Stop Background
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop-background.ps1"
pause
