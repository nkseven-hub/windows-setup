# bucket を追加してから scoopfile.json を import
$ErrorActionPreference = 'Stop'
$dir        = Join-Path $PSScriptRoot "..\packages\scoop"
$bucketList = Join-Path $dir "buckets.txt"
$scoopFile  = Join-Path $dir "scoopfile.json"

if (Test-Path $bucketList) {
    Write-Host "[scoop] bucket を追加します..."
    $existing = (scoop bucket list).Name

    Get-Content $bucketList | ForEach-Object {
        $line = $_.Trim()
        # 空行・コメント行はスキップ
        if (-not $line -or $line.StartsWith('#')) { return }

        # 「名前」と「URL(任意)」をスペースで分割
        $parts = $line -split '\s+', 2
        $name  = $parts[0]
        $url   = if ($parts.Count -gt 1) { $parts[1] } else { $null }

        if ($existing -contains $name) {
            Write-Host "  = $name (既存、スキップ)"
            return
        }

        if ($url) {
            Write-Host "  + $name  <$url>"
            scoop bucket add $name $url
        } else {
            Write-Host "  + $name (公式)"
            scoop bucket add $name
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