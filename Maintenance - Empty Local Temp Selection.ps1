$accountfolders = Get-ChildItem -Path "C:\Users"

Write-host "Accounts on the system are.." -ForegroundColor Yellow
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
