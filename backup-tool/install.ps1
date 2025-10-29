$config = Get-Content -Path $($PSScriptRoot | Join-Path -ChildPath "config.json") | ConvertFrom-Json

$taskPath = ("\{0}\" -f $config.taskPath) -replace "^\\+", "\" -replace "\\+$", "\"

$appDir = $env:APPDATA | Join-Path -ChildPath $config.appDirName
if (-not (Test-Path $appDir -PathType Container)) {
    New-Item -Path $appDir -ItemType Directory > $null
}

$backupDir = $env:USERPROFILE | Join-Path -ChildPath "Dropbox" | Join-Path -ChildPath "CorvusSKK-backup"
if (($args.Count -gt 0) -and ($args[0].Trim().Length -gt 0)) {
    $backupDir = $args[0].Trim()
}

$src = $PSScriptRoot | Join-Path -ChildPath "backup.ps1" | Copy-Item -Destination $appDir -PassThru

$action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$src`" `"$backupDir`""
$settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

$startupTaskName = "startup"
$startupTrigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

Register-ScheduledTask -TaskName $startupTaskName `
    -TaskPath $taskPath `
    -Action $action `
    -Trigger $startupTrigger `
    -Description "Copy CorvusSKK userdict.txt to backup directory on startup." `
    -Settings $settings `
    -Force
