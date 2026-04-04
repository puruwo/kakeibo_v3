---
name: confluence-kakeibo-spec
description: >
  kakeiboアプリの仕様をConfluenceにまとめるときのルール。
  Confluenceに仕様を書く・読む・更新するときは必ずこのSkillに従うこと。
---

# Confluence 家計簿アプリ仕様ページ

## 仕様ページの場所

| 項目 | 値 |
|---|---|
| **ページタイトル** | 家計簿アプリ |
| **ページID** | `1703937` |
| **スペースキー** | `~7120203d5ce4b46b164aff93f7bf82f1a3cf44` |
| **URL** | https://tomatokey.atlassian.net/wiki/spaces/~7120203d5ce4b46b164aff93f7bf82f1a3cf44/pages/1703937 |
| **cloudId** | `tomatokey.atlassian.net` |

---

## ページの読み取り

`mcp__claude_ai_Atlassian_Rovo__getConfluencePage` を使う。

```
cloudId: tomatokey.atlassian.net
pageId: 1703937
contentFormat: markdown
```

---

## 子ページの作成

仕様の各セクションを子ページとして作成する場合は `mcp__claude_ai_Atlassian_Rovo__createConfluencePage` を使い、
`parentId: 1703937` を指定する。

```
cloudId: tomatokey.atlassian.net
parentId: 1703937
spaceKey: ~7120203d5ce4b46b164aff93f7bf82f1a3cf44
```

---

## ページの更新

`mcp__claude_ai_Atlassian_Rovo__updateConfluencePage` を使う。

```
cloudId: tomatokey.atlassian.net
pageId: 1703937（または対象の子ページID）
```

---

## 子ページ一覧の取得

`mcp__claude_ai_Atlassian_Rovo__getConfluencePageDescendants` を使う。

```
cloudId: tomatokey.atlassian.net
pageId: 1703937
```

---

## 仕様書の文章スタイル

Confluenceの仕様書はチーム・ユーザー向けのドキュメントであり、コード読解の補助資料ではない。以下のルールを守ること。

### 禁止事項
- プログラムの変数名・型名・Enumの値名を文章中で使わない
  - ❌ `hasIncome == true` → ✅ 「収入が記録されている場合」
  - ❌ `graphType == hasBudgetButOver` → ✅ 「予算が設定されており、支出が予算を超えている場合」
  - ❌ `realSavings != 0` → ✅ 「収入と支出の合計に差額がある場合」
- 実装関数名・クラス名・プロバイダ名を説明の主語にしない
  - ❌ `MonthlyCategoryCardUsecaseNotifier.fetch() で GraphType を決定する`
  - ✅ 「各カテゴリーの予算・支出状況に応じて、棒グラフの表示パターンを決定する」
- 条件式（`==`, `!=`, `>`, `||` など）を文章中に直接書かない

### 推奨表現
- 「〇〇が設定されている場合」「〇〇がある場合」のような自然な日本語
- 「表示される」「非表示になる」「グレーで表示される」など視覚的な結果で説明
- 実装ファイルパスは参考情報として末尾や脚注に記載する程度にとどめる
- テーブルの条件列も日本語で書く（「予算あり・支出が予算内」など）

### コードブロックの使用
- ファイルパスの列挙など、コードブロックが本当に適切な場合のみ使用する
- 条件分岐の説明にコードブロックを使わない

---

## 仕様書画像利用ルール
仕様説明に必要な画像はFigmaから取得し、静的な画像をConfluenceにアップロードして利用する。
その際、Figmaの画像取得元のURLを併記すること


## 注意事項

- Confluenceに書く内容はCLAUDE.mdと重複しないようにする
- CLAUDE.mdはコード開発ガイド、Confluenceはユーザー向け・チーム向けの仕様書として使い分ける
- ページを新規作成した場合、このSkillのページ一覧セクションを更新する
