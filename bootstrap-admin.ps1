#Requires -RunAsAdministrator
# 管理者パート: Chocolatey本体 + chocoパッケージ + OS設定

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# 管理者で動いているか確認（1行にまとめて記述）
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal   = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin     = $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

if (-not $isAdmin) {
    Write-Error "このスクリプトは『管理者として実行』してください。"
    exit 1
}

Write-Host "=== [ADMIN] セットアップ開始 ===" -ForegroundColor Cyan

& "$root\scripts\windows-settings.ps1"
& "$root\scripts\install-chocolatey.ps1"
& "$root\scripts\install-packages-choco.ps1"

Write-Host ""
Write-Host "=== [ADMIN] 完了 ===" -ForegroundColor Green
Write-Host "次に『管理者ではない通常の PowerShell』を開いて、" -ForegroundColor Yellow
Write-Host "  .\bootstrap-user.ps1" -ForegroundColor Yellow
Write-Host "を実行してください。" -ForegroundColor Yellow