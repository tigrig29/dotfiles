---
name: github-issue-creator
description: GitHub の Issue を作成・登録するスキルです。プロジェクトのIssueテンプレート（存在する場合）を利用し、バグ報告や機能要望、タスクなどを自動的に構築します。Windows環境での文字化けを防ぐため、ファイル経由での作成を徹底します。
---

# GitHub Issue Creator

## 概要

このスキルは、GitHub CLI (`gh`) を使用して、一貫性のあるわかりやすい GitHub Issue を作成するためのガイドラインを提供します。特に Windows (win32/PowerShell) 環境における文字化けや変数展開の課題を解決するためのベストプラクティスを網羅しています。

## ワークフロー

### 1. コンテキストの収集

Issue を作成する前に、以下の情報を特定します。

- **Issueの種類**: バグ報告 (Bug)、機能要望 (Feature Request)、タスク (Task) など。
- **タイトル**: 簡潔で内容が伝わるタイトル。
- **本文**: 問題の詳細、再現手順、期待される動作、関連するソースコードやエラーログなど。
- **ラベルやアサイン**: (オプション) 付与すべきラベル(`bug`, `enhancement`など)や担当者。
- **テンプレート**: リポジトリに `.github/ISSUE_TEMPLATE/` や `.github/issue_template.md` などのテンプレートが存在する場合は、それをベースにする。

### 2. Issue の作成

新しい Issue を作成する場合の標準的な手順です。

1. テンプレートが存在する場合は内容を読み込む。
2. 収集したコンテキストを反映してIssueの本文を構成する。
3. `gh issue create` コマンドを実行する。
   - **注意**: 日本語が含まれる場合や本文が複数行にわたる場合は、後述の「文字化け対策」を適用すること。

## 文字化け対策 (Windows/PowerShell)

Windows 環境で日本語を含む Issue を作成する際は、コマンドライン引数として直接文字列を渡すと文字化けが発生する可能性があるため、**必ず一時ファイルを経由**して `--body-file` オプションを使用してください。

### 推奨コマンドパターン

```powershell
$issueBody = @'
## 概要
ここにIssueの概要を記述します。

## 詳細
- 詳細1
- 詳細2
'@;

# UTF-8 で一時ファイルに書き込む
Set-Content -Path "issue_body.txt" -Value $issueBody -Encoding utf8;

# Issue を作成する
gh issue create --title "Issueのタイトル" --body-file issue_body.txt;

# 一時ファイルを削除する
Remove-Item "issue_body.txt"
```

※ ラベルやアサインを追加する場合は、コマンドに `--label "bug,help wanted"` や `--assignee "@me"` などのオプションを追加します。
