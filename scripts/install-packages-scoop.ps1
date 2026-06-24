# bucket を追加してから scoopfile.json を import
$ErrorActionPreference = 'Stop'
$dir        = Join-Path $PSScriptRoot "..\packages\scoop"
$bucketList = Join-Path $dir "buckets.txt"
$scoopFile  = Join-Path $dir "scoopfile.json"

# 追加 bucket
if (Test-Path $bucketList) {
    Write-Host "[scoop] bucket を追加します..."
    $existing = (scoop bucket list).Name
    Get-Content $bucketList | Where-Object { $_ -and ($_ -notmatch '^\s*#') } | ForEach-Object {
        $name = $_.Trim()
        if ($existing -notcontains $name) {
            Write-Host "  + $name"
            scoop bucket add $name
        } else {
            Write-Host "  = $name (既存)"
        }
    }
}

# パッケージ import
if (Test-Path $scoopFile) {
    Write-Host "[scoop] scoopfile.json から import します..."
    scoop import $scoopFile
    Write-Host "[scoop] パッケージ導入完了。"
} else {
    Write-Warning "[scoop] $scoopFile が見つかりません。スキップします。"
}
