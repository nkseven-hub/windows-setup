# Chocolatey 本体の導入(冪等: 既に入っていればスキップ)
$ErrorActionPreference = 'Stop'

if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "[choco] 既にインストール済み。スキップします。"
    return
}

Write-Host "[choco] Chocolatey をインストールします..."
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = `
    [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
    'https://community.chocolatey.org/install.ps1'))

Write-Host "[choco] 完了。"