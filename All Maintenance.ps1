
function Show-MainMenu {
    Clear-Host
    Write-Host "================ Options ================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1:  Local Computer Maintenance"
    Write-Host "2:  Network & Connectivity Tools"
    Write-Host "3:  Active Directory Tasks"
    Write-Host "Q:  Quit"
    Write-Host ""
}

function Show-MaintenanceMenu {
    Clear-Host
    Write-Host "================ Local Computer Maintenance ================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1: Clear Profile Temp Files"
    Write-Host "2: Get Installed Applications"
    Write-Host "3: Fix Windows Update"
    Write-Host "4: Get System Uptime"
    Write-Host "5: Test Network Connectivity"
    Write-Host "6: Restart Print Spooler"
    Write-Host "7: Repair Computer"
    Write-Host "B: Back to Main Menu"
    Write-Host ""
}

function Show-NetworkMenu {
    Clear-Host
    Write-Host "================ Network & Connectivity Tools ================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1: Ping Multiple Hosts"
    Write-Host "2: Test Port Connectivity"
    Write-Host "3: DNS Lookup"
    Write-Host "4: Trace Route"
    Write-Host "5: Get Network Adapters"
    Write-Host "6: Get IP Configuration"
    Write-Host "7: Flush DNS Cache"
    Write-Host "B: Back to Main Menu"
    Write-Host ""
}

function Show-ADMenu {
    Clear-Host
    Write-Host "================ Active Directory Tasks ================" -ForegroundColor Yellow
    Write-Host "**This requires RSAT to be installed on your machine**" -ForegroundColor DarkRed
    Write-Host ""
    Write-Host "1: Get Disabled Users"
    Write-Host "2: Get Locked Out Users"
    Write-Host "3: Search User by Name"
    Write-Host "4: Get User Group Memberships"
    Write-Host "B: Back to Main Menu"
    Write-Host ""
}

function Invoke-MaintenanceTasks {

    do {
        Show-MaintenanceMenu
        $choice = Read-Host "Select a menu option"

        switch ($choice) {

            '1' {
                $accountfolders = Get-ChildItem -Path "C:\Users"
                Write-Host "Accounts on the system are.." -ForegroundColor Yellow

                foreach ($account in $accountfolders) {
                    Write-Host $account.Name -ForegroundColor Magenta
                }

                $question = Read-Host "Which account would you like to have the App Data erased for?"

                foreach ($account in $accountfolders) {
                    if ($question -eq $account.Name) {

                        $tempPath = Join-Path $account.FullName "AppData\Local\Temp"

                        try {
                            Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Host "Temp contents deleted from $($account.Name)" -ForegroundColor Green
                        }
                        catch {
                            Write-Error $_
                        }
                    }
                }

                Pause
            }

            '2' {
                $paths = @(
                    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
                )

                Get-ItemProperty $paths -ErrorAction SilentlyContinue |
                    Where-Object { $_.DisplayName -and $_.DisplayName -ne "" } |
                    Select-Object DisplayName, DisplayVersion, Publisher |
                    Sort-Object DisplayName | Format-Table -AutoSize

                Pause
            }

            '3' {
                If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
                Write-Host "This option requires PowerShell be ran with admin rights. Relaunch PowerShell as admin" -ForegroundColor Red
                Pause
                return
                }
                
                Write-Host "Stopping windows services.`n" -ForegroundColor Yellow
            
                $Services = @{
                    service1 = "wuauserv"
                    service2 = "bits"
                    service3 = "cryptsvc"
                    service4 = "msiserver"
                }

                foreach ($Key in $services.Keys) {
                    $service = $Services[$Key]
                    Write-Host "Stopping $service" -ForegroundColor Red
                    Stop-Service -Name $service -Force
                    if (($servicename = Get-Service -Name $service).Status -eq "stopped") {
                        Write-Host "Services stopped. Proceeding.." -ForegroundColor Yellow
                    }
                }

                Start-Sleep -Seconds 2
            
                Write-Host "Renaming folder "$ENV:SystemRoot\SoftwareDistribution"" -ForegroundColor Yellow
                Write-Host "Renaming folder "$ENV:SystemRoot\System32\catroot2"" -ForegroundColor Yellow

                Rename-Item -Path "$ENV:SystemRoot\SoftwareDistribution" -NewName "OLD_SoftwareDistribution"
                Rename-Item -Path "$ENV:SystemRoot\System32\catroot2" -NewName "OLD_catroot2"

                foreach ($Key in $services.Keys) {
                    $service = $Services[$Key]
                    Write-Host "Starting $service" -ForegroundColor Green
                    Start-Service $service
                }

                Pause
            }

            '4' {
                $os = Get-CimInstance -ClassName Win32_OperatingSystem
                $uptime = (Get-Date) - $os.LastBootUpTime
                Write-Host "`nSystem Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes" -ForegroundColor Cyan
                Write-Host "Last Boot: $($os.LastBootUpTime)" -ForegroundColor Yellow
                Pause
            }

            '5' {
                $targets = @("8.8.8.8", "1.1.1.1", "google.com")
                foreach ($target in $targets) {
                    Test-Connection -ComputerName $target -Count 3 |
                    Select-Object Address, IPV4Address, ResponseTime
                }
                Pause
            }

            '6' {
                If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
                Write-Host "This option requires PowerShell be ran with admin rights. Relaunch PowerShell as admin" -ForegroundColor Red
                Pause
                return
                }

                Write-Host "Restarting Print Spooler service..." -ForegroundColor Yellow
                Restart-Service -Name spooler -Force
                Write-Host "Print Spooler restarted successfully!" -ForegroundColor Green
                Pause
            }

            '7' {
                If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
                Write-Host "This option requires PowerShell be ran with admin rights. Relaunch PowerShell as admin" -ForegroundColor Red
                Pause
                return
                }

                $cleaner = "C:\Windows\System32\cleanmgr.exe"
                $filechecker = "C:\Windows\System32\sfc.exe"
                Write-Host "Starting system performance optimizer..." -ForegroundColor Yellow
                Start-Process -FilePath $cleaner -ArgumentList "/autoclean" -Wait -NoNewWindow
                
                Start-Sleep -Seconds 5
                Write-Host "Starting Windows image check" -ForegroundColor Yellow
                $windowsimagecheck = Repair-WindowsImage -Online -ScanHealth
                if ($windowsimagecheck.ImageHealthState -eq "Healthy") {
                    Write-Host "Windows image is healthy." -ForegroundColor Green
                } else {
                    Write-Host "Windows image issues detected, running scan and repair..." -ForegroundColor Red
                    Repair-WindowsImage -Online -RestoreHealth
                }
                
                Start-Sleep -Seconds 5
                Write-Host "Starting system file checker" -ForegroundColor Yellow
                Start-Process -FilePath $filechecker -ArgumentList "/scannow" -Wait -NoNewWindow
                
                Start-Sleep -Seconds 5
                Write-Host "Starting Volume Repair Scan" -ForegroundColor Yellow
                Repair-Volume -DriveLetter C -Scan > $null
                Start-Sleep -Seconds 5
                if ($?) {
                    Write-Host "No errors found on the volume." -ForegroundColor Green
                } else {
                    Write-Host "Errors detected, starting volume repair..." -ForegroundColor Red
                    Repair-Volume -DriveLetter C
                }
                
                Start-Sleep -Seconds 5
                Write-Host "Tasks completed! You can close this window." -ForegroundColor Green
                Pause
            }
            'B' { return }
        }
    } while ($choice -ne 'B')
}

