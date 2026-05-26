function Setup-Symlinks {
    Write-Host "`n[7/7] Linking Dotfiles..." -ForegroundColor Cyan

    $dotfiles = Split-Path -Parent $PSCommandPath
    $config = "$env:USERPROFILE\.config"

    if (-not (Test-Path $config)) { New-Item -ItemType Directory -Path $config | Out-Null }

    # Helper function to create symlink
    function Link-File {
        param($Src, $Dest, $DestType = "File")
        if (Test-Path $Dest) {
            Write-Host "  Skipping $Dest (already exists)" -ForegroundColor DarkGray
        }
        else {
            Write-Host "  Linking $Dest -> $Src"
            if ($DestType -eq "Directory") {
              New-Item -Type Directory $Dest
            }
            New-Item -ItemType Junction -Path $Dest -Value $Src | Out-Null
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

    # gemini
    Link-File -Src "$dotfiles\ai-agents\gemini" -Dest "$env:USERPROFILE\.gemini" -DestType Directory
}
