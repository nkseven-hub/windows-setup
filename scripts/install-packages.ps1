# Chocolatey
choco install packages/chocolatey/packages.config -y

# Scoop の bucket を追加してから import
Get-Content packages/scoop/buckets.txt | ForEach-Object { scoop bucket add $_ }
scoop import packages/scoop/scoopfile.json
