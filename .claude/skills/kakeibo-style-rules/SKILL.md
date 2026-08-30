---
name: kakeibo-style-rules
description: >
  kakeibo の UI 実装ルール（色・文字・レイアウト）の入口。本文は持たず、
  色 → kakeibo-design-tokens Skill、文字 → Vault「Kakeibo テキストスタイルルール」、
  レイアウト（グロナビ余白）→ Vault「Kakeibo 共通コンポーネント利用ガイド」へ振り分ける。
  UI コンポーネントを実装・修正するときに起動し、該当する先を必ず読むこと。
---

# kakeibo スタイルルール（振り分けポインタ）

**このファイルは振り分けのみ。ルール本文は書かない**（2026-08-30 KP-007 で本文を Vault へ移植）。

| 対象 | 正本 |
|---|---|
| 色（トークン・`context.colors.*`・ハードコード禁止） | `.claude/skills/kakeibo-design-tokens/SKILL.md`（リポジトリ内） |
| 文字（`AppTextStyles` / `AppTypeScale` / `MyFontStyle` / ファミリー / ウェイト / `copyWith` の可否） | `/Users/puruwo/kakeibo_vault/06_design/Kakeibo テキストスタイルルール.md`（発火用 Skill: `~/.claude/skills/kakeibo-text-style-rules/`） |
| ボタン | `/Users/puruwo/kakeibo_vault/06_design/Kakeibo ボタンルール.md`（発火用 Skill: `~/.claude/skills/kakeibo-button-rules/`） |
| 共通コンポーネント・スクロール末尾の下部余白（グロナビ回避） | `/Users/puruwo/kakeibo_vault/06_design/Kakeibo 共通コンポーネント利用ガイド.md`（§3 注意点） |

## 手順

1. 該当する正本を **必ず Read してから** 実装に入る
2. 文字を触ったら `scripts/check_text_style.sh <file>`（警告のみ）を通す。色は `scripts/check_hardcoded_color.sh`
3. 規約に無い状況は、その場で独自実装せず Vault ページの「既知の逸脱と対応」に追記して報告する

## 定義ファイル

| 定義ファイル | クラス名 | 用途 |
|---|---|---|
| `design-tokens/tokens.json` | - | カラーの単一ソース（`kakeibo-design-tokens` Skill 参照） |
| `lib/theme/app_colors.dart` | `AppColors` / `AppColorsDark` | 生成されたカラートークン（手編集禁止） |
| `lib/constant/font_style.dart` | `MyFontStyle` | ベースフォント（`app_type_scale.dart` からのみ参照） |
| `lib/constant/styles/app_type_scale.dart` | `AppTypeScale` | 型スケール（family × size × weight の段。値の正本） |
| `lib/constant/styles/app_text_styles.dart` ほか | `AppTextStyles` / `RegisterPageStyles` / `CalendarStyles` / `GraphTextStyles` | 役割スタイル（段への参照＋色） |
