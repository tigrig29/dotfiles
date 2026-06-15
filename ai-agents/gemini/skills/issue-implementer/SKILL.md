---
name: issue-implementer
description: Issueに対する実装を指示された際に、専用のgit worktreeを作成して実装作業を行い、完了後に変更内容と動作確認手順を記載したPRを作成するスキルです。
---

# Issue Implementer

## 概要

このスキルは、GitHubのIssueに対して実装を行う際の一連のワークフロー（作業用Worktreeの作成、実装作業、コミット・プッシュ、PRの作成）を標準化するためのガイドラインです。他のスキル（`git-commit` や `github-pr-creator`）と連携して、安全かつ確実にタスクを完了させることを目的としています。

## ワークフロー

### 1. Issueの把握
実装対象のIssue番号（例：`#12`）が指定されたら、対象のIssueの内容を確認し、実装の要件とスコープを把握します。
- `gh issue view <Issue番号>` コマンド等を使用して内容を取得します。

### 2. Worktreeの作成
現在のリポジトリから、実装作業用のブランチと紐づく **git worktree** を作成します。
これによって、既存の作業状態を汚染することなく新しいタスクに集中できます。

**推奨コマンドパターン:**
```powershell
# 作業ディレクトリはリポジトリのルートに移動しておくこと
$issueNumber = "12"
$branchName = "feature/issue-$issueNumber"

# 推奨: .worktrees などの専用ディレクトリ配下に作成する
$worktreePath = ".worktrees/issue-$issueNumber"

git worktree add $worktreePath -b $branchName
```
※ `git worktree` で作成されたディレクトリは `.gitignore` に追加する（例: `.worktrees/`）などして、親リポジトリの差分として検出されないように配慮してください。
※ 作成後は、エージェントの作業ディレクトリ (CWD) を作成した `$worktreePath` に変更して作業を進めてください。

### 3. 実装作業とテスト
作成した worktree 内でコードの修正・追加を行います。
- 要件に基づいて実装を進めます。
- 必要に応じてビルドやテスト（例：`npm test`, `dotnet test` など環境に応じたコマンド）を実行し、動作確認を行います。

### 4. コミットとプッシュ
実装と動作確認が完了したら、変更をコミットしてリモートへプッシュします。
- コミットには `git-commit` スキルを活用し、Conventional Commitsに従った適切なメッセージを（日本語で）作成してください。
- ユーザー指示のルールに従い、Windows環境の文字化け防止のため、コミットメッセージは必ず一時ファイル（UTF-8）を経由して `git commit -F` を使用すること。

```powershell
git push -u origin $branchName
```

### 5. プルリクエスト (PR) の作成
リモートブランチへプッシュ後、`github-pr-creator` スキルを活用してPRを作成します。

**PR本文の必須項目:**
1. **関連Issue**: 必ず `Resolves #{Issue番号}` などのキーワードを含めてIssueを紐づけ、PRマージ時にIssueが自動クローズされるようにすること。
2. **変更内容**: どのような修正や機能追加を行ったか。
3. **動作確認手順**: ユーザーやレビュアーが、実装内容をどのように検証・テストすればよいかの具体的な手順。

**PR作成時の文字化け対策（必須）:**
Windows (PowerShell) 環境での文字化けを防ぐため、以下のように一時ファイルを経由して `gh pr create` を実行してください。

```powershell
$prBody = @"
## 関連Issue
Resolves #12

## 変更内容
- ここに変更内容を具体的に記述します。
- ...

## 動作確認手順
1. アプリケーションを起動する（\`npm run dev\` など）。
2. 動作確認すべき画面やAPIへアクセスする。
3. ...
"@;

Set-Content -Path "pr_body.txt" -Value $prBody -Encoding utf8;
gh pr create --title "feature: Issue #12 の実装" --body-file pr_body.txt --base main;
Remove-Item "pr_body.txt"
```

## 注意事項
- 必ずユーザーの指示に従い、PR作成前に必要な要件がすべて満たされているか確認すること。
- 自動的なマージ（`git merge`）は禁止されています。マージは行わず、PRを作成してユーザーの承認を待つ状態に留めてください。
- 作業完了後、不要になった worktree のクリーンアップを行うかユーザーに判断を仰いでください (`git worktree remove`)。
