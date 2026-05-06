# PR Templates and Patterns

このリファレンスは、GitHub PR Creator が PR を作成・編集する際の具体的なパターンと、Windows 環境（PowerShell）における注意点をまとめたものです。

## 1. PR 作成 (gh pr create)

PR を作成する際は、タイトルと本文を動的に生成し、ファイル経由で渡すことで文字化けを回避します。

### ワークフロー
1. `.github/pull_request_template.md` を読み込む。
2. PBI 番号、タイトル、変更内容などを埋める。
3. 一時ファイル `pr_body.txt` に UTF-8 で保存する。
4. `gh pr create --title "[Title]" --body-file pr_body.txt` を実行する。
5. 一時ファイルを削除する。

## 2. PR 編集 (gh pr edit)

既存の PR を更新する際、特に「直近のコミット内容を追加する」場合に有効なパターンです。

### 文字化け回避パターン (Windows/PowerShell)
直接文字列を引数に渡すと、日本語が文字化けしたり、変数が展開されなかったりすることがあります。以下のパターンを推奨します。

```powershell
$prBody = @"
# Title: [PBI-XXX] タイトル

## 概要
...（日本語の本文）...
"@;
# UTF-8 で一時ファイルに書き出す
Set-Content -Path "pr_body_edit.txt" -Value $prBody -Encoding utf8;
# ファイル経由で編集
gh pr edit <number> --title "[New Title]" --body-file pr_body_edit.txt;
# 一時ファイルを削除
Remove-Item "pr_body_edit.txt"
```

## 3. コンテキスト収集のヒント

PR の内容を充実させるために、以下のコマンドを組み合わせて使用します。

### 直近のコミット内容の把握
```powershell
git log -n 1 --pretty=format:"%B" ; git diff HEAD^ HEAD
```

### 現在の PR 状態の確認
```powershell
gh pr view --json number,title,body
```
