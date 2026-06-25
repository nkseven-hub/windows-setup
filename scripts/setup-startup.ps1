# scripts\setup-startup.ps1 — 自動起動させたいアプリをまとめて登録
$ErrorActionPreference = 'Stop'
$startup = [Environment]::GetFolderPath('Startup')
$shell   = New-Object -ComObject WScript.Shell

# 自動起動させたいアプリ。要素が1個でも必ず配列になるよう @() で囲む
$apps = @(
    [pscustomobject]@{
        Name   = "Keypirinha"
        Search = "$env:ProgramData\chocolatey\lib\keypirinha"
        Filter = "keypirinha*.exe"
    }
    # 追加するときはここに , 区切りで足す
)

Write-Host "登録対象アプリ数: $($apps.Count)" -ForegroundColor Cyan

foreach ($app in $apps) {
    Write-Host "処理中: $($app.Name)"

    $exe = Get-ChildItem -Path $app.Search -Recurse -Filter $app.Filter -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName

    if (-not $exe) {
        Write-Warning "  $($app.Name): 実行ファイルが見つかりません ($($app.Search) 内に $($app.Filter))。スキップ"
        continue
    }

    Write-Host "  実行ファイル検出: $exe"

    $lnk = Join-Path $startup "$($app.Name).lnk"
    $sc  = $shell.CreateShortcut($lnk)
    $sc.TargetPath       = $exe
    $sc.WorkingDirectory = Split-Path $exe -Parent
    $sc.Save()

    if (Test-Path $lnk) {
        Write-Host "  $($app.Name) をスタートアップに登録: $lnk" -ForegroundColor Green
    } else {
        Write-Warning "  $($app.Name): ショートカット作成に失敗しました。"
    }
}