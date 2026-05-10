---
name: github-pr-creator
description: GitHub のプルリクエスト (PR) を作成・編集するスキルです。プロジェクトの PR テンプレートを元に、最新のコミット、PBI、設計書などのコンテキストを反映した高品質な PR を自動的に構築します。Windows 環境での文字化けを回避するため、ファイル経由での更新を徹底します。
---

# GitHub PR Creator / Manager

## 概要

このスキルは、GitHub CLI (`gh`) を使用して、プロジェクト標準のプルリクエストテンプレートに基づいた一貫性のある PR を作成・編集するためのガイドラインを提供します。特に Windows (win32) 環境における文字化けや変数展開の課題を解決するためのベストプラクティスを網羅しています。

## ワークフロー

### 1. コンテキストの収集

PR を作成または編集する前に、以下の情報を特定します。

- **PR 番号**: 既存の PR を編集する場合 (`gh pr view --json number`)。
- **PBI 番号とタイトル**: `docs/product-backlog/` から特定。
- **最新の変更内容**: `git log -n 1` および `git diff` で最新のコミット内容を把握。
- **関連ドキュメント**: 仕様書・設計書・テスト仕様書への相対パス。
- **検証結果**: `dotnet test` の最新の結果。

### 2. PR の作成 (New PR)

新しい PR を作成する場合の標準的な手順です。

1. `.github/pull_request_template.md` を読み込む。
2. PBI や変更内容をテンプレートに埋め込む。
3. `gh pr create --title "[Title]" --body "[Body]"` を実行。
   - **注意**: 日本語が含まれる場合は、後述の「文字化け対策」を適用すること。

### 3. PR の編集 (Update PR)

既存の PR に最新の変更内容（直近のコミットなど）を反映させる場合の手順です。

1. 現在の PR 本文を取得: `gh pr view <number> --json body`
2. 最新のコミット差分を元に、本文の「修正内容」や「概要」を更新。
3. `gh pr edit <number> --title "[New Title]" --body "[New Body]"` を実行。

## 文字化け対策 (Windows/PowerShell)

Windows 環境で日本語を含む PR を作成・編集する際は、直接文字列を引数に渡すと文字化けが発生するため、**必ず一時ファイルを経由**してください。

具体的な手順については、[references/pr-templates.md](references/pr-templates.md) を参照してください。

### 推奨コマンドパターン
```powershell
$prBody = @"
...（日本語の本文）...
"@;
Set-Content -Path "pr_body.txt" -Value $prBody -Encoding utf8;
gh pr edit <number> --body-file pr_body.txt;
Remove-Item "pr_body.txt"
```

## リソース

- [references/pr-templates.md](references/pr-templates.md): 具体的な埋め込みパターンと PowerShell での回避策。
- [scripts/update_pr.ps1](scripts/update_pr.ps1): 安全に PR を更新するためのユーティリティ。
