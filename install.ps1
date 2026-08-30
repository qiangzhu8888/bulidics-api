[CmdletBinding()]
param(
    [ValidateSet("all", "codex-cursor", "claude")]
    [string]$Target = "all",

    [string]$UserProfilePath = $env:USERPROFILE,

    [string]$BackupBasePath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-BulidicsDataRoot {
    param(
        [string]$RequestedBackupBase,
        [string]$RequestedUserProfile
    )

    if ($RequestedBackupBase) {
        return $RequestedBackupBase
    }
    if ($env:LOCALAPPDATA) {
        return Join-Path $env:LOCALAPPDATA "BULIDICS\SkillInstaller"
    }
    return Join-Path $RequestedUserProfile ".bulidics\SkillInstaller"
}

function Get-InstallTargets {
    param(
        [string]$SelectedTarget,
        [string]$RequestedUserProfile
    )

    $targets = @()
    if ($SelectedTarget -in @("all", "codex-cursor")) {
        $targets += [pscustomobject]@{
            Name = "Codex / Cursor"
            FolderName = "Codex-Cursor"
            Path = Join-Path $RequestedUserProfile ".agents\skills"
        }
    }
    if ($SelectedTarget -in @("all", "claude")) {
        $targets += [pscustomobject]@{
            Name = "Claude Code"
            FolderName = "Claude-Code"
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

function Write-Stage {
    param(
        [int]$Number,
        [int]$Total,
        [string]$Message
    )

    Write-Host ""
    Write-Host ("[{0}/{1}] {2}" -f $Number, $Total, $Message) -ForegroundColor Cyan
}

function Write-ProgressLine {
    param(
        [int]$Completed,
        [int]$Total,
        [string]$Message
    )

    $percent = if ($Total -gt 0) { [Math]::Floor(($Completed / $Total) * 100) } else { 100 }
    $barWidth = 30
    $filled = [Math]::Floor(($percent / 100) * $barWidth)
    $empty = $barWidth - $filled
    $bar = ('#' * $filled) + ('-' * $empty)
    Write-Host ("  [{0}] {1,3}%  {2}" -f $bar, $percent, $Message)
}

$transcriptStarted = $false
$logPath = ""
$exitCode = 0

try {
    if (-not $UserProfilePath) {
        throw "USERPROFILEを確認できません。Windowsユーザーとして実行してください。"
    }

    $sourceRoot = Join-Path $PSScriptRoot "skills"
    $versionFile = Join-Path $PSScriptRoot "VERSION.txt"
    $version = if (Test-Path -LiteralPath $versionFile -PathType Leaf) {
        (Get-Content -LiteralPath $versionFile -Raw).Trim()
    } else {
        "unknown"
    }

    $dataRoot = Get-BulidicsDataRoot -RequestedBackupBase $BackupBasePath -RequestedUserProfile $UserProfilePath
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logDirectory = Join-Path $dataRoot "logs"
    $logPath = Join-Path $logDirectory "$timestamp-install.log"
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null

    try {
        Start-Transcript -LiteralPath $logPath -Force | Out-Null
        $transcriptStarted = $true
    } catch {
        Write-Warning "ログの開始に失敗しました。インストール処理は継続します。"
    }

    Write-Host "BULIDICS Skill Installer v$version" -ForegroundColor Cyan
    Write-Host ("開始日時: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))

    Write-Stage -Number 1 -Total 4 -Message "パッケージを確認しています"
    if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
        throw "skillsフォルダーが見つかりません: $sourceRoot"
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
        Write-Host "  OK: $($skill.Name)"
    }

    $targets = @(Get-InstallTargets -SelectedTarget $Target -RequestedUserProfile $UserProfilePath)
    $backupRoot = Join-Path $dataRoot "backups\$timestamp-install"
    $backupCreated = $false

    Write-Stage -Number 2 -Total 4 -Message "インストール先を準備しています"
    foreach ($installTarget in $targets) {
        New-Item -ItemType Directory -Path $installTarget.Path -Force | Out-Null
        Write-Host "  $($installTarget.Name)"
        Write-Host "    $($installTarget.Path)" -ForegroundColor Yellow
    }

    Write-Stage -Number 3 -Total 4 -Message "Skillをインストールしています"
    $totalOperations = $targets.Count * $skills.Count
    $completedOperations = 0

    foreach ($installTarget in $targets) {
        foreach ($skill in $skills) {
            $statusMessage = "$($installTarget.Name): $($skill.Name)"
            $percentBefore = [Math]::Floor(($completedOperations / $totalOperations) * 100)
            Write-Progress -Activity "BULIDICS Skillをインストールしています" -Status $statusMessage -PercentComplete $percentBefore
            Write-Host ""
            Write-Host "  処理中: $statusMessage" -ForegroundColor Yellow

            $destination = Join-Path $installTarget.Path $skill.Name
            Assert-SafeSkillPath -Root $installTarget.Path -Candidate $destination

            if (Test-Path -LiteralPath $destination) {
                $backupDestination = Join-Path (Join-Path $backupRoot $installTarget.FolderName) $skill.Name
                New-Item -ItemType Directory -Path (Split-Path -Parent $backupDestination) -Force | Out-Null
                Copy-Item -LiteralPath $destination -Destination $backupDestination -Recurse -Force
                $backupCreated = $true
                Remove-Item -LiteralPath $destination -Recurse -Force
                Write-Host "    既存版をバックアップしました"
            }

            Copy-Item -LiteralPath $skill.FullName -Destination $destination -Recurse -Force
            $completedOperations++
            Write-ProgressLine -Completed $completedOperations -Total $totalOperations -Message "$statusMessage 完了"
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
    Write-Progress -Activity "BULIDICS Skillをインストールしています" -Completed

    Write-Stage -Number 4 -Total 4 -Message "インストール結果を確認しています"
    foreach ($installTarget in $targets) {
        foreach ($skill in $skills) {
            $installedSkillFile = Join-Path (Join-Path $installTarget.Path $skill.Name) "SKILL.md"
            if (-not (Test-Path -LiteralPath $installedSkillFile -PathType Leaf)) {
                throw "インストール確認に失敗しました: $installedSkillFile"
            }
        }
        Write-Host "  OK: $($installTarget.Name)" -ForegroundColor Green
        Write-Host "      $($installTarget.Path)"
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " インストールが正常に完了しました" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "インストールしたSkill:"
    foreach ($skill in $skills) {
        Write-Host "  - $($skill.Name)"
    }
    Write-Host ""
    Write-Host "インストール先:"
    foreach ($installTarget in $targets) {
        Write-Host "  $($installTarget.Name): $($installTarget.Path)"
    }
    if ($backupCreated) {
        Write-Host ""
        Write-Host "既存版のバックアップ: $backupRoot"
    }
    Write-Host "ログ: $logPath"
    Write-Host ""
    Write-Host "次の操作: Cursor、Codex、Claude Codeを再起動してください。" -ForegroundColor Cyan
} catch {
    $exitCode = 1
    Write-Progress -Activity "BULIDICS Skillをインストールしています" -Completed
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " インストール中にエラーが発生しました" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($logPath) {
        Write-Host "ログ: $logPath"
    }
} finally {
    if ($transcriptStarted) {
        Stop-Transcript | Out-Null
    }
}

exit $exitCode
