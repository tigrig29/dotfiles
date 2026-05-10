param (
    [Parameter(Mandatory=$true)]
    [int]$prNumber,
    [Parameter(Mandatory=$true)]
    [string]$title,
    [Parameter(Mandatory=$true)]
    [string]$body
)

$tempFile = "temp_pr_body_$(Get-Random).txt"

try {
    # UTF-8 で一時ファイルに書き出す (文字化け回避)
    Set-Content -Path $tempFile -Value $body -Encoding utf8
    
    # gh pr edit を実行
    gh pr edit $prNumber --title $title --body-file $tempFile
    
    Write-Host "✅ PR #$prNumber updated successfully."
}
catch {
    Write-Error "❌ Failed to update PR #${prNumber}: $_"
}
finally {
    # 一時ファイルを削除
    if (Test-Path $tempFile) {
        Remove-Item $tempFile
    }
}
