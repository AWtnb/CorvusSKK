function New-StartupShortcut {
    param (
        [string]$shortcutName,
        [string]$targetPath,
        [string]$argument = ""
    )
    $wsShell = New-Object -ComObject WScript.Shell
    $startMenu = $env:USERPROFILE | Join-Path -ChildPath "AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
    if (-not $shortcutName.EndsWith(".lnk")) {
        $shortcutName = $shortcutName + ".lnk"
    }
    $shortcutPath = $startMenu | Join-Path -ChildPath $shortcutName
    $shortcut = $wsShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    if ($argument.Length -gt 0) {
        $shortcut.Arguments = '"{0}"' -f $argument
    }
    $shortcut.Save()
}

try {
    $cmd = Get-Command "Code" -ErrorAction Stop
    $vscode = $cmd.Source | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath "code.exe"
    if (Test-Path $vscode) {
        $shortcutName = "{0}-on-vscode.lnk" -f ($PSScriptRoot | Split-Path -Leaf)
        New-StartupShortcut -shortcutName $shortcutName -targetPath $vscode -argument ('"{0}"' -f $PSScriptRoot)
        "Created shortcut on start menu: {0}" -f $shortcutName | Write-Host -ForegroundColor Blue
    }
    else {
        "Cannot find VSCode on '{0}'" -f $vscode | Write-Host -ForegroundColor Magenta
    }
}
catch {
    $_ | Write-Error
}

New-StartupShortcut -shortcutName "CorvusSKK-config.lnk" -targetPath "C:\Windows\System32\IME\IMCRVSKK\imcrvcnf.exe"
"Created shortcut on start menu: {0}" -f "CorvusSKK-config.lnk" | Write-Host -ForegroundColor Blue
