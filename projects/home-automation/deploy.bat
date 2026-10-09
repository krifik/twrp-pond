@echo off
title Home Automation - Deploy to Background
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
pause
