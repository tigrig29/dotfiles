function Install-GUI-Apps {
    Write-Host "`n[6/7] Installing GUI apps via Winget..." -ForegroundColor Cyan

    $apps = @(
        # 基盤
        "Google.JapaneseIME",
        "Microsoft.PowerToys",
        # ブラウザ
        "Google.Chrome",
        # "Brave.Brave",
        # "Mozilla.Firefox",
        # 開発
        "wez.wezterm",
        "gerardog.gsudo",
        "Microsoft.VisualStudioCode",
        "Google.Antigravity",
        # "Unity.UnityHub",
        "Figma.Figma",
        # ノート
        "Notion.Notion",
        "Obsidian.Obsidian",
        # 連絡
        # "Discord.Discord",
        # "Mozilla.Thunderbird",
        "SlackTechnologies.Slack"
        # エンタメ
        # "Amazon.Kindle",
        # "Valve.Steam"
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
