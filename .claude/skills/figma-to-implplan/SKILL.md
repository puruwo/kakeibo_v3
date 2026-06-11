---
name: figma-to-implplan
description: >
  Figmaデザインから Flutter 実装設計を作る作業で使う。figma-to-impl subagentが
  get_design_context でUI構造を取得して実装設計（影響範囲/新規・変更ファイル/使用トークン）を
  出力するとき、「Figmaから実装設計を作って」と指示されたときは必ずこのスキルに従うこと。
---

# Figma → Flutter実装設計

> **雛形（C-0時点）**: 詳細手順は C-1（既存Figma→実装の検証）着手時に詰める。
> 現時点では骨子のみを定義する。

## 手順（骨子）

1. **Figma取得**: Figma MCP の `get_design_context` で対象ノード（URL or ノードID）の
   UI構造・スタイルを取得する。必要に応じて `get_screenshot` で見た目を確認する
2. **既存パターン調査**: `lib/view/` の類似画面を探し、以下を把握する
   - ディレクトリ構成（page / area / component の分割）
   - 状態管理（`view_model/state/` のProvider・`updateDBCountNotifier` 監視）
   - 共通Widget（kakeibo-common-components スキル参照）
3. **色のトークン読み替え**: get_design_context が返す生hexを
   `design-tokens/tokens.json` から検索し、対応する `context.colors.<token>` を特定する
   - 対応規則: tokens は `#RRGGBBAA`、Flutter は `0xAARRGGBB`（kakeibo-design-tokens 参照）
   - 対応トークンが無い場合は**生hexを使わず**「未決」として報告する
4. **実装設計の出力**: 下記フォーマットで出力する。**実装はしない**

## 出力フォーマット（骨子）

```markdown
# 実装設計: <画面/機能名>
- 対象Figma: <URL / ノードID>
- 参照した類似画面: <lib/view/... のパス>

## 影響範囲
- <波及するファイル・Provider・UseCase>

## 新規/変更ファイル
| パス | 新規/変更 | 役割 |

## 使用トークン（色の読み替え表）
| Figmaの色(hex) | トークン | 用途 |

## 未決
- <トークン対応不明・既存パターンで表現できない要素>
```

## TODO（C-1着手時に詰める）

- [ ] get_design_context の出力からレイアウト値（余白/角丸/フォント）を抽出する具体手順
- [ ] AppTextStyles（constant/styles/）との対応の取り方
- [ ] 実例（既存1画面）でのサンプル設計
