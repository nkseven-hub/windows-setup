# packages.config を読んで choco 一括インストール
$ErrorActionPreference = 'Stop'
$config = Join-Path $PSScriptRoot "..\packages\chocolatey\packages.config"

if (-not (Test-Path $config)) {
    Write-Warning "[choco] $config が見つかりません。スキップします。"
    return
}

Write-Host "[choco] packages.config からインストールします..."
choco install $config -y
Write-Host "[choco] パッケージ導入完了。"
