# 設定ファイルをシンボリックリンクで配置(開発者モード or 管理者が必要)
$ErrorActionPreference = 'Stop'
$config = Join-Path $PSScriptRoot "..\config"

# [リンク元(リポジトリ内) , リンク先(実環境)] の対応表
# %APPDATA%          → C:\Users\<user>\AppData\Roaming   (多くのアプリの設定)
# %LOCALAPPDATA%     → C:\Users\<user>\AppData\Local     (キャッシュ・端末固有設定)
# %USERPROFILE%      → C:\Users\<user>                   (.gitconfig 等)
# %PROGRAMDATA%      → C:\ProgramData                    (全ユーザー共通設定)
$links = @(
    @{ Source = "$config\git\.gitconfig";
       Target = "$env:USERPROFILE\.gitconfig" },
    @{ Source = "$config\nvim\init.vim";
       Target = "$env:LOCALAPPDATA\nvim\init.vim" }
)

foreach ($l in $links) {
    if (-not (Test-Path $l.Source)) {
        Write-Warning "  リンク元なし: $($l.Source) → スキップ"
        continue
    }
    # 配置先フォルダを用意
    $parent = Split-Path $l.Target -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    # 既存ファイルがあれば退避してからリンク作成
    if (Test-Path $l.Target) {
        $backup = "$($l.Target).bak_$(Get-Date -Format yyyyMMddHHmmss)"
        Write-Host "  既存を退避: $($l.Target) → $backup"
        Move-Item $l.Target $backup -Force
    }

    try {
        New-Item -ItemType SymbolicLink -Path $l.Target -Target $l.Source -Force | Out-Null
        Write-Host "  リンク作成: $($l.Target)"
    } catch {
        Write-Warning "  リンク失敗: $($l.Target)"
        Write-Warning "    理由: $($_.Exception.Message)"
        Write-Warning "    → コピーで代替します(開発者モードを有効化後に再実行するとリンクになります)"
        Copy-Item $l.Source $l.Target -Force
    }
}
Write-Host "[dotfiles] 配置完了。"
