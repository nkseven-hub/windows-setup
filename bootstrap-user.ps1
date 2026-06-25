<#
  ユーザーパート: Scoop本体 + scoopパッケージ + 設定配置 + プラグイン配置
  実行: 管理者ではない通常の PowerShell から  .\bootstrap-user.ps1
#>
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# 管理者で動いていたら止める(Scoopは昇格セッションを拒否するため)
$isAdmin = ([Security.Principal.WindowsPrincipal]`
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($isAdmin) {
    Write-Error "このスクリプトは『管理者ではない通常の PowerShell』で実行してください。"
    exit 1
}

Write-Host "=== [USER] セットアップ開始 ===" -ForegroundColor Cyan

& "$root\scripts\install-scoop.ps1"
& "$root\scripts\setup-ssh-github.ps1"
& "$root\scripts\install-packages-scoop.ps1"
& "$root\scripts\apply-dotfiles.ps1"
& "$root\scripts\setup-plugins.ps1"
& "$root\scripts\setup-startup.ps1"

Write-Host ""
Write-Host "=== [USER] 完了 ===" -ForegroundColor Green
Write-Host "残りの手動作業は docs\manual-steps.md を確認してください。" -ForegroundColor Yellow
