function Setup-AutoHotkey {
    Write-Host "Setting up AutoHotkey..." -ForegroundColor Cyan

    # dotfiles直下のAutoHotkeyディレクトリのパスを取得
    $ahkPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\AutoHotkey\AutoHotkey.exe"))

    if (-not (Test-Path $ahkPath)) {
        Write-Warning "AutoHotkey.exe が見つかりません: $ahkPath"
        Write-Warning "サブモジュールが初期化されていない場合は、'git submodule update --init' を実行してください。"
        return
    }

    $taskName = "AutoHotkey"
    
    # 実行アクション
    $action = New-ScheduledTaskAction -Execute $ahkPath
    
    # ログオン時トリガー
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    
    # 最上位の特権で実行する設定 (UACプロンプト回避用)
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest -LogonType Interactive
    
    # 設定 (バッテリー駆動時も開始、期限なし)
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0

    try {
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        Write-Host "AutoHotkey をタスクスケジューラに登録しました (ログオン時起動)." -ForegroundColor Green
    }
    catch {
        Write-Warning "タスクの登録に失敗しました。管理者権限で実行しているか確認してください。"
        Write-Warning $_.Exception.Message
    }
}
