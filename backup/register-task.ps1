$taskPath = "\corvusskk-backup"

$appDir = $env:APPDATA | Join-Path -ChildPath "CorvusSKK-backup"
if (-not (Test-Path $appDir -PathType Container)) {
    New-Item -Path $appDir -ItemType Directory > $null
}

$src = $PSScriptRoot | Join-Path -ChildPath "backup.ps1" | Copy-Item -Destination $appDir -PassThru

$action = New-ScheduledTaskAction -Execute conhost.exe -Argument "--headless powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$src`""
$settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 30)

$startupTaskName = "startup"
$startupTrigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

if ($null -ne (Get-ScheduledTask -TaskName $startupTaskName -ErrorAction SilentlyContinue)) {
    Unregister-ScheduledTask -TaskName $startupTaskName -Confirm:$false
}

Register-ScheduledTask -TaskName $startupTaskName `
    -TaskPath $taskPath `
    -Action $action `
    -Trigger $startupTrigger `
    -Description "Copy CorvusSKK userdict.txt to backup directory on startup." `
    -Settings $settings
