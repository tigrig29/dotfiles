---
name: sync-submodule-to-main
description: このdotfilesリポジトリで、thinkingsブランチ上でsubmodule(nvim等)に加えた汎用的な変更をmainブランチにも反映し、thinkingsブランチに再マージする。「mainにも反映したい」「mainとthinkingsの両方に適用したい」と言われたときに使う。
---

# submoduleの変更をmainブランチにも反映する

このリポジトリは `nvim` や `AutoHotkey` などをgit submoduleとして持ち、ルートリポジトリ・各submoduleの両方に `main`（汎用設定）と `thinkings`（会社固有の設定）のブランチがある。thinkings上で加えた変更のうち会社固有ではないものは、mainにも取り込んでからthinkingsへマージし直すことで、両ブランチの履歴を揃える。

## 前提

- ルートリポジトリと対象submoduleの両方に、ローカルの `main` ブランチと `thinkings` ブランチが存在すること。
- 対象submodule内で、thinkingsブランチ上に反映したい変更（コミット前でもよい）が存在すること。
- 変更は事前に洗い出しておく。submoduleの `main` へブランチを切り替えても、コミットされていない変更・未追跡ファイルはworking treeにそのまま残るので、切り替え後にコミットできる。

## 手順

以下、対象submoduleを `<submodule>` とする（例: `nvim`）。

1. **submoduleフォルダで `main` に切り替えてコミット**
   ```
   cd <submodule>
   git checkout main
   git add <変更したファイル>
   git commit -m "<変更内容>"
   ```

2. **ルートフォルダで `main` に切り替え、submodule参照の更新をコミット**
   ```
   cd ..
   git checkout main
   git add <submodule>
   git commit -m "update(<submodule>): サブモジュールを最新コミットに更新"
   ```

3. **submoduleフォルダで `thinkings` に戻り `main` をマージ**
   ```
   cd <submodule>
   git checkout thinkings
   git merge main
   ```

4. **ルートフォルダで `thinkings` に戻り `main` をマージ**
   ```
   cd ..
   git checkout thinkings
   git merge main
   ```
   このとき、ルートリポジトリ側でsubmoduleのgitlink参照が競合し、`<submodule>` が unmerged（both modified）として残ることがある。その場合は、手順3で作成済みの「thinkings上でmainをマージし終えたsubmoduleのコミット」を優先して採用する。具体的には `git checkout --ours`/`--theirs` は使わず、現在submoduleディレクトリが指しているコミット（手順3の結果）をそのまま採用すればよいので、内容を確認したうえで:
   ```
   git add <submodule>
   git commit
   ```

## 注意

- 各ステップのコミット後、リモートへの `push` は明示的に指示がない限り行わない。
- ルート側でコンフリクト解消のために `git add <submodule>` する前に、submoduleディレクトリが実際に手順3のマージ結果（thinkings + main の統合コミット）を指しているか確認すること。
