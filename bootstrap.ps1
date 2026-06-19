# Windows用 Dotfiles ブートストラップスクリプト

$ErrorActionPreference = "Stop"

Write-Host "dotfiles のブートストラップ処理を開始します..." -ForegroundColor Cyan

# 1. Scoop が未インストールの場合はインストール
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop がインストールされていません。Scoop をインストールします..." -ForegroundColor Yellow
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# 2. Git が未インストールの場合は Scoop 経由でインストール
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git がインストールされていません。Scoop 経由でインストールします..." -ForegroundColor Yellow
    
    # 現在のセッションの $env:Path に scoop の shim パスを追加
    $scoopShimPath = "$HOME\scoop\shims"
    if ($env:Path -notmatch [regex]::Escape($scoopShimPath)) {
        $env:Path = "$scoopShimPath;" + $env:Path
    }

    scoop install git
    
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git のインストールに失敗しました。ターミナルを再起動してやり直してください。" -ForegroundColor Red
        exit 1
    }
}

# 3. 環境・ブランチの選択
Write-Host "`n--- 環境の選択 ---" -ForegroundColor Cyan
Write-Host "1) main      (デフォルト ghq.root: D:\TigRig\repos)"
Write-Host "2) thinkings (デフォルト ghq.root: C:\taigasato\repos)"
Write-Host "3) カスタム"
$choice = Read-Host "セットアップする環境を選択してください [1-3] (デフォルト: 1)"

$branch = "main"
$defaultGhqRoot = "D:\TigRig\repos"

switch ($choice) {
    "2" {
        $branch = "thinkings"
        $defaultGhqRoot = "C:\taigasato\repos"
    }
    "3" {
        $branch = Read-Host "ブランチ名を入力してください (デフォルト: main)"
        if ([string]::IsNullOrWhiteSpace($branch)) { $branch = "main" }
        $defaultGhqRoot = "C:\taigasato\repos"
    }
    default {
        $branch = "main"
        $defaultGhqRoot = "D:\TigRig\repos"
    }
}

# 4. ghq.root パスの指定
$ghqRoot = Read-Host "ghq.root のパスを入力してください (デフォルト: $defaultGhqRoot)"
if ([string]::IsNullOrWhiteSpace($ghqRoot)) {
    $ghqRoot = $defaultGhqRoot
}

# リポジトリパスの定義
$repoName = "tigrig29/dotfiles"
$repoPath = "$ghqRoot\github.com\$repoName"

# 5. リポジトリのクローン
if (-not (Test-Path $repoPath)) {
    Write-Host "`nリポジトリ ($branch ブランチ) を $repoPath にクローンしています..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$ghqRoot\github.com" | Out-Null
    Set-Location "$ghqRoot\github.com"
    git clone -b $branch "https://github.com/${repoName}.git"
} else {
    Write-Host "`nリポジトリはすでに $repoPath に存在します。最新の変更をプルします..." -ForegroundColor Yellow
    Set-Location $repoPath
    git pull
    git switch $branch
}

# 6. メインのセットアップスクリプトを実行
if (Test-Path "$repoPath\setup-windows.ps1") {
    Write-Host "`nsetup-windows.ps1 を開始します..." -ForegroundColor Green
    Set-Location $repoPath
    .\setup-windows.ps1
} else {
    Write-Host "$repoPath に setup-windows.ps1 が見つかりませんでした。" -ForegroundColor Red
    exit 1
}
