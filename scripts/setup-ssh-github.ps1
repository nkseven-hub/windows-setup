# scripts\setup-ssh-github.ps1
# GitHub 用の SSH 鍵をマシンごとに発行し、公開鍵を gh 経由でアカウントに登録する
$ErrorActionPreference = 'Stop'

$sshDir  = Join-Path $env:USERPROFILE ".ssh"
$keyPath = Join-Path $sshDir "id_ed25519"
$pubPath = "$keyPath.pub"
$keyTitle = "$env:COMPUTERNAME-$(Get-Date -Format yyyyMMdd)"  # GitHub上での鍵の名前

# 0. gh が入っているか確認
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) が見つかりません。先に 'choco install gh' などで導入してください。"
    return
}

# 1. .ssh フォルダを用意
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

# 2. 鍵が無ければ生成(既にあれば再生成しない)
if (Test-Path $keyPath) {
    Write-Host "[ssh] 既存の鍵を使用します: $keyPath"
} else {
    Write-Host "[ssh] 新しい Ed25519 鍵を生成します..."
    # -N "" でパスフレーズ無し。パスフレーズを付けたい場合はここを変更
    ssh-keygen -t ed25519 -C $keyTitle -f $keyPath -N ''
    Write-Host "[ssh] 鍵を生成しました: $keyPath"
}

# 3. ssh-agent を起動して鍵を登録(任意。パスフレーズ付きなら推奨)
try {
    Set-Service ssh-agent -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service ssh-agent -ErrorAction SilentlyContinue
    ssh-add $keyPath 2>$null
} catch {
    Write-Warning "[ssh] ssh-agent の設定をスキップしました: $($_.Exception.Message)"
}

# 4. gh にログイン(未ログインなら)
$loggedIn = $false
try { gh auth status 2>$null; if ($LASTEXITCODE -eq 0) { $loggedIn = $true } } catch {}
if (-not $loggedIn) {
    Write-Host "[gh] GitHub にログインします(ブラウザが開きます)..."
    gh auth login --git-protocol ssh --web
}

# 5. 公開鍵の登録に必要なスコープを追加
Write-Host "[gh] 公開鍵登録用のスコープを確認/追加します..."
gh auth refresh -h github.com -s admin:public_key

# 6. 公開鍵を GitHub アカウントに登録(同じ鍵が既にあればスキップ)
$pubContent = (Get-Content $pubPath -Raw).Trim()
$existing = gh ssh-key list 2>$null
if ($existing -and ($existing -match [regex]::Escape(($pubContent -split '\s+')[1]))) {
    Write-Host "[gh] この公開鍵は既に登録済みです。スキップします。"
} else {
    Write-Host "[gh] 公開鍵を登録します(タイトル: $keyTitle)..."
    gh ssh-key add $pubPath --title $keyTitle
    Write-Host "[gh] 登録しました。"
}

# 7. 疎通確認
Write-Host "[ssh] GitHub への接続を確認します..."
ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>&1 | Write-Host
Write-Host "[ssh] 完了。'successfully authenticated' と出ていれば成功です。" -ForegroundColor Green
