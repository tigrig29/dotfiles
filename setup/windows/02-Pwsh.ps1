function Ensure-Pwsh {
    Write-Host "`n[3/7] Checking PowerShell Version..." -ForegroundColor Cyan
    if ($PSVersionTable.PSEdition -ne "Core") {
        Write-Host "Currently running in Windows PowerShell ($($PSVersionTable.PSVersion.ToString()))." -ForegroundColor Yellow
        Write-Host "pwsh (PowerShell Core) has been installed via Scoop." -ForegroundColor Yellow
        Write-Host "Please restart your terminal or run this script again in pwsh to continue the setup." -ForegroundColor Yellow
        Write-Host "Command to run: pwsh -File `"$PSCommandPath`"" -ForegroundColor Cyan
        exit
    }
    else {
        Write-Host "Running in pwsh ($($PSVersionTable.PSVersion.ToString())). Continuing..."
    }
}
