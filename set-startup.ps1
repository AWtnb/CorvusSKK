param([parameter(Mandatory)]$path)
if (-not $path) {
    Write-Host "Specify crvskkserv.exe path."
} else {
    $wsShell = New-Object -ComObject WScript.Shell
    $startup = $env:USERPROFILE | Join-Path -ChildPath "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutPath = $startup | Join-Path -ChildPath ((Get-Item $path).BaseName + ".lnk")
    $shortcut = $wsShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $path
    $shortcut.Save()
    "Created shortcut on startup: {0}" -f $shortcutPath | Write-Host
}