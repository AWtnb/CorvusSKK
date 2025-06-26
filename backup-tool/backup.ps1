$maxGen = 15

if (($args.Length -lt 1) -or ($args[0].Trim().Length -lt 1)) {
    $log = "{0} Backup dest path is not specified." -f (Get-Date -Format "yyyyMMdd-HH:mm:ss")
    $log | Out-File -FilePath ($env:USERPROFILE | Join-Path -ChildPath "Desktop\CorvusSKK-backup-error.log") -Append
    [System.Environment]::exit(1)
}

$backupDir = $args[0].Trim()
if (-not (Test-Path $backupDir -PathType Container)) {
    New-Item -Path $backupDir -ItemType Directory > $null
}

function logWrite {
    param (
        [switch]$asError
    )
    $log = $input -join ""
    if ($asError) {
        $log = "[ERROR] " + $log
    }
    $log = (Get-Date -Format "yyyyMMdd-HH:mm:ss ") + $log
    $log | Out-File -FilePath ($backupDir | Join-Path -ChildPath "backup.log") -Append
}

$src = $env:APPDATA | Join-Path -ChildPath "CorvusSKK\userdict.txt"
if (-not (Test-Path $src)) {
    "'{0}' not found." -f $src | logWrite -asError
    [System.Environment]::exit(1)
}

try {
    $backups = @(Get-ChildItem $backupDir -Filter "*.txt")
    if ($backups.Count -gt 0) {
        $lastHash = ($backups | Sort-Object -Property LastWriteTime | Select-Object -Last 1 | Get-FileHash).Hash
        if ((Get-FileHash -Path $src).Hash -eq $lastHash) {
            "skipped (userdict not updated since last backup)" -f $src | logWrite
            [System.Environment]::exit(0)
        }
    }

    $backupCountBeforeRun = $backups.Count

    $backupName = "{0}{1}.txt" -f (Get-Item $src).BaseName, (Get-Date -Format "yyyyMMddHHmmss")
    $copyAs = $backupDir | Join-Path -ChildPath $backupName
    Get-Item -Path $src | Copy-Item -Destination $copyAs -ErrorAction Stop
    "backup finished." | logWrite

    if ($backupCountBeforeRun -eq $maxGen) {
        $oldest = $backups | Sort-Object -Property LastWriteTime | Select-Object -First 1
        $oldest | Remove-Item -ErrorAction stop
        "removed oldest backup '{0}'." -f $oldest.Name | logWrite
    }
}
catch {
    $_ | logWrite -asError
    [System.Environment]::exit(1)
}

[System.Environment]::exit(0)
