[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$versionFile = Join-Path $PSScriptRoot "VERSION.txt"
if (-not (Test-Path -LiteralPath $versionFile -PathType Leaf)) {
    throw "VERSION.txtが見つかりません。"
}

$version = (Get-Content -LiteralPath $versionFile -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') {
    throw "VERSION.txtの形式が不正です: $version"
}

$packageItems = @(
    "install.cmd",
    "install.ps1",
    "verify.cmd",
    "verify.ps1",
    "uninstall.cmd",
    "uninstall.ps1",
    "VERSION.txt",
    "README.md",
    "README_インストール.txt",
    "skills"
)

$packagePaths = @()
foreach ($item in $packageItems) {
    $itemPath = Join-Path $PSScriptRoot $item
    if (-not (Test-Path -LiteralPath $itemPath)) {
        throw "パッケージ対象が見つかりません: $itemPath"
    }
    $packagePaths += $itemPath
}

$distPath = Join-Path $PSScriptRoot "dist"
New-Item -ItemType Directory -Path $distPath -Force | Out-Null

$archivePath = Join-Path $distPath "BULIDICS-Skill-Installer-v$version.zip"
if (Test-Path -LiteralPath $archivePath -PathType Leaf) {
    Remove-Item -LiteralPath $archivePath -Force
}

Compress-Archive -LiteralPath $packagePaths -DestinationPath $archivePath -CompressionLevel Optimal
Write-Host "作成完了: $archivePath" -ForegroundColor Green
