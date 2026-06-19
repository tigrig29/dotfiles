function Install-GUI-Apps {
    Write-Host "`n[6/7] Installing GUI apps via Winget..." -ForegroundColor Cyan

    $apps = @(
        # 基盤
        "Google.JapaneseIME",
        "Microsoft.PowerToys",
        # ブラウザ
        "Google.Chrome",
        "Brave.Brave",
        "Mozilla.Firefox",
        # 開発
        "JanDeDobbeleer.OhMyPosh",
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
        "SlackTechnologies.Slack",
        # エンタメ
        "Amazon.Kindle",
        "Valve.Steam"
    )

    $installedWingetApps = winget list --accept-source-agreements | Out-String

    foreach ($id in $apps) {
        # Check if the app ID exists in the pre-fetched list
        if ($installedWingetApps -match $id) {
            Write-Host "$id is already installed."
        }
        else {
            Write-Host "Installing $id..."
            winget install --id $id -e --source winget --accept-source-agreements --accept-package-agreements
        }
    }
}
