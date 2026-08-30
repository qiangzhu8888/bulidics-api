@echo off
setlocal
chcp 65001 >nul
title BULIDICS Skill Installer

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set "BULIDICS_EXIT=%ERRORLEVEL%"

echo.
if "%BULIDICS_EXIT%"=="0" (
  echo インストールが完了しました。Cursor、Codex、Claude Codeを再起動してください。
) else (
  echo インストールに失敗しました。上に表示された内容を確認してください。
)
echo.
pause
exit /b %BULIDICS_EXIT%
