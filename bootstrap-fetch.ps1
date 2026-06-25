# bootstrap-fetch.ps1 (public リポジトリに置く軽量ローダー)
$ErrorActionPreference = 'Stop'
$repo = "https://github.com/nkseven-hub/windows-setup.git"
$dest = Join-Path $env:USERPROFILE "windows-setup"

# git が無ければ winget で最低限入れる(winget は OS 標準)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    # PATH 反映のため再読込
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path","User")
}

if (-not (Test-Path $dest)) {
    git clone $repo $dest    # public なので HTTPS で認証不要
}
Set-Location $dest
# 以降は本体のブートストラップへ
pwsh .\bootstrap-admin.ps1
