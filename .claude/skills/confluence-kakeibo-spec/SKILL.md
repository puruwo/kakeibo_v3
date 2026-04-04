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

## 注意事項

- Confluenceに書く内容はCLAUDE.mdと重複しないようにする
- CLAUDE.mdはコード開発ガイド、Confluenceはユーザー向け・チーム向けの仕様書として使い分ける
- ページを新規作成した場合、このSkillのページ一覧セクションを更新する
