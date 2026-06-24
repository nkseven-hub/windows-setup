# Scoop 本体の導入(冪等)。通常ユーザーで実行されること前提。
$ErrorActionPreference = 'Stop'

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "[scoop] 既にインストール済み。スキップします。"
    return
}

Write-Host "[scoop] Scoop をインストールします..."
# 現在のユーザー向けに実行ポリシーを許可
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression

# git は bucket 操作に必須なので先に入れておく
scoop install git

Write-Host "[scoop] 完了。"
