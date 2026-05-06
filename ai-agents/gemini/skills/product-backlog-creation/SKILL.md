---
name: product-backlog-creation
description: PRDからプロダクトバックログ（PBI）を作成するスキル。
---

# プロダクトバックログ作成

PRD（`docs/prd.md`）を分析し、以下の制約を厳守してPBIを作成してください。

## 制約

1. **言語**: すべて日本語で記述すること。
2. **ユーザーストーリー**: 「[ユーザー]として、[アクション]をしたい。なぜなら[目的]だからだ」の形式を徹底。
3. **垂直分割**: 技術単位（UI、DB等）ではなく、ユーザー価値が完結する単位（バーティカルスライス）で分割。
4. **ファイル構成**:
   - `docs/product-backlog/` 内に個別ファイルを作成（`assets/pbi-template.md` 使用）。
   - `index.md` で全PBIを優先度順に一覧化。
5. **受入条件**: BDD形式（前提・操作・結果 / Given-When-Then）で記述。

## テンプレート

./assets/pbi-template.md を使用して、各PBIを作成してください。
