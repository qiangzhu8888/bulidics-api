@echo off
setlocal
chcp 65001 >nul
title BULIDICS Skill Installer
color 0B
mode con cols=92 lines=34
cls

echo ===========================================================================================
echo                           BULIDICS Skill Installer
echo ===========================================================================================
echo.
echo インストール先
echo   Codex / Cursor : %USERPROFILE%\.agents\skills
echo   Claude Code    : %USERPROFILE%\.claude\skills
echo.
echo 既存のBULIDICS Skillがある場合は、バックアップしてから更新します。
echo インストールを開始しています。しばらくお待ちください...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set "BULIDICS_EXIT=%ERRORLEVEL%"

echo.
echo ===========================================================================================
if "%BULIDICS_EXIT%"=="0" (
  echo  完了: BULIDICS Skillをインストールしました。
  echo  Cursor、Codex、Claude Codeを再起動してください。
) else (
  color 0C
  echo  エラー: インストールに失敗しました。
  echo  上に表示されたエラー内容とログ保存先を確認してください。
)
echo ===========================================================================================
echo.
echo この画面を閉じるには、何かキーを押してください。
pause
exit /b %BULIDICS_EXIT%