function Invoke-NetworkTasks {

    do {
        Show-NetworkMenu
        $choice = Read-Host "Select a menu option"

        switch ($choice) {

            '1' {
                $hosts = Read-Host "Enter the hostnames (comma-separated. No spaces)"
                $hosts = $hosts -split ','
                foreach ($h in $hosts) {
                    Test-Connection -ComputerName $h.Trim() -IPv4 -Count 3
                }
                Pause
            }

            '2' {
                $port = Read-Host "What port do you want to test? This will test using Google.com"
                Test-NetConnection -ComputerName "google.com" -Port $port
                Pause
            }

            '3' {
                $hostname = Read-Host "Enter hostname to lookup"
                Resolve-DnsName -Name $hostname
                Select-Object Name, Type, IPV4Address, NameHost | Format-Table -AutoSize
                Pause
            }

            '4' {
                $hostname = Read-Host "Enter hostname to trace"
                tracert $hostname
                Pause
            }

            '5' {
                Get-NetAdapter | Format-Table
                Pause
            }

            '6' {
                ipconfig /all
                Pause
            }

            '7' {
                ipconfig /flushdns
                Pause
            }

            '8' {

            }
            'B' { return } 
        }
    } while ($choice -ne 'B')
}

function Invoke-ADTasks {

    Do {
        Show-ADMenu
        $choice = Read-Host "Select a menu option"

        switch ($choice) {

            '1' {
                $path = Join-Path $HOME "Downloads\DisabledUsers.csv"
                $users = Search-ADAccount -UsersOnly -AccountDisabled | Select-Object Name, UserPrincipalName, Enabled
                $csv = Read-Host "Do you want these exported to a CSV?"
                if ($csv -match '^[Yy]') {
                    $csvoutput = $users | Export-Csv -Path $path -NoTypeInformation
                } else {
                    $users
                }
                Pause
            }

            '2' {
                $path = Join-Path $HOME "Downloads\LockedOutUsers.csv"
                $users = Search-ADAccount -UsersOnly -LockedOut | Select-Object Name, UserPrincipalName, LockedOut
                $csv = Read-Host "Do you want these exported to a CSV?"
                if ($csv -match '^[Yy]') {
                    $csvoutput = $users | Export-Csv -Path $path -NoTypeInformation
                } else {
                    $users | Out-Host
                }
                Pause
            }

            '3' {
                $name = Read-Host "What's the last name of the user?"
                Get-ADUser -Filter {Surname -eq $name}
                Pause
            }

            '4' {
                $user = Read-Host "Enter the MailNickname eg. Hrkerko"
                Write-Host ""
                $user = Get-ADUser -Identity $user -Properties MemberOf
                $user.MemberOf | ForEach-Object { ($_ -split ',')[0] -replace 'CN=' }
                Write-Host ""
                Pause
            }
            'B' { return } 
        }
    } while ($choice -ne 'B')
}

# ============= MAIN SCRIPT =============
do {
    Show-MainMenu
    $mainChoice = Read-Host "Select an option"
    
    switch ($mainChoice) {
        '1' { Invoke-MaintenanceTasks }
        '2' { Invoke-NetworkTasks }
        '3' { Invoke-ADTasks }
        'Q' { Exit }
    }
} while ($mainChoice -ne 'Q')