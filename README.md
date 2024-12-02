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

