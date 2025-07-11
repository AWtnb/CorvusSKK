# README

[CorvusSKK](https://nathancorvussolis.github.io/)の個人用カスタマイズ。

## Install

- [`install.ps1`](./install.ps1) を実行して `CorvusSKK` のジャンクションをAppDataに作成すると、以降はその内容がロードされるようになる。
- このリポジトリをVSCodeで開くショートカットをスタートメニューに登録するには [`set-startmenu.ps1`](./set-startmenu.ps1) を実行する。
- [`backup-tool/install.ps1`](./backup-tool/install.ps1) は [backup-tool/backup.ps1](./backup-tool/backup.ps1) を `$env:AppData\CorvusSKK-backup-tool` にコピーし、起動時に実行するタスクを登録する。
    - バックアップ先は `backup-tool/install.ps1` の実行時にコマンドライン引数で指定する。デフォルトだと `$env:USERPROFILE\Dropbox\CorvusSKK-backup` にバックアップする。
    - [`backup-tool/uninstall.ps1`](./backup-tool/uninstall.ps1) で関連データを削除可能。

### SKKサーバ

1. [リポジトリ](https://github.com/nathancorvussolis/crvskkserv/releases/) から最新版をダウンロード
1. [`set-startup.ps1`](set-startup.ps1) を実行してスタートアップに登録（`crvskkserv.exe` のパスを引数に指定する）

    ```
    .\set-startup.ps1 "$env:USERPROFILE\Personal\crvskkserv\crvskkserv.exe"
    ```

Syncthing使用時は下記の内容を `.stignore` に記載して同期の対象外にする。

```
(?d)CorvusSKK/*dict.txt
```

## Windowsシステム設定

インストールされているIMEの確認：

```
PS> Get-WinUserLanguageList

LanguageTag     : ja
Autonym         : 日本語
EnglishName     : Japanese
LocalizedName   : 日本語
ScriptName      : 日本語
InputMethodTips : {0411:{EAEA0E29-AA1E-48EF-B2DF-46F4E24C6265}{956F14B3-5310-4CEF-9651-26710EB72F3A}, 0411:{03B5835F-F03C-411B-9CE2-AA23E1171E36}{A76C93D9-5523-4E90-AAFA-4DB112F9AC76}}
Spellchecking   : True
Handwriting     : True

PS> (Get-WinUserLanguageList).InputMethodTips
0411:{EAEA0E29-AA1E-48EF-B2DF-46F4E24C6265}{956F14B3-5310-4CEF-9651-26710EB72F3A}
0411:{03B5835F-F03C-411B-9CE2-AA23E1171E36}{A76C93D9-5523-4E90-AAFA-4DB112F9AC76}

```

下記で設定を変更することも可能。

```PowerShell
Set-WinDefaultInputMethodOverride -InputTip "0411:{EAEA0E29-AA1E-48EF-B2DF-46F4E24C6265}{956F14B3-5310-4CEF-9651-26710EB72F3A}"
```

