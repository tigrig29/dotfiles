# Settings =============================================================

[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
$env:LESSCHARSET = "utf-8"

# 検索候補を一覧表示
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Disable beep sound
Set-PSReadlineOption -BellStyle None

# Disable UpdateCheck
$env:POWERSHELL_UPDATECHECK = 'Off'

# PowerShell の入力補完形式を ListView (下部に最近の履歴を表示) に変更
Set-PSReadlineOption -PredictionViewStyle ListView

# 文字コードを UTF-8 に統一
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Aliases =============================================================

Set-Alias -Name cd -Value Push-Location -Option AllScope
Set-Alias -Name cdp -Value Pop-Location -Option None
Set-Alias -Name which -Value Get-Command -Option None
Set-Alias -Name cdb -Value Invoke-PushLocationBack -Option None

Set-Alias -Name g -Value git -Option None
Set-Alias -Name lg -Value lazygit -Option None
Set-Alias -Name cod -Value code-insiders -Option None
Set-Alias -Name sudo -Value gsudo -Option None
Set-Alias -Name dn -Value dotnet -Option None
Set-Alias -Name v -Value nvim -Option None

Set-Alias -Name dnr -Value Invoke-DotnetRun -Option None
Set-Alias -Name lsn -Value Get-ChildItem-Name-Only -Option None
Set-Alias -Name sln -Value Open-CurrentSln -Option None
Set-Alias -Name uni -Value Open-UnityEditor -Option None
Set-Alias -Name gmi -Value Invoke-Gemini
Set-Alias -Name wtcd -Value Set-GitWorktreeLocation
Set-Alias -Name memo -Value Open-Memo

# Cmdlet =============================================================

function Invoke-PushLocationBack {
    param (
        [int]$Count = 1
    )
    for ($i = 0; $i -lt $Count; $i++) {
        Push-Location ../
    }
}

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
    $selectedRepo = ghq list | fzf

    if ([string]::IsNullOrWhiteSpace($selectedRepo)) {
        return
    }

    Set-Location ( Join-Path $ghqRoot $selectedRepo )
}

function Invoke-HistoryFzf {
    Invoke-Expression ((Get-Content $(Get-PSReadLineOption).HistorySavePath) | fzf)
}

function Invoke-Gemini {
    powershell -ExecutionPolicy Bypass -Command "gemini $args"
}

function Set-GitWorktreeLocation {
    <#
    .SYNOPSIS
        fzfを使用してGit worktreeを選択し、そのディレクトリに移動します。
    #>
    $selected = git worktree list --porcelain | ForEach-Object {
        if ($_ -match "^worktree (.+)") { $path = $matches[1] }
        elseif ($_ -match "^branch (.+)") {
            $branch = $matches[1] -replace "refs/heads/", ""
            "$path`t$branch"
        }
    } | fzf --height 40% --reverse --header "Select Worktree" `
            --preview "git -C {1} log --oneline --color=always -n 10" `
            --no-multi

    if ($selected) {
        $targetPath = $selected.Split("`t")[0]
        Set-Location $targetPath
    }
}
function Open-Memo {
    # メモの保存先ディレクトリ（必要に応じてパスを変更してください）
    $memo_dir = "$HOME\memos"

    # ディレクトリが存在しない場合は自動作成
    if (-not (Test-Path $memo_dir)) {
        New-Item -ItemType Directory -Force -Path $memo_dir | Out-Null
    }

    # ファイル名を今日の日付にする（例: 2026-05-18.md）
    $date_str = Get-Date -Format "yyyy-MM-dd"
    $filepath = Join-Path -Path $memo_dir -ChildPath "$date_str.txt"

    # 起動待ち時間を無くすためにプラグインを読み込まず（--clean）起動
    # 開いた瞬間にインサートモードに入る（+startinsert）
    & nvim $filepath
}

# KeyBindings =============================================================

Set-PSReadLineKeyHandler -Chord Alt+h -ScriptBlock { 
    Invoke-GhqFzf
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() 
}

Set-PSReadLineKeyHandler -Chord Alt+l -ScriptBlock { 
    Invoke-HistoryFzf
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() 
}

Set-PSReadLineKeyHandler -Chord Alt+g -ScriptBlock { 
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('gmi -y')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() 
}

# Module =============================================================

# oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/emodipt-extend.omp.json" | Invoke-Expression

# PoshGit
Import-Module posh-git

# ファイルやフォルダのアイコン表示
Import-Module -Name Terminal-Icons
