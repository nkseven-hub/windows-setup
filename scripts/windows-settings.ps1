# OS設定(管理者パートで実行)。開発者モード有効化 + エクスプローラ表示など
$ErrorActionPreference = 'Stop'

Write-Host "[os] 開発者モードを有効化します(シンボリックリンク作成のため)..."
$devKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (-not (Test-Path $devKey)) { New-Item -Path $devKey -Force | Out-Null }
Set-ItemProperty -Path $devKey -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord

# 例: 隠しファイルと拡張子を表示
$exp = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $exp -Name "Hidden" -Value 1 -Type DWord
Set-ItemProperty -Path $exp -Name "HideFileExt" -Value 0 -Type DWord

Write-Host "[os] OS設定を適用しました。"
