# README

CorvusSKKの個人用カスタマイズ。

## Install

```PowerShell
$d = "CorvusSKK"; New-Item -Path ($env:APPDATA | Join-Path -ChildPath $d) -Value ($pwd.Path | Join-Path -ChildPath $d) -ItemType Junction
```

- サーバを使用する場合、 [`crvskkserv.ini`](crvskkserv.ini) を `crvskkserv.exe` と同じフォルダにコピーするかシンボリックリンクを作成する。
- Syncthing使用時は下記の内容を `.stignore` に記載して同期の対象外にする。

    ```
    CorvusSKK/*dict.txt
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

