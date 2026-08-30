[CmdletBinding()]
param(
    [ValidateSet("all", "codex-cursor", "claude")]
    [string]$Target = "all",

    [string]$UserProfilePath = $env:USERPROFILE,

    [string]$BackupBasePath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-SafeSkillPath {
    param(
        [string]$Root,
        [string]$Candidate
    )

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $candidateFull = [System.IO.Path]::GetFullPath($Candidate)
    if (-not $candidateFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "安全でない削除対象が検出されました: $candidateFull"
    }
}

if (-not $UserProfilePath) {
    throw "USERPROFILEを確認できません。Windowsユーザーとして実行してください。"
}

$sourceRoot = Join-Path $PSScriptRoot "skills"
$skills = @(Get-ChildItem -LiteralPath $sourceRoot -Directory | Sort-Object Name)
$targets = @()

if ($Target -in @("all", "codex-cursor")) {
    $targets += [pscustomobject]@{
        Name = "Codex-Cursor"
        Path = Join-Path $UserProfilePath ".agents\skills"
    }
}
if ($Target -in @("all", "claude")) {
    $targets += [pscustomobject]@{
        Name = "Claude-Code"
        Path = Join-Path $UserProfilePath ".claude\skills"
    }
}

$backupBase = if ($BackupBasePath) {
    $BackupBasePath
} elseif ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA "BULIDICS\SkillInstaller"
} else {
    Join-Path $UserProfilePath ".bulidics\SkillInstaller"
}
$backupRoot = Join-Path $backupBase ("backups\{0}-uninstall" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
$removed = $false

Write-Host "BULIDICS Skill Uninstaller" -ForegroundColor Cyan
Write-Host ""

foreach ($installTarget in $targets) {
    Write-Host "[$($installTarget.Name)] $($installTarget.Path)" -ForegroundColor Yellow
    foreach ($skill in $skills) {
        $destination = Join-Path $installTarget.Path $skill.Name
        Assert-SafeSkillPath -Root $installTarget.Path -Candidate $destination

        if (Test-Path -LiteralPath $destination -PathType Container) {
            $backupDestination = Join-Path (Join-Path $backupRoot $installTarget.Name) $skill.Name
            New-Item -ItemType Directory -Path (Split-Path -Parent $backupDestination) -Force | Out-Null
            Copy-Item -LiteralPath $destination -Destination $backupDestination -Recurse -Force
            Remove-Item -LiteralPath $destination -Recurse -Force
            Write-Host "  削除完了: $($skill.Name)" -ForegroundColor Green
            $removed = $true
        } else {
            Write-Host "  対象なし: $($skill.Name)"
        }
    }

    $manifestPath = Join-Path $installTarget.Path ".bulidics-install.json"
    if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
        Remove-Item -LiteralPath $manifestPath -Force
    }
}

Write-Host ""
if ($removed) {
    Write-Host "削除前のバックアップ: $backupRoot"
} else {
    Write-Host "インストール済みのBULIDICS Skillは見つかりませんでした。"
}
exit 0
