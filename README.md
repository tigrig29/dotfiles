# TigRig Dotfiles

このリポジトリは、TigRig の個人用設定ファイル（Dotfiles）を管理するものです。

PowerShell, Neovim, WezTerm, Starship などの設定が含まれています。

## PC 初期セットアップ時の手順

新しいPCのセットアップを行う際は、Gitやghqが未インストールの状態から「一発で」完了させるため、以下のワンライナーを使用します。

PowerShell を開き、以下のコマンドを実行してください。（途中 Scoop のインストール等で適宜権限が要求される場合があります）

```powershell
irm https://raw.githubusercontent.com/tigrig29/dotfiles/main/bootstrap.ps1 | iex
```

実行するとプロンプトが表示されるので、セットアップしたい環境（ブランチ）を選択します。
- **1 (main)**: デフォルトパス `D:\TigRig\repos\github.com\tigrig29\dotfiles` にクローンしてセットアップします。
- **2 (thinkings)**: デフォルトパス `C:\taigasato\repos\github.com\tigrig29\dotfiles` にクローンしてセットアップします。
- **3 (Custom)**: 任意のブランチ名とクローン先パスを指定できます。

スクリプトが自動的に Scoop と Git をインストールし、適切な場所にリポジトリをクローンした上で、メインのセットアップスクリプト (`setup-windows.ps1`) を呼び出して自動構築を行います。
