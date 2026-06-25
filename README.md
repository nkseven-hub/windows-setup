# windows-setup

ChocolateyとScoopでWindows環境を再現するためのリポジトリ。
**権限の都合で2段階に分けて実行します。**

## セットアップ手順

### 1. リポジトリを取得
$url = "https://raw.githubusercontent.com/nkseven-hub/windows-setup/main/bootstrap-fetch.ps1"
irm $url | iex

### 2. 管理者パート（Chocolatey系・OS設定）
PowerShellを「管理者として実行」で開き:
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\bootstrap-admin.ps1

### 3. ユーザーパート（Scoop系・設定配置）
**通常の（管理者ではない）** PowerShellを開き直して:
    .\bootstrap-user.ps1

> Scoopは管理者セッションを拒否するため、必ず分けて実行してください。

## 既存環境からパッケージリストを更新する
    scoop export > packages\scoop\scoopfile.json
    # chocoは現状を手動でpackages.configに反映、もしくはchoco exportを利用
