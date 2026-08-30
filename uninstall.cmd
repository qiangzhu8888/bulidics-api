@echo off
setlocal
chcp 65001 >nul
title BULIDICS Skill Uninstaller

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1" %*
set "BULIDICS_EXIT=%ERRORLEVEL%"

echo.
if "%BULIDICS_EXIT%"=="0" (
  echo アンインストールが完了しました。
) else (
  echo アンインストールに失敗しました。上に表示された内容を確認してください。
)
echo.
pause
exit /b %BULIDICS_EXIT%
