[CmdletBinding()]
param(
    [ValidateSet("all", "codex-cursor", "claude")]
    [string]$Target = "all",

    [string]$UserProfilePath = $env:USERPROFILE
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $UserProfilePath) {
    throw "USERPROFILEを確認できません。Windowsユーザーとして実行してください。"
}

$sourceRoot = Join-Path $PSScriptRoot "skills"
$skills = @(Get-ChildItem -LiteralPath $sourceRoot -Directory | Sort-Object Name)
$targets = @()

if ($Target -in @("all", "codex-cursor")) {
    $targets += [pscustomobject]@{
        Name = "Codex / Cursor"
        Path = Join-Path $UserProfilePath ".agents\skills"
    }
}
if ($Target -in @("all", "claude")) {
    $targets += [pscustomobject]@{
        Name = "Claude Code"
        Path = Join-Path $UserProfilePath ".claude\skills"
    }
}

$failed = $false
Write-Host "BULIDICS Skill インストール確認" -ForegroundColor Cyan
Write-Host ""

foreach ($installTarget in $targets) {
    Write-Host "[$($installTarget.Name)] $($installTarget.Path)" -ForegroundColor Yellow
    foreach ($skill in $skills) {
        $skillFile = Join-Path (Join-Path $installTarget.Path $skill.Name) "SKILL.md"
        if (Test-Path -LiteralPath $skillFile -PathType Leaf) {
            Write-Host "  OK  $($skill.Name)" -ForegroundColor Green
        } else {
            Write-Host "  NG  $($skill.Name) が見つかりません" -ForegroundColor Red
            $failed = $true
        }
    }
}

Write-Host ""
if ($failed) {
    Write-Host "確認に失敗しました。install.cmdをもう一度実行してください。" -ForegroundColor Red
    exit 1
}

Write-Host "すべてのBULIDICS Skillを確認できました。" -ForegroundColor Green
exit 0
