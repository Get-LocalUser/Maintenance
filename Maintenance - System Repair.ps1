<#
=============================================================================================
Name:           System Repair
Description:    This script executes common commands that check and repair Windows files, volumes etc.
Prerequisites:  N/A

Script Tasks: 
~~~~~~~~~~~~~~~~~
1. Checks if you ran the script as Administrator and if not relaunches as Administrator.
2. Executes Disk-Cleanup.
3. Executes SFC and performs repair if needed.
4. Executes Repair-Volume and performs reapir if needed.
5. Executes Repair-WindowsImage and performs repair if needed.
============================================================================================
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue." -ForegroundColor Red
    Start-Sleep 3
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    exit
}

$cleaner = "C:\Windows\System32\cleanmgr.exe"
$filechecker = "C:\Windows\System32\sfc.exe"

Write-Host "Starting system performance optimizer..." -ForegroundColor Yellow
Start-Process -FilePath $cleaner -ArgumentList "/autoclean" -Wait -NoNewWindow
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

Write-Host "Starting Windows image check" -ForegroundColor Yellow
$windowsimagecheck = Repair-WindowsImage -Online -CheckHealth

if ($windowsimagecheck.ImageHealthState -eq "Healthy") {
    Write-Host "Windows image is healthy." -ForegroundColor Green
} else {
    Write-Host "Windows image issues detected, running scan and repair..." -ForegroundColor Red
    Repair-WindowsImage -Online -ScanHealth
}

Start-Sleep -Seconds 5
Write-Host "Tasks completed! You can close this window." -ForegroundColor Green