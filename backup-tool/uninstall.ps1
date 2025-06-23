$config = Get-Content -Path $($PSScriptRoot | Join-Path -ChildPath "config.json") | ConvertFrom-Json
$($config.taskName | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
    Unregister-ScheduledTask -TaskPath $config.taskPath -TaskName $_ -Confirm:$false -ErrorAction SilentlyContinue
}
$env:APPDATA | Join-Path -ChildPath $config.appDirName | Get-Item -ErrorAction SilentlyContinue | Remove-Item -Recurse -ErrorAction SilentlyContinue

$schedule = New-Object -ComObject Schedule.Service
$schedule.connect()
$root = $schedule.GetFolder("\")
$root.DeleteFolder($config.taskPath.TrimStart("\").TrimEnd("\"), $null)