function Ensure-Pwsh {
    Write-Host "`n[3/7] Checking PowerShell Version & Settings..." -ForegroundColor Cyan

    # 起動時の更新通知クラッシュ（全角・ターミナル幅計算バグ）回避のため、OSユーザー環境変数に恒久設定
    if ([System.Environment]::GetEnvironmentVariable("POWERSHELL_UPDATECHECK", "User") -ne "Off") {
        Write-Host "Setting POWERSHELL_UPDATECHECK=Off (User Environment Variable)..."
        [System.Environment]::SetEnvironmentVariable("POWERSHELL_UPDATECHECK", "Off", "User")
    }

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
