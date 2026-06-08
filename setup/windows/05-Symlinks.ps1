function Setup-Symlinks {
    Write-Host "`n[7/7] ドットファイルのリンクを作成しています..." -ForegroundColor Cyan

    # 05-Symlinks.ps1 is in setup\windows, so we go up 3 levels to get the repository root
    $dotfiles = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
    $config = "$env:USERPROFILE\.config"

    if (-not (Test-Path $config)) { New-Item -ItemType Directory -Path $config | Out-Null }

    $elevatedCmds = New-Object System.Collections.ArrayList

    # Helper function to create symlink
    function Link-File {
        param($Src, $Dest)
        if (Test-Path $Dest) {
            Write-Host "  スキップ: $Dest (すでに存在します)" -ForegroundColor DarkGray
        }
        elseif (-not (Test-Path $Src)) {
            Write-Host "  スキップ: $Dest (リンク元が存在しません)" -ForegroundColor DarkGray
        }
        else {
            Write-Host "  リンク作成: $Dest -> $Src"
            if ((Get-Item $Src) -is [System.IO.DirectoryInfo]) {
                New-Item -ItemType Junction -Path $Dest -Value $Src | Out-Null
            }
            else {
                try {
                    New-Item -ItemType SymbolicLink -Path $Dest -Value $Src -ErrorAction Stop | Out-Null
                } catch {
                    Write-Host "    シンボリックリンク作成をキューに追加しました: $Dest..." -ForegroundColor Yellow
                    $elevatedCmds.Add("New-Item -ItemType SymbolicLink -Path '$Dest' -Value '$Src' -ErrorAction Stop | Out-Null") | Out-Null
                }
            }
        }
    }

    # Neovim
    Link-File -Src "$dotfiles\nvim" -Dest "$env:LOCALAPPDATA\nvim"

    # WezTerm (Using XDG standard path)
    Link-File -Src "$dotfiles\wezterm" -Dest "$config\wezterm"

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
            Write-Host "  既存のPowerShellプロファイルに追記しています..."
            Add-Content -Path $PROFILE -Value "`n$loadCmd"
        }
        else {
            Write-Host "  PowerShellプロファイルはすでに設定されています。" -ForegroundColor DarkGray
        }
    }
    else {
        Write-Host "  PowerShellプロファイルを作成しています..."
        Set-Content -Path $PROFILE -Value $loadCmd
    }

    # gitconfig
    $gitconfigPath = "$env:USERPROFILE\.gitconfig"
    $dotfilesGitconfigPath = "$dotfiles\git\common.gitconfig" -replace '\\', '/'
    $includeSetting = "[include]`n  path = {0}" -f $dotfilesGitconfigPath

    if (Test-Path $gitconfigPath) {
        $content = Get-Content $gitconfigPath -Raw

        if ($content -notmatch "dotfiles\\git\\common.gitconfig") {
            Write-Host "  既存の .gitconfig に追記しています..."
            $includeSetting + "`n`n" + $content | Out-File $gitconfigPath -Encoding UTF8 -NoNewLine
        }
        else {
            Write-Host "  .gitconfig はすでに設定されています。" -ForegroundColor DarkGray
        }
    }
    else {
        Write-Host "  .gitconfig を作成しています..."
        Set-Content -Path $gitconfigPath -Value $includeSetting
    }

    # lazygit
    Link-File -Src "$dotfiles\git\lazygit" -Dest "$env:LOCALAPPDATA\lazygit"

    # gemini
    $geminiDest = "$env:USERPROFILE\.gemini"
    if (-not (Test-Path $geminiDest)) {
        New-Item -ItemType Directory -Path $geminiDest | Out-Null
    }

    $geminiSrcDir = "$dotfiles\ai-agents\gemini"
    
    Link-File -Src "$geminiSrcDir\settings.json" -Dest "$geminiDest\settings.json"
    Link-File -Src "$geminiSrcDir\GEMINI.md" -Dest "$geminiDest\GEMINI.md"
    Link-File -Src "$geminiSrcDir\skills" -Dest "$geminiDest\skills"
    Link-File -Src "$geminiSrcDir\commands" -Dest "$geminiDest\commands"
    Link-File -Src "$geminiSrcDir\agents" -Dest "$geminiDest\agents"

    # agents
    $agentsDest = "$env:USERPROFILE\.agents"
    if (-not (Test-Path $agentsDest)) {
        New-Item -ItemType Directory -Path $agentsDest | Out-Null
    }
    
    Link-File -Src "$geminiSrcDir\skills" -Dest "$agentsDest\skills"

    if ($elevatedCmds.Count -gt 0) {
        Write-Host "`n  キューに追加されたシンボリックリンクを作成するため、gsudo経由で管理者権限を要求しています..." -ForegroundColor Yellow
        $cmdBlock = $elevatedCmds -join "; "
        $encodedCmd = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($cmdBlock))
        try {
            gsudo powershell -NoProfile -EncodedCommand $encodedCmd
            Write-Host "  キューに追加されたシンボリックリンクの作成に成功しました。" -ForegroundColor Green
        } catch {
            Write-Host "  gsudoを使用したシンボリックリンクの作成に失敗しました。" -ForegroundColor Red
            throw $_
        }
    }
}
