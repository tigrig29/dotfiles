---
name: git-commit
description: 'Conventional Commits メッセージの解析、インテリジェントなステージング、メッセージの生成を伴う git commit を実行します。ユーザーが変更のコミットや git commit の作成を求めた場合、または "/commit" と言及した場合に使用します。サポート機能: (1) 変更からのタイプとスコープの自動検出、(2) 差分からの Conventional Commits メッセージの生成、(3) タイプ/スコープ/説明のオーバーライド（オプション）によるインタラクティブなコミット、(4) 論理的なグループ化のためのインテリジェントなファイルステージング'
license: MIT
allowed-tools: Bash
---

# Conventional Commits による Git Commit

## 概要

Conventional Commits 仕様を使用して、標準化されたセマンティックな git コミットを作成します。実際の差分を分析して、適切なタイプ、スコープ、およびメッセージを決定します。

## Conventional Commit フォーマット

```
<type>(optional scope): <description>

[optional body]

[optional footer(s)]
```

## コミットタイプ

| タイプ     | 目的                           |
| ---------- | ------------------------------ |
| `feat`     | 新機能                         |
| `fix`      | バグ修正                       |
| `docs`     | ドキュメントのみの変更         |
| `style`    | フォーマット/スタイル（ロジック変更なし） |
| `refactor` | コードのリファクタリング（機能追加/バグ修正なし） |
| `perf`     | パフォーマンス改善             |
| `test`     | テストの追加/更新               |
| `build`    | ビルドシステム/依存関係の変更   |
| `ci`       | CI/設定の変更                   |
| `chore`    | メンテナンス/その他             |
| `revert`   | コミットの取り消し (revert)    |

## 破壊的変更 (Breaking Changes)

```
# タイプ/スコープの後の感嘆符 (!)
feat!: 非推奨のエンドポイントを削除

# BREAKING CHANGE フッター
feat: 設定が他の設定を継承できるようにする

BREAKING CHANGE: `extends` キーの動作が変更されました
```

## ワークフロー

### 1. 差分の分析

```bash
# ファイルがステージングされている場合は、ステージングされた差分を使用
git diff --staged

# ステージングされていない場合は、作業ツリーの差分を使用
git diff

# ステータスも確認
git status --porcelain
```

### 2. ファイルのステージング (必要な場合)

何もステージングされていない場合、または変更を別の方法でグループ化したい場合:

```bash
# 特定のファイルをステージング
git add path/to/file1 path/to/file2

# パターンによるステージング
git add *.test.*
git add src/components/*

# インタラクティブなステージング
git add -p
```

**シークレット情報（.env, credentials.json, 秘密鍵など）は絶対にコミットしないでください。**

### 3. コミットメッセージの生成

差分を分析して以下を決定します:

- **タイプ**: どのような種類の変更か？
- **スコープ**: 影響を受けるエリア/モジュールは何か？
- **説明**: 変更内容の1行での要約 (現在形、命令法、72文字未満。日本語で記述する場合は簡潔にまとめる)

### 4. コミットの実行

**注意**: Windows (PowerShell) 環境で日本語のコミットメッセージを作成する際は、文字化けを防止するため、直接 `git commit -m` に引数として渡すのではなく、メッセージを一時ファイルに `-Encoding utf8` で書き込んでから `git commit -F` を使用してください。

```powershell
# メッセージを一時ファイルに書き込む
@"
<type>(scope): <description>

<optional body>

<optional footer>
"@ | Out-File -FilePath .\.git\COMMIT_EDITMSG_TEMP -Encoding utf8

# ファイルを指定してコミット
git commit -F .\.git\COMMIT_EDITMSG_TEMP

# 一時ファイルを削除
Remove-Item .\.git\COMMIT_EDITMSG_TEMP
```

## ベストプラクティス

- 1つのコミットにつき1つの論理的な変更を含める
- コミットメッセージは日本語で記述し、1行目は簡潔にまとめ、詳細が必要な場合は3行目以降に記述する
- イシューの参照: `Closes #123`, `Refs #456`
- 説明は72文字未満に抑える

## Git 安全プロトコル

- git config は **絶対に** 更新しないでください
- ユーザーからの明示的な要求がない限り、破壊的なコマンド (`--force`, hard reset など) は **絶対に** 実行しないでください
- ユーザーからの要求がない限り、フック (`--no-verify`) は **絶対に** スキップしないでください
- main/master ブランチへの強制プッシュ (`force push`) は **絶対に** 行わないでください
- フックが原因でコミットが失敗した場合は、問題を修正して **新しい** コミットを作成してください (`amend` は使用しない)
- AIエージェントによる自動的なマージ (`git merge`) は禁止されています。マージの実行には必ずユーザーの明示的な承認を求めてください
