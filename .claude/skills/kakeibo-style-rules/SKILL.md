---
name: kakeibo-style-rules
description: >
  Kakeiboプロジェクトでのカラー参照・フォント定義の運用ルール。
  UIコンポーネントを実装・修正するときは必ずこのSkillに従うこと。
  カラーの詳細ルールは kakeibo-design-tokens Skill を正とする。
---

# カラー・フォント定義ルール

## カラー定義

**カラーの運用ルールは `kakeibo-design-tokens` Skill を正とする。**
色を扱う作業（トークン追加・UI実装・ハードコード色の置き換え等）では必ずそちらに従うこと。

要点のみ再掲：

- 色の単一ソースは `design-tokens/tokens.json`。ここ以外に色値を書かない
- アプリコードからは `context.colors.<token>` で参照する（`Colors.*` / `Color(0x...)` の直書き禁止）
- `lib/theme/app_colors.dart` は生成物（`tool/generate_tokens.dart` で生成）。手で編集しない
- 旧 `MyColors` は廃止済み。見つけたら対応する `context.colors.*` へ置き換える
- `const TextStyle` や `CustomPainter` など context が使えない場所の例外パターンも
  `kakeibo-design-tokens` Skill に定義がある

---

## フォント定義

### 基本ルール

フォントスタイルはすべて `lib/constant/styles/app_text_styles.dart` の `AppTextStyles` クラスから参照すること。

```dart
// ✅ 正しい
style: AppTextStyles.pageHeaderText
style: AppTextStyles.listTilePrimaryTitle
style: AppTextStyles.appCardPriceLabel

// ❌ 禁止
style: TextStyle(fontSize: 14, color: Colors.white, ...)
style: MyFontStyle.notoSans.copyWith(...)  // 使用箇所に直接書くのは禁止
```

### 既存定義の選定基準

| 用途 | 使うスタイル |
|---|---|
| ページAppBarのタイトル | `pageHeaderText` (text, 18, w500) |
| ページAppBarのサブテキスト | `pageHeaderSubText` (textSecondary, 11, w400) |
| セクションヘッダー（カード上部） | `appCardSectionTitle` (text, 16, w600) |
| リストタイルのメインラベル | `listTilePrimaryTitle` (text, 14, w500) |
| リストタイルのサブラベル | `listTileSecondaryTitle` (textSecondary, 13, w400) |
| カード内の金額 | `appCardPriceLabel` (text, 20, w600) |
| ボタンのテキスト | `mainButtonText` (text, 14, w600) |
| ダイアログタイトル | `dialogTitle` (text, 18, w500) |

### 新しいスタイルが必要な場合

既存定義に適切なものがなければ、**使用箇所に直接書かず**、`app_text_styles.dart` に定義してから参照する。

```dart
// app_text_styles.dart に追加
/// ピッカーの選択中テキスト用スタイル
static final TextStyle pickerSelectedLabel = MyFontStyle.notoSans.copyWith(
  fontSize: 16,
  color: AppColorsDark.text,
  fontWeight: FontWeight.w600,
);

// 使用箇所
style: AppTextStyles.pickerSelectedLabel
```

定義時のフォーマット：
- 1行のdocコメント（用途を日本語で記述）
- `MyFontStyle.notoSans` か `MyFontStyle.sfUi` を使う（数値系は sfUi、日本語文字列は notoSans）
- カラーは `AppColorsDark`（static 逃げ道クラス・ダーク値）から参照する
  - static 定義内では context が使えないためのやむを得ない例外（`kakeibo-design-tokens` Skill の対応B）
  - 使用箇所で色をモード追従させたい場合は `.copyWith(color: context.colors.<token>)` を当てる（対応A）

---

## ファイルパス

| 定義ファイル | クラス名 | 用途 |
|---|---|---|
| `design-tokens/tokens.json` | - | カラーの単一ソース（`kakeibo-design-tokens` Skill 参照） |
| `lib/theme/app_colors.dart` | `AppColors` / `AppColorsDark` | 生成されたカラートークン（手編集禁止） |
| `lib/constant/styles/app_text_styles.dart` | `AppTextStyles` | フォントスタイル |
| `lib/constant/font_style.dart` | `MyFontStyle` | ベースフォント（直接使用禁止） |
