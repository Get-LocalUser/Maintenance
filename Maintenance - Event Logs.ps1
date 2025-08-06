$LogNamesTable = @{
    1 = 'Application'
    2 = 'Security'
    3 = 'Setup'
    4 = 'System'
}

Write-Host "Available log names are:"
$LogNamesTable.Values | ForEach-Object { Write-Host $_ -ForegroundColor Magenta }

$Question = Read-Host "Which log would you like to check?"

if ($LogNamesTable.Values -contains $Question) {

    $Levels = @{
        1 = 'Critical'
        2 = 'Error'
        3 = 'Warning'
        4 = 'Information'
        5 = 'Verbose'
        6 = 'Debug'
    }

    Write-Host "`nAvailable log levels are:"
    $Levels.Values | ForEach-Object { Write-Host $_ -ForegroundColor Magenta }

    $Level = Read-Host "Which log level would you like to check?"
    [int]$Events = Read-Host "In number format, how many logs would you like displayed?"

    if ($Levels.Values -contains $Level) {
        $LevelNumber = ($Levels.GetEnumerator() | Where-Object { $_.Value -eq $Level }).Key

        Get-WinEvent -FilterHashtable @{
            LogName = $Question
            Level = $LevelNumber
        } -MaxEvents $Events | Format-List
    }
}
