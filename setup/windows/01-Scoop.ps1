function Install-Scoop {
    Write-Host "`n[1/7] Setting up Scoop..." -ForegroundColor Cyan
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..."
        # Check if running as administrator
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host "Running as administrator. Attempting all-user Scoop installation."
            # For all-user installation of Scoop when running as admin
            # Temporarily set ExecutionPolicy for LocalMachine
            $originalExecutionPolicy = Get-ExecutionPolicy -Scope LocalMachine
            Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

            # Restore original ExecutionPolicy for LocalMachine
            Set-ExecutionPolicy $originalExecutionPolicy -Scope LocalMachine -Force

            # Complete all-user Scoop installation
            scoop install scoop
        }
        else {
            Write-Host "Running as regular user. Attempting current-user Scoop installation."
            # For current-user installation of Scoop when running as regular user
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        }
    }
    else {
        Write-Host "Scoop is already installed."
    }
}

function Install-BaseApps {
    Write-Host "`n[2/7] Installing Base apps (git, pwsh) via Scoop..." -ForegroundColor Cyan
    $apps = @("git", "pwsh")
    foreach ($app in $apps) {
        if (-not (Get-Command $app -ErrorAction SilentlyContinue)) {
            Write-Host "Installing $app..."
            scoop install $app
        }
        else {
            Write-Host "$app is already installed."
        }
    }
}

function Add-ScoopBuckets {
    Write-Host "`n[4/7] Adding Scoop buckets..." -ForegroundColor Cyan
    scoop bucket add extras  # For GUI apps
    scoop bucket add versions  # For alternative versions
    scoop bucket add nerd-fonts  # For fonts like Hack-NF
    scoop bucket add mo-san https://github.com/mo-san/scoop-bucket # For HackGen
}
