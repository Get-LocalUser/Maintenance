<#
=============================================================================================
Name:           Maintenance - Empty Local Temp
Description:    This script deletes the contents AppData\Local\Temp to help with declutter as well as the ShareFile Add-in issue in Outlook.
Prerequisites:  N/A

Script Tasks: 
~~~~~~~~~~~~~~~~~
1. Exludes certain accounts from script execution.
2. Deletes the contents of the local temp in each user account not listed in $accounts
============================================================================================
#>
 
$accounts = @("Administrator", "AutopilotDiagnostics", "DefaultAccount", "defaultuser", "defaultuser0", "Guest", "WDAGUtilityAccount")
 
$folder = Get-ChildItem -Path "C:\Users" -Exclude $accounts
$join = @(Join-Path $folder "AppData\Local\Temp")
Write-Host "Emptying contents. This could take a while..." -ForegroundColor Yellow
foreach ($joined in $join) {
    try {
        Remove-Item -Path $joined -Recurse -ErrorAction SilentlyContinue
        Write-Host "Temp contents deleted from $joined"
    }
    catch {
        Write-Error $_
    }
}