---
name: kakeibo-common-components
description: >
  kakeibo で共通UIコンポーネント（カード・タイル・ピル・インセットグループ・チップ・
  空状態・ピッカーなど）を使う／新設するときに必ず起動する。
  本文は Vault の「Kakeibo 共通コンポーネント利用ガイド」が正本で、この Skill はそこへ誘導するだけ。
  Container に BoxDecoration（色・角丸・border・shape）を直接書こうとしたときが対象。
---

# kakeibo 共通UIコンポーネント（ポインタ）

**このファイルはポインタのみ。本文は書かない。正本:**

```
/Users/puruwo/kakeibo_vault/06_design/Kakeibo 共通コンポーネント利用ガイド.md
```

## 手順

1. 上記ページを **必ず Read してから** 実装に入る（§1 一覧 → §2 使い分け → §3 注意点 → §4 実装ルール）
2. 押すとアクションが起きる要素は `kakeibo-button-rules` Skill（`~/.claude/skills/`）へ
3. 共通 widget を新設・変更したら、同ページ §1 と Vault「Kakeibo デザインシステム」の共通コンポーネント表を更新する（ingest の一部として行う）

## 関連 Skill

- 色: `kakeibo-design-tokens`（リポジトリ内が正）
- 期間・ピッカー: `kakeibo-period-patterns`
