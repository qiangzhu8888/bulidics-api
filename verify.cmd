@echo off
setlocal
chcp 65001 >nul
title BULIDICS Skill Installation Check

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0verify.ps1" %*
set "BULIDICS_EXIT=%ERRORLEVEL%"

echo.
pause
exit /b %BULIDICS_EXIT%
