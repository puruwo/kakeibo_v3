---
name: kakeibo-style-rules
description: >
  Kakeiboプロジェクトでのカラー定義・フォント定義の運用ルール。
  UIコンポーネントを実装・修正するときは必ずこのSkillに従うこと。
---

# カラー・フォント定義ルール

## カラー定義

### 基本ルール

カラーはすべて `lib/constant/colors.dart` の `MyColors` クラスから参照すること。

```dart
// ✅ 正しい
color: MyColors.white
color: MyColors.themeColor
color: MyColors.secondaryLabel

// ❌ 禁止
color: Colors.white
color: Colors.black
color: Color(0xFFFFFFFF)  // MyColorsに同等の定義があれば禁止
```

### 新しい色が必要な場合

`MyColors` に未定義の色が必要な場合は、**使用箇所に直接書かず**、必ず `colors.dart` に定義してから参照する。

```dart
// colors.dart に追加
static const overlayDark = Color(0xBF000000);  // alpha: 0.75 相当

// 使用箇所
color: MyColors.overlayDark
```

### 透明度バリアント

`.withValues(alpha: x)` や `.withOpacity(x)` で動的に透明度を変える場合：
- ベースカラーは `MyColors` から取得する
- 同じ透明度を複数箇所で使う場合は `MyColors` に定数化する

```dart
// 1箇所だけで使う場合（許容）
color: MyColors.black.withValues(alpha: 0.75)

// 複数箇所で使う場合 → MyColorsに定数化する
static const backdropColor = Color(0xBF000000);  // Colors.dart に追加
```

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
| ページAppBarのタイトル | `pageHeaderText` (white, 18, w500) |
| ページAppBarのサブテキスト | `pageHeaderSubText` (secondaryLabel, 11, w400) |
| セクションヘッダー（カード上部） | `appCardSectionTitle` (label, 16, w600) |
| リストタイルのメインラベル | `listTilePrimaryTitle` (label, 14, w500) |
| リストタイルのサブラベル | `listTileSecondaryTitle` (secondaryLabel, 13, w400) |
| カード内の金額 | `appCardPriceLabel` (white, 20, w600) |
| ボタンのテキスト | `mainButtonText` (label, 14, w600) |
| ダイアログタイトル | `dialogTitle` (white, 18, w500) |

### 新しいスタイルが必要な場合

既存定義に適切なものがなければ、**使用箇所に直接書かず**、`app_text_styles.dart` に定義してから参照する。

```dart
// app_text_styles.dart に追加
/// ピッカーの選択中テキスト用スタイル
static final TextStyle pickerSelectedLabel = MyFontStyle.notoSans.copyWith(
  fontSize: 16,
  color: MyColors.label,
  fontWeight: FontWeight.w600,
);

// 使用箇所
style: AppTextStyles.pickerSelectedLabel
```

定義時のフォーマット：
- 1行のdocコメント（用途を日本語で記述）
- `MyFontStyle.notoSans` か `MyFontStyle.sfUi` を使う（数値系は sfUi、日本語文字列は notoSans）
- カラーは `MyColors` から参照

---

## ファイルパス

| 定義ファイル | クラス名 | 用途 |
|---|---|---|
| `lib/constant/colors.dart` | `MyColors` | カラー定数 |
| `lib/constant/styles/app_text_styles.dart` | `AppTextStyles` | フォントスタイル |
| `lib/constant/font_style.dart` | `MyFontStyle` | ベースフォント（直接使用禁止） |
