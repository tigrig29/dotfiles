# Dotfiles Setup Script for Windows
# Combines Scoop (CLI) and Winget (GUI)

$ErrorActionPreference = "Stop"
$setupDir = Join-Path $PSScriptRoot "setup\windows"

# Load modules
. (Join-Path $setupDir "01-Scoop.ps1")
. (Join-Path $setupDir "02-Pwsh.ps1")
. (Join-Path $setupDir "03-CLI-Tools.ps1")
. (Join-Path $setupDir "04-GUI-Apps.ps1")


# --- Main Execution ---

Install-Scoop
Install-BaseApps
Ensure-Pwsh
Add-ScoopBuckets
Install-CLI-Tools
Install-GUI-Apps

if (-not (Get-Command gsudo -ErrorAction SilentlyContinue)) {
    Write-Warning "gsudo is not installed. Please install gsudo to setup symlinks."
    exit 1
}

$symlinkScript = Join-Path $setupDir "05-Symlinks.ps1"
gsudo pwsh -NoProfile -Command ". `"$symlinkScript`"; Setup-Symlinks"

Write-Host "`nSetup Complete! Please restart your terminal." -ForegroundColor Green
