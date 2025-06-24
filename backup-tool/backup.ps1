$maxGen = 5

$backupDir = $env:USERPROFILE | Join-Path -ChildPath "Dropbox" | Join-Path -ChildPath "CorvusSKK-backup"
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
    $log = $(Get-Date -Format "yyyyMMdd-HH:mm:ss ") + $log
    $log | Out-File -FilePath $($backupDir | Join-Path -ChildPath "backup.log") -Append
}

$src = $env:APPDATA | Join-Path -ChildPath "CorvusSKK\userdict.txt"
if (-not (Test-Path $src)) {
    "'{0}' not found." -f $src | logWrite -asError
    [System.Environment]::exit(1)
}

try {
    $backups = @(Get-ChildItem $backupDir -Filter "*.txt")
    if ($backups.Count -gt 0) {
        $srcHash = $(Get-Item $src | Get-FileHash).Hash
        $lastHash = $($backups | Sort-Object -Property LastWriteTime | Select-Object -Last 1 | Get-FileHash).Hash
        if ($srcHash -eq $lastHash) {
            "skipped (userdict not updated since last backup)" -f $src | logWrite
            [System.Environment]::exit(0)
        }
    }

    if ($backups.Count -ge $maxGen) {
        $oldest = $backups | Sort-Object -Property LastWriteTime | Select-Object -First 1
        $oldest | Remove-Item -ErrorAction stop
        "removed oldest backup '{0}'." -f $oldest.Name | logWrite
    }

    $backupName = "{0}{1}.txt" -f (Get-Item $src).BaseName, (Get-Date -Format "yyyyMMddHHmmss")
    $copyAs = $backupDir | Join-Path -ChildPath $backupName
    Get-Item -Path $src | Copy-Item -Destination $copyAs -ErrorAction Stop
    "backup finished." | logWrite
}
catch {
    $_ | logWrite -asError
    [System.Environment]::exit(1)
}

[System.Environment]::exit(0)
