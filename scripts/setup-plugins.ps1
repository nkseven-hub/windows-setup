# scripts\setup-plugins.ps1
# プラグイン/DLL/付随アセットを、ファイル単位またはディレクトリ単位で配置する汎用スクリプト
$ErrorActionPreference = 'Stop'
$assets = Join-Path $PSScriptRoot "..\assets"

# あふw のインストール先(Scoop 経由)。環境に合わせて調整
$afxwDir = "$env:USERPROFILE\scoop\apps\afxw\current"

# --- 配置ジョブの定義 ---
# Name   : 表示名
# Type   : "file"(ファイルをコピー) または "dir"(ディレクトリごとコピー)
# Source : 元のパス(assets 配下)
# Target : 配置先。file の場合は配置先フォルダ、dir の場合は配置先の親フォルダ
# Filter : Type=file のときのワイルドカード(省略時 *)。dir のときは無視
$jobs = @(
    [pscustomobject]@{
        Name   = "あふw Susieプラグイン"
        Type   = "file"
        Source = Join-Path $assets "afxw\spi"
        Target = Join-Path $afxwDir "spi"
        Filter = "*.spi"
    },
    [pscustomobject]@{
        Name   = "あふw 統合アーカイバDLL"
        Type   = "file"
        Source = Join-Path $assets "afxw\dll"
        Target = $afxwDir
        Filter = "*.dll"
    },
    [pscustomobject]@{
        Name   = "Migemo 辞書フォルダ(DLL付随アセット)"
        Type   = "dir"
        Source = Join-Path $assets "afxw\dll\dict"   # 例: dict フォルダごと
        Target = $afxwDir                            # 配置先の親。ここに dict\ ができる
    }
    # 追加は , 区切りでここに
)

Write-Host "配置ジョブ数: $($jobs.Count)" -ForegroundColor Cyan

foreach ($job in $jobs) {
    Write-Host "処理中: $($job.Name)  [$($job.Type)]"

    if (-not (Test-Path $job.Source)) {
        Write-Warning "  元パスなし: $($job.Source) → スキップ"
        continue
    }

    switch ($job.Type) {

        "dir" {
            # 配置先の親フォルダを用意
            if (-not (Test-Path $job.Target)) {
                try { New-Item -ItemType Directory -Path $job.Target -Force | Out-Null }
                catch { Write-Warning "  配置先を作成できません: $($job.Target) → スキップ"; continue }
            }
            $leaf = Split-Path $job.Source -Leaf          # コピーするフォルダ名
            $dest = Join-Path $job.Target $leaf
            try {
                # -Recurse でフォルダ構造ごと。-Force で既存を上書き
                Copy-Item -Path $job.Source -Destination $job.Target -Recurse -Force
                $count = (Get-ChildItem $dest -Recurse -File -ErrorAction SilentlyContinue).Count
                Write-Host "  ディレクトリを配置: $dest ($count ファイル)" -ForegroundColor Green
            } catch {
                Write-Warning "  ディレクトリコピー失敗: $($_.Exception.Message)"
            }
        }

        default {   # "file"
            $filter = if ($job.Filter) { $job.Filter } else { "*" }
            $files  = Get-ChildItem -Path $job.Source -Filter $filter -File -ErrorAction SilentlyContinue
            if (-not $files) {
                Write-Warning "  対象ファイルなし ($filter in $($job.Source)) → スキップ"
                continue
            }
            if (-not (Test-Path $job.Target)) {
                try { New-Item -ItemType Directory -Path $job.Target -Force | Out-Null }
                catch { Write-Warning "  配置先を作成できません: $($job.Target) → スキップ"; continue }
            }
            $copied = 0
            foreach ($f in $files) {
                try { Copy-Item $f.FullName (Join-Path $job.Target $f.Name) -Force; $copied++ }
                catch { Write-Warning "  コピー失敗: $($f.Name) → $($_.Exception.Message)" }
            }
            Write-Host "  $copied 個のファイルを配置: $($job.Target)" -ForegroundColor Green
        }
    }
}

Write-Host "[plugins] 配置完了。"