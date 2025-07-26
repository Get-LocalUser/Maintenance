# Define log names
$LogNamesTable = @{
    1 = 'Application'
    2 = 'Security'
    3 = 'Setup'
    4 = 'System'
}

# Write out the log names
Write-Host "Available log names are:"
$LogNamesTable.Values | ForEach-Object { Write-Host $_ -ForegroundColor Magenta }

# Get the log you want to check and see if it matches any available logs
$Question = Read-Host "Which log would you like to check?"

if ($LogNamesTable.Values -contains $Question) {
    #Write-Host "Checking 'Application' logs.." -ForegroundColor Yellow

    # Define log levels
    $Levels = @{
        1 = 'Critical'
        2 = 'Error'
        3 = 'Warning'
        4 = 'Information'
        5 = 'Verbose'
        6 = 'Debug'
    }

    # Write out the log levels
    Write-Host "`nAvailable log levels are:"
    $Levels.Values | ForEach-Object { Write-Host $_ -ForegroundColor Magenta }

    # Get the log level you want to check
    $Level = Read-Host "Which log level would you like to check?"
    [int]$Events = Read-Host "In number format, how many logs would you like displayed?"

    if ($Levels.Values -contains $Level) {
        # Convert level name to number
        $LevelNumber = ($Levels.GetEnumerator() | Where-Object { $_.Value -eq $Level }).Key

        # Get the logs for the specified logname and level
        Get-WinEvent -FilterHashtable @{
            LogName = $Question
            Level = $LevelNumber
        } -MaxEvents $Events | Format-List
    }
}