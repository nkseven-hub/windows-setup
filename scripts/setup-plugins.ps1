# Susieプラグイン/DLL等を各アプリの所定フォルダへ配置
$ErrorActionPreference = 'Stop'
$config = Join-Path $PSScriptRoot "..\config"

# 例: あふw の spi フォルダへ Susie プラグインをコピー
$spiSource = Join-Path $config "afxw\spi"
$spiTarget = "$env:APPDATA\afxw\spi"   # ← 実際のあふwのプラグイン参照先に合わせて変更

if (Test-Path $spiSource) {
    if (-not (Test-Path $spiTarget)) { New-Item -ItemType Directory -Path $spiTarget -Force | Out-Null }
    Copy-Item "$spiSource\*.spi" $spiTarget -Force -ErrorAction SilentlyContinue
    Write-Host "[plugins] Susieプラグインを配置: $spiTarget"
} else {
    Write-Host "[plugins] プラグイン元フォルダなし。スキップします。"
}
