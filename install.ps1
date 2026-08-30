[CmdletBinding()]
param(
    [ValidateSet("all", "codex-cursor", "claude")]
    [string]$Target = "all",

    [string]$UserProfilePath = $env:USERPROFILE,

    [string]$BackupBasePath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-BulidicsBackupRoot {
    param(
        [string]$Operation,
        [string]$RequestedBackupBase,
        [string]$RequestedUserProfile
    )

    $basePath = if ($RequestedBackupBase) {
        $RequestedBackupBase
    } elseif ($env:LOCALAPPDATA) {
        Join-Path $env:LOCALAPPDATA "BULIDICS\SkillInstaller"
    } else {
        Join-Path $RequestedUserProfile ".bulidics\SkillInstaller"
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    return Join-Path $basePath "backups\$timestamp-$Operation"
}

function Get-InstallTargets {
    param(
        [string]$SelectedTarget,
        [string]$RequestedUserProfile
    )

    $targets = @()
    if ($SelectedTarget -in @("all", "codex-cursor")) {
        $targets += [pscustomobject]@{
            Name = "Codex-Cursor"
            Path = Join-Path $RequestedUserProfile ".agents\skills"
        }
    }
    if ($SelectedTarget -in @("all", "claude")) {
        $targets += [pscustomobject]@{
            Name = "Claude-Code"
            Path = Join-Path $RequestedUserProfile ".claude\skills"
        }
    }
    return $targets
}

function Assert-SafeSkillPath {
    param(
        [string]$Root,
        [string]$Candidate
    )

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $candidateFull = [System.IO.Path]::GetFullPath($Candidate)
    if (-not $candidateFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "安全でないインストール先が検出されました: $candidateFull"
    }
}

if (-not $UserProfilePath) {
    throw "USERPROFILEを確認できません。Windowsユーザーとして実行してください。"
}

$sourceRoot = Join-Path $PSScriptRoot "skills"
$versionFile = Join-Path $PSScriptRoot "VERSION.txt"
if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "skillsフォルダーが見つかりません: $sourceRoot"
}

$version = if (Test-Path -LiteralPath $versionFile -PathType Leaf) {
    (Get-Content -LiteralPath $versionFile -Raw).Trim()
} else {
    "unknown"
}

$skills = @(Get-ChildItem -LiteralPath $sourceRoot -Directory | Sort-Object Name)
if ($skills.Count -eq 0) {
    throw "インストール対象のSkillがありません。"
}

foreach ($skill in $skills) {
    if ($skill.Name -notmatch '^[a-z0-9][a-z0-9-]*$') {
        throw "Skillフォルダー名が不正です: $($skill.Name)"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $skill.FullName "SKILL.md") -PathType Leaf)) {
        throw "SKILL.mdが見つかりません: $($skill.FullName)"
    }
}

$targets = @(Get-InstallTargets -SelectedTarget $Target -RequestedUserProfile $UserProfilePath)
$backupRoot = Get-BulidicsBackupRoot -Operation "install" -RequestedBackupBase $BackupBasePath -RequestedUserProfile $UserProfilePath
$backupCreated = $false

Write-Host "BULIDICS Skill Installer v$version" -ForegroundColor Cyan
Write-Host "対象Skill: $($skills.Name -join ', ')"
Write-Host ""

foreach ($installTarget in $targets) {
    New-Item -ItemType Directory -Path $installTarget.Path -Force | Out-Null
    Write-Host "[$($installTarget.Name)] $($installTarget.Path)" -ForegroundColor Yellow

    foreach ($skill in $skills) {
        $destination = Join-Path $installTarget.Path $skill.Name
        Assert-SafeSkillPath -Root $installTarget.Path -Candidate $destination

        if (Test-Path -LiteralPath $destination) {
            $backupDestination = Join-Path (Join-Path $backupRoot $installTarget.Name) $skill.Name
            New-Item -ItemType Directory -Path (Split-Path -Parent $backupDestination) -Force | Out-Null
            Copy-Item -LiteralPath $destination -Destination $backupDestination -Recurse -Force
            $backupCreated = $true
            Remove-Item -LiteralPath $destination -Recurse -Force
            Write-Host "  既存版をバックアップ: $($skill.Name)"
        }

        Copy-Item -LiteralPath $skill.FullName -Destination $destination -Recurse -Force
        Write-Host "  インストール完了: $($skill.Name)" -ForegroundColor Green
    }

    $manifest = [ordered]@{
        product = "BULIDICS Agent Skills"
        version = $version
        installedAt = (Get-Date).ToString("o")
        target = $installTarget.Name
        skills = @($skills.Name)
    }
    $manifestPath = Join-Path $installTarget.Path ".bulidics-install.json"
    $manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
}

Write-Host ""
if ($backupCreated) {
    Write-Host "バックアップ先: $backupRoot"
}
Write-Host "インストール後、Cursor、Codex、Claude Codeを再起動してください。" -ForegroundColor Cyan
exit 0
