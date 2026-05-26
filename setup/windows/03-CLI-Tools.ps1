function Install-CLI-Tools {
    Write-Host "`n[5/7] Installing CLI tools via Scoop..." -ForegroundColor Cyan
    # If you want to add more apps, just add them to this array
    $apps = @(
        "gh",
        "ghq",
        "nvm",
        "neovim",
        "tree-sitter",
        "gcc",        # Needed for nvim-treesitter
        "ripgrep",    # Needed for Telescope/fzf
        "fd",         # Needed for Telescope/fzf
        "lazygit",    # Git UI
        "starship",   # Prompt
        "fzf",
        "eza",        # ls replacement
        "bat",        # cat replacement
        "delta",      # git diff viewer
        "zoxide",     # cd replacement
        "rustup",
        "python",
        "font-hackgen-console-nf",
        "zenhan"
    )

    $installedScoopApps = scoop list | Out-String
    foreach ($app in $apps) {
        if ($installedScoopApps -notmatch "(?im)^\s*$app\s") {
            Write-Host "Installing $app..."
            scoop install $app
        }
        else {
            Write-Host "$app is already installed."
        }
    }

    Write-Host "`nInstalling antigravity cli..."
    irm https://antigravity.google/cli/install.ps1 | iex
}
