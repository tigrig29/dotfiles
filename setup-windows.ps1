# Dotfiles Setup Script for Windows
# Combines Scoop (CLI) and Winget (GUI)

$ErrorActionPreference = "Stop"

function Install-Scoop {
    Write-Host "`n[1/4] Setting up Scoop..." -ForegroundColor Cyan
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

    Write-Host "Adding Scoop buckets..."
    scoop bucket add extras  # For GUI apps
    scoop bucket add versions  # For alternative versions
    scoop bucket add nerd-fonts  # For fonts like Hack-NF
}

function Install-CLI-Tools {
    Write-Host "`n[2/4] Installing CLI tools via Scoop..." -ForegroundColor Cyan
    # If you want to add more apps, just add them to this array
    $apps = @(
        "git",
        "gh",
        "ghq",
        "nvm",
        "neovim",
        "gcc",        # Needed for nvim-treesitter
        "ripgrep",    # Needed for Telescope/fzf
        "fd",         # Needed for Telescope/fzf
        "lazygit",    # Git UI
        "starship",   # Prompt
        "fzf",
        "eza",        # ls replacement
        "bat",        # cat replacement
        "delta",      # git diff viewer
        "zoxide"      # cd replacement
    )

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

function Install-GUI-Apps {
    Write-Host "`n[3/4] Installing GUI apps via Winget..." -ForegroundColor Cyan

    $apps = @(
        # 基盤
        "Google.JapaneseIME",
        "Microsoft.PowerToys",
        # ブラウザ
        "Google.Chrome",
        "Brave.Brave",
        "Mozilla.Firefox",
        # 開発
        "wez.wezterm",
        "gerardog.gsudo",
        "Microsoft.VisualStudioCode",
        "Unity.UnityHub",
        "Figma.Figma",
        # ノート
        "Notion.Notion",
        "Obsidian.Obsidian",
        # 連絡
        "Discord.Discord",
        "Mozilla.Thunderbird",
        "Amazon.Kindle",
        #ゲーム
        "Valve.Steam"
    )

    foreach ($id in $apps) {
        # Explicitly check if the app is already installed to avoid unnecessary install attempts
        $installed = winget list --id $id | Select-String $id
        if (-not $installed) {
            Write-Host "Installing $id..."
            winget install --id $id -e --source winget --accept-source-agreements --accept-package-agreements
        }
        else {
            Write-Host "$id is already installed."
        }
    }
}

function Setup-Symlinks {
    Write-Host "`n[4/4] Linking Dotfiles..." -ForegroundColor Cyan

    $dotfiles = Split-Path -Parent $PSCommandPath
    $config = "$env:USERPROFILE\.config"

    if (-not (Test-Path $config)) { New-Item -ItemType Directory -Path $config | Out-Null }

    # Helper function to create symlink
    function Link-File {
        param($Src, $Dest)
        if (Test-Path $Dest) {
            Write-Host "  Skipping $Dest (already exists)" -ForegroundColor DarkGray
        }
        else {
            Write-Host "  Linking $Dest -> $Src"
            New-Item -ItemType SymbolicLink -Path $Dest -Value $Src | Out-Null
        }
    }

    # Neovim
    Link-File -Src "$dotfiles\nvim" -Dest "$env:LOCALAPPDATA\nvim"

    # WezTerm (Using XDG standard path)
    Link-File -Src "$dotfiles\wezterm" -Dest "$config\wezterm"

    # Starship
    Link-File -Src "$dotfiles\starship.toml" -Dest "$config\starship.toml"

    # PowerShell Profile
    # $PROFILE is usually Documents\PowerShell\Microsoft.PowerShell_profile.ps1
    $psDir = Split-Path $PROFILE
    if (-not (Test-Path $psDir)) { New-Item -ItemType Directory -Path $psDir | Out-Null }

    # Instead of replacing the profile, we source our dotfiles profile
    # Using format operator -f to avoid escaping issues
    $profilePath = "$dotfiles\powershell\profile.ps1"
    $loadCmd = '. "{0}"' -f $profilePath

    if (Test-Path $PROFILE) {
        $content = Get-Content $PROFILE -Raw
        if ($null -eq $content) {
            $content = ''
        }

        if ($content -notmatch "dotfiles\\powershell\\profile.ps1") {
            Write-Host "  Appending to existing PowerShell profile..."
            Add-Content -Path $PROFILE -Value "`n$loadCmd"
        }
        else {
            Write-Host "  PowerShell profile already configured." -ForegroundColor DarkGray
        }
    }
    else {
        Write-Host "  Creating PowerShell profile..."
        Set-Content -Path $PROFILE -Value $loadCmd
    }

    # gitconfig
    $gitconfigPath = "$env:USERPROFILE\.gitconfig"
    $dotfilesGitconfigPath = "$dotfiles\git\common.gitconfig" -replace '\\', '/'
    $includeSetting = "[include]`n  path = {0}" -f $dotfilesGitconfigPath

    if (Test-Path $gitconfigPath) {
        $content = Get-Content $gitconfigPath -Raw

        if ($content -notmatch "dotfiles\\git\\common.gitconfig") {
            Write-Host "  Appending to existing .gitconfig..."
            $includeSetting + "`n`n" + $content | Out-File $gitconfigPath -Encoding UTF8 -NoNewLine
        }
        else {
            Write-Host "  .gitconfig already configured." -ForegroundColor DarkGray
        }
    }
    else {
        Write-Host "  Creating .gitconfig..."
        Set-Content -Path $gitconfigPath -Value $includeSetting
    }

    # lazygit
    Link-File -Src "$dotfiles\git\lazygit" -Dest "$env:LOCALAPPDATA\lazygit"
}

# --- Main Execution ---

Install-Scoop
Install-CLI-Tools
Install-GUI-Apps
Setup-Symlinks

Write-Host "`nSetup Complete! Please restart your terminal." -ForegroundColor Green
