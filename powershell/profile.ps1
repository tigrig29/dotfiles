# Aliases =============================================================

Set-Alias -Name cd -Value Push-Location -Option AllScope
Set-Alias -Name cdp -Value Pop-Location -Option None
Set-Alias -Name which -Value Get-Command -Option None

Set-Alias -Name g -Value git -Option None
Set-Alias -Name cod -Value code-insiders -Option None
Set-Alias -Name sudo -Value gsudo -Option None
Set-Alias -Name dn -Value dotnet -Option None
Set-Alias -Name dnr -Value Invoke-DotnetRun -Option None

Set-Alias -Name lsn -Value Get-ChildItem-Name-Only -Option None
Set-Alias -Name sln -Value Open-CurrentSln -Option None
Set-Alias -Name uni -Value Open-UnityEditor -Option None

# Cmdlet =============================================================

function New-OrUpdateFile ($filename) {
    if ($filename) {
        New-Item -Type FILE $filename
    }
    else {
        (Get-Item $filename).LastWriteTime = (Get-Date)
    }
}

function Get-ChildItem-Name-Only {
    Get-ChildItem -Name
}

function Open-CurrentSln {
    Get-ChildItem -Name -File -Include *.sln | Invoke-Item
}

function Open-UnityEditor {
    $project = Convert-Path .
    $version = (Get-Content .\ProjectSettings\ProjectVersion.txt)[0].Split(":")[1].Replace(" ", "")
    $unityEditor = "C:/Program Files/Unity/Hub/Editor/" + $version + "/Editor/Unity.exe"
    Start-Process $unityEditor -ArgumentList "-projectPath" , $project
}

function Invoke-DotnetRun {
    dotnet run
}

function Invoke-GhqFzf {
    # ghq root を取得
    $ghqRoot = ghq root

    if (-not $ghqRoot) {
        return
    }

    # ghq list → fzf
    $selectedRepo = ghq list |
    fzf `
        --preview "bat --color=always --style=header,grid --line-range :80 `"$ghqRoot/{}/README.*`""

    if ([string]::IsNullOrWhiteSpace($selectedRepo)) {
        return
    }

    Set-Location ( Join-Path $ghqRoot $selectedRepo )
}

function Invoke-HistoryFzf {
    Invoke-Expression ((Get-Content $(Get-PSReadLineOption).HistorySavePath) | fzf)
}

# KeyBindings =============================================================

Set-PSReadLineKeyHandler -Chord Ctrl+g -ScriptBlock { 
    Invoke-GhqFzf
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() 
}

Set-PSReadLineKeyHandler -Chord Ctrl+l -ScriptBlock { 
    Invoke-HistoryFzf
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() 
}

# Settings =============================================================

[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
$env:LESSCHARSET = "utf-8"

# 検索候補を一覧表示
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Variables
$global:pc = '@{-1}'
$global:me = 'TigRig'

# Disable beep sound
Set-PSReadlineOption -BellStyle None

# Disable UpdateCheck
$env:POWERSHELL_UPDATECHECK = 'Off'

# PowerShell の入力補完形式を ListView (下部に最近の履歴を表示) に変更
Set-PSReadlineOption -PredictionViewStyle ListView

# Module =============================================================

# oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/emodipt-extend.omp.json" | Invoke-Expression

# PoshGit
Import-Module posh-git

# ファイルやフォルダのアイコン表示
Import-Module -Name Terminal-Icons
