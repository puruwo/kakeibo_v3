# Kakeibo v3 Design

家計簿アプリ Kakeibo v3 のUIデザインリファレンス。
カラー、タイポグラフィ、共通コンポーネント、画面構成のすべてを 1 ファイルで把握できることを目的とする。

- **対象アプリバージョン**: 1.1.2
- **Flutter version**: 3.16.9
- **テーマ**: ダーク固定（iOS HIG ライク）
- **配置**: `design.md`（リポジトリ直下）

---

## 目次

- [0. Overview](#0-overview)
- [1. Design Principles](#1-design-principles)
- [2. Color System](#2-color-system)
  - 2.1 Brand / Theme
  - 2.2 iOS System Background
  - 2.3 System Gray Scale
  - 2.4 Label Hierarchy
  - 2.5 System Fill
  - 2.6 Category Color - Expense
  - 2.7 Category Color - Income
  - 2.8 Category Color - Fixed Cost
  - 2.9 Accent / Utility
  - 2.10 Helpers
- [3. Typography](#3-typography) — Vault「Kakeibo テキストスタイルルール」へ移植済み
- [4. Theme & Global Style](#4-theme--global-style)
- [5. Common UI Components](#5-common-ui-components)
  - 5.1 Card 系
  - 5.2 List 系
  - 5.3 Icon 系
  - 5.4 Header 系
  - 5.5 Button 系
  - 5.6 Dialog 系
  - 5.7 Modal 系
  - 5.8 Interaction 系
  - 5.9 Feedback 系
  - 5.10 その他
- [6. Layout & Navigation](#6-layout--navigation)
- [7. Screen Inventory](#7-screen-inventory)
- [8. Standard Values（早見表）](#8-standard-values早見表)
- [9. Reference Files](#9-reference-files)

---

## 0. Overview

Kakeibo v3 は Flutter 製の日本語家計簿アプリ。デザインは「**ダーク前提 / iOS HIG ライクの色階層 / カード&タイル中心 / 部分的にリキッドグラス**」を基本方針とする。

**主要 4 タブ（BottomNavigationBar）**

| # | タブ名 | ページ | 用途 |
|---|-------|-------|------|
| 0 | ホーム | `YearPage` | 年間収支・固定費・ボーナス計画・生活収支グラフ |
| 1 | 入力 | （モーダル） | 支出/収入/固定費の入力モーダルを開く |
| 2 | 分析 | `MonthlyPage` | 月次の収支・カテゴリ別・予算・予測 |
| 3 | 履歴 | `ExpenseHistoryPage` | カレンダーベースの取引履歴 |

アクセントカラーは `#0BB283` のミントグリーン（`MyColors.themeColor`）。

---

## 1. Design Principles

1. **ダークテーマ固定**
   - `main.dart` で `theme: ThemeData.dark()` / `darkTheme: ThemeData.dark()` / `themeMode: ThemeMode.dark` の3点を固定し、OS設定を無視する。
   - 一貫した色階層のため、ライトテーマは存在しない。

2. **iOS HIG ライクなラベル階層**
   - 透過白の4段階：`label`（不透明）/ `secondaryLabel`（α60%）/ `tirtiaryLabel`（α30%）/ `quarternaryLabel`（α18%）。
   - 強調・本文・補助・無効の役割を色の濃さで表現。

3. **カテゴリ色は DB シードに HEX で保存**
   - 動的に変更可能なため、`MyColors` の定数を直接参照せず `MyColors.getColorFromHex(colorCode)` で変換する。
   - DBの初期値は `lib/model/sql_on_create.dart` を参照（例: 食費=`FF7171`）。

4. **数字は `sf_ui`、日本語/混在は `noto_sans`**
   - 金額・日付などの数値は SF UI Display（英数のみ）。
   - 見出し・本文・カテゴリ名など日本語が混じるテキストは Noto Sans JP。

5. **`MyColors` / `AppTextStyles` を必ず経由**（Skill `kakeibo-style-rules` 抜粋）
   - `Colors.white` 等の Flutter 既定や `Color(0xFF...)` の直書きは禁止。
   - `TextStyle(...)` の直書きおよび使用箇所での `MyFontStyle.notoSans.copyWith(...)` も禁止。
   - 未定義のスタイルが必要な場合は、まず `colors.dart` / `app_text_styles.dart` に追加してから参照する。

---

## 2. Color System

定義ファイル: `lib/constant/colors.dart` の `MyColors` クラス。

### 2.1 Brand / Theme

| 名前 | 値 | 用途 |
|------|-----|------|
| `themeColor` | `Color.fromARGB(255, 11, 178, 131)` ≒ `#0BB283` | アプリのメインアクセント（FAB、テーマ、チェック、適用ボタン） |
| `themeThinColor` | `#D7FFF4` | 「変動あり」チップ背景などのテーマ淡色 |
| `themeSecondaryColor` | `Color.fromARGB(255, 63, 200, 161)` ≒ `#3FC8A1` | BottomNavigationBar の選択色 |
| `blackmint` | `#0BB283` | `themeColor` と同値の別名 |
| `buttonPrimary` | = `themeColor` | プライマリボタン背景のエイリアス |

### 2.2 iOS System Background

| 名前 | 値 | 用途 |
|------|-----|------|
| `systemBackground` | `#000000` | 最背面（純黒） |
| `secondarySystemBackground` | `#1C1C1E` | カード、BottomNav 背景、リキッドグラスの素地 |
| `tirtiarySystemBackground` | `#2C2C2E` | メニュー / ポップアップ背景 |
| `tertiarySystemBackground` | `#2C2C2E` | `tirtiary...` の typo 修正版（同値） |

### 2.3 System Gray Scale

| 名前 | 値 | 用途 |
|------|-----|------|
| `systemGray` | `#8E8E93` | 標準グレー（固定費カテゴリのデフォルト色と同じ値） |
| `systemGray2` | `#636366` | |
| `systemGray3` | `#48484A` | |
| `systemGray4` | `#3A3A3C` | 「今月度に戻す」ボタン等 |
| `systemGray5` | `#2C2C2C` | ダイアログ背景 |
| `systemGray6` | `#1C1C1E` | |
| `lightGray` | `#F6F6F6` | 補助色（ほぼ未使用） |
| `dimGray` | `#6A706E` | |
| `jet` | `#3F3D3D` | |
| `eerieBlack` | `#1E1E1E` | |
| `richBlack` | `#051014` | |

### 2.4 Label Hierarchy

| 名前 | 値 | 用途 |
|------|-----|------|
| `label` | `#FFFFFF` | 強調・本文（不透明白） |
| `secondaryLabel` | `0x99EBEBF5`（α≒60%） | 補助テキスト、サブタイトル |
| `tirtiaryLabel` | `0x4CEBEBF5`（α≒30%） | プレースホルダー、期間外の日付 |
| `quarternaryLabel` | `0x2DEBEBF5`（α≒18%） | 無効・極薄 |

### 2.5 System Fill

| 名前 | 値 | 用途 |
|------|-----|------|
| `systemfill` | `0x5B787880` | 一般的な fill |
| `secondarySystemfill` | `0x51787880` | ピル、円形アイコン背景 |
| `tirtiarySystemfill` | `0x3D767680` | |
| `quarternarySystemfill` | `0x39767680` | **CardContainer / AppListCard の標準背景** |
| `quarternarySystemfillOpaque` | `#2C2C30` | 透過なし版 |
| `separater` | `0x99545458` | メニュー内 1px Divider |
| `buttonSecondary` | = `systemfill` | セカンダリボタン背景のエイリアス |

### 2.6 Category Color - Expense

`MyColors` 定数と、`expense_big_category` テーブルの DB 初期値（`sql_on_create.dart`）の対応。

| カテゴリ名 | colorCode（DB） | MyColors 定数 | HEX |
|-----------|--------|-----------|------|
| 食費 | `FF7171` | `expensePink` | `#FF7171` |
| 日用品 | `FB5B01` | `expenseGiantsOrange` | `#FB5B01` |
| 遊び娯楽 | `3DD8E0` | `expenseMint` | `#3DD8E0` |
| 交通費 | `4BA6FF` | `expenseBlue` | `#4BA6FF` |
| 衣服美容 | `BB87FF` | `expensePurple` | `#BB87FF` |
| 医療費 | `DF2828` | `expenseRed` | `#DF2828` |
| 雑費 | `FFC700` | `expenseYellow` | `#FFC700` |
| （予備） | — | `expenseBrown` | `#AC3E00` |

### 2.7 Category Color - Income

| カテゴリ名 | colorCode（DB） | MyColors 定数 | HEX |
|-----------|--------|-----------|------|
| 月次収入 | `21D19F` | `incomeEmerald` | `#21D19F` |
| ボーナス | `10B981` | `incomeGreen` | `#10B981` |
| （予備） | — | `incomeDeepGreen` | `#059669` |
| （予備） | — | `incomeMintGreen` | `#6EE7B7` |

### 2.8 Category Color - Fixed Cost

固定費カテゴリは **意図的に全カテゴリ無彩色（`#8E8E93`）** で統一されている。

| カテゴリ名 | colorCode（DB） | MyColors 定数 |
|-----------|--------|-----------|
| 住居費 | `8E8E93` | `fixedCostGray` |
| サブスク | `8E8E93` | `fixedCostGray` |
| 通信費 | `8E8E93` | `fixedCostGray` |
| 光熱費 | `8E8E93` | `fixedCostGray` |
| その他 | `8E8E93` | `fixedCostGray` |

### 2.9 Accent / Utility

| 名前 | 値 | 用途 |
|------|-----|------|
| `pink` | `#FF7171` | マイナス金額表示、日曜日のラベル |
| `mintBlue` | `#36C5F1` | プラス金額系（補助）、土曜日のラベル |
| `linkColor` | `#0A84FF` | リンク |
| `barHandler` | `#D9D9D9` | モーダル上部のドラッグハンドル |
| `hoverColor` | `0x33000000` | タップフィードバック |
| `transparent` | `Colors.transparent` | 透明 |
| `white` | `Colors.white` | 純白（必要時のみ） |
| `black` | `Colors.black` | 純黒（必要時のみ） |

### 2.10 Helpers

```dart
// DB の HEX 文字列 → Flutter Color
Color getColorFromHex(String colorCode);

// Color → "rrggbb"（小文字）
String getColorCodeFromColor(Color color);

// Color → "RRGGBB"（大文字）
String getHexFromColor(Color color);
```

カテゴリ色は DB に保存される HEX 文字列を `getColorFromHex` で `Color` に変換して描画する。

---

## 3. Typography

> **本節は Vault へ移植済み（2026-08-30 KP-007）。正本は
> `/Users/puruwo/kakeibo_vault/06_design/Kakeibo テキストスタイルルール.md`。**
> 判断フロー・役割別の全スタイル一覧・型スケール（`AppTypeScale`）・ファミリーの使い分け・
> 禁止事項・逸脱の記録はすべて Vault 側で管理し、本ファイルには書かない。
>
> 定義ファイル: `lib/constant/font_style.dart`（family）→ `lib/constant/styles/app_type_scale.dart`（段・値の正本）
> → `lib/constant/styles/app_text_styles.dart` ほか（役割スタイル）。
> 規約チェック: `scripts/check_text_style.sh`（警告のみ）。発火用 Skill: `~/.claude/skills/kakeibo-text-style-rules/`。

---

## 4. Theme & Global Style

定義ファイル: `lib/main.dart`、`lib/view/foundation.dart`

### MaterialApp 設定

```dart
MaterialApp(
  theme: ThemeData.dark(),
  darkTheme: ThemeData.dark(),
  themeMode: ThemeMode.dark,
  debugShowCheckedModeBanner: false,
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  // MediaQuery override:
  //   textScaler: TextScaler.linear(1.0)
  //   boldText: false
  // → OS設定による拡大・太字化を無効化（フォント一貫性確保）
)
```

### Scaffold（Foundation）

- `extendBody: true` — BottomNav の下までボディを伸ばし、半透明感を活かす
- `backgroundColor` 指定なし → `ThemeData.dark()` のデフォルト

### リキッドグラス標準レシピ

アプリ全体で **唯一のレシピ**（使用箇所: `GlassAppBarBackground`、BottomNavigationBar の2つだけ）。

```dart
ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
    child: Container(
      color: MyColors.secondarySystemBackground.withOpacity(0.7),
      // ...
    ),
  ),
)
```

### ステータスバー

`SystemUiOverlayStyle` の明示設定はなし。`ThemeData.dark()` のデフォルト（明色アイコン）に依存。

---

## 5. Common UI Components

すべてダーク前提・iOS 風の見た目。共通widget一覧は **`view/component/` 17ファイル + `util/common_widget/` 5ファイル = 22 widget**。

> Skill `kakeibo-common-components` に詳細利用ガイドあり（記載済み7件 + 本ドキュメントで補完15件）。
> 既存ガイド: `CardContainer` / `AppListCard` / `AppPillContainer` / `AppIconCircleContainer` / `UnconfirmedFixedCostChipLabel` / `CheckBox` / `showAppYearMonthPicker`

### 5.1 Card 系

#### `CardContainer`
ファイル: `lib/view/component/card_container.dart`

- **用途**: 汎用カード背景。`Container` + `BoxDecoration(色, 角丸)` の置き換え。
- **見た目**: 背景 `MyColors.quarternarySystemfill` / 角丸 18px（`appCardRadius`）/ 影なし
- **API**: `decoration` は固定、他の `Container` 引数は全指定可
- **export**: トップレベル `BorderRadius get appCardRadius => BorderRadius.circular(18)`

#### `AppPillContainer`
ファイル: `lib/view/component/app_pill_container.dart`

- **用途**: 入力ページの日付ボタン・予算行などのピル型コンテナ
- **見た目**: 背景 `MyColors.secondarySystemfill` / 角丸 50px（ピル）/ 高さ `InputPageWidgetSize.pillHeight`
- **注意**: 動的に色が変わるピルには使わない

### 5.2 List 系

#### `AppListCard`
ファイル: `lib/view/component/app_list_card.dart`

履歴・分析・カレンダー画面の **リストタイル統一widget**。

- **デフォルト高さ**: 69px（2行時）/ 53px ≒ `69 / 1.3`（1行時）
- **下部 padding**: 8px（タイル間余白）
- **値段エリア幅**: 128px
- **横 padding**: `14.5 * screenHorizontalMagnification`
- **背景**: デフォルト `MyColors.quarternarySystemfill`、角丸 `appCardRadius`（18px）
- **タップ可**: 内部で `AppInkWell` を使用
- **レイアウト**:
  ```
  | [icon 25x25] | [primaryTitle] [secondaryTitle]  | [price ±] |
  |              | [subLeading]   [subTrailing]     | [underPriceLabel] |
  ```
- **主要API**: `iconPath` / `iconColor` / `primaryTitle` / `secondaryTitle` / `subtitleLeading` / `subtitleTrailing` / `priceLabel` / `isIncome` / `customUnderPriceLabel` / `onTap` / `onLongPress`

### 5.3 Icon 系

#### `AppIconCircleContainer`
ファイル: `lib/view/component/app_icon_circle_container.dart`

- **用途**: カテゴリーアイコン背景の標準
- **見た目**: `BoxShape.circle` / デフォルト色 `MyColors.secondarySystemfill` / `size` と `child` のみ
- **備考**: 選択状態などで `color` 上書き可

#### `CheckBox`
ファイル: `lib/view/component/check_box.dart`

- **用途**: 円形チェックボックス（カテゴリ表示切替など）
- **サイズ**: 23×23 / `BoxShape.circle`
- **チェック時**: 背景 `themeColor` + `Icons.done_rounded`(19px, `label`)
- **非チェック時**: 透明背景 + `secondarySystemfill` 1px ボーダー

#### `UnconfirmedFixedCostChipLabel`
ファイル: `lib/view/component/unconfirmed_fixed_cost_chip_label.dart`

- **用途**: 未確定固定費「変動あり」チップ
- **見た目**: padding H6/V2 / 右マージン4px / 背景 `themeThinColor` / 角丸 4px / `themeColor` 1px ボーダー
- **中身**: `Icons.show_chart`(12px, `themeColor`) + 「変動あり」(noto / 10 / w400)

### 5.4 Header 系

#### `AppContentsHeader`
ファイル: `lib/view/component/app_contents_header.dart`

- **用途**: 画面内セクションヘッダー（「支出グラフ」「今月の計画」等）
- **見た目**: 高さ 37px
- **構造**: 左=アイコン(IconData 18px or iconWidget) + タイトル / 右=subLabel（`isLinkable: true` で `TextButton` 化）
- **API**: `type` で `appCardSectionTitle` / `listCardSectionTitle` 切替

#### `AppTab`
ファイル: `lib/view/component/app_component.dart`

- **用途**: カテゴリ設定ページ等のタブバー
- **見た目**: `indicatorColor: themeColor` / `indicatorWeight: 2` / `TabBarIndicatorSize.tab` / `preferredSize: kToolbarHeight`
- **PreferredSizeWidget** 実装

#### `GlassAppBarBackground`
ファイル: `lib/view/component/glass_app_bar_background.dart`

- **用途**: AppBar の `flexibleSpace` に挿すリキッドグラス背景
- **見た目**: `BackdropFilter(ImageFilter.blur(sigmaX:15, sigmaY:15))` + `secondarySystemBackground.withOpacity(0.7)`

#### `showAppYearMonthPicker` / `AppYearMonthPickerMode`
ファイル: `lib/view/component/app_year_month_picker.dart`

- **用途**: AppBar 下にドロップダウン展開する年月度・年度ピッカー（Overlay 式）
- **背景**: `Colors.black.withValues(alpha: 0.75)`
- **モード**:
  - `yearMonth` — 年列 + 月度列の2ドラム
  - `year` — 「YYYY年M月〜YYYY年M月」形式の年ドラム
- **見た目**:
  - ヘッダーカード: `tirtiarySystemBackground` / 角丸 16px
  - Picker: 216px 高 / 角丸 16px / `CupertinoPicker` / itemExtent 38 / magnification 1.1
  - フッターボタン: 「今月度に戻す」`systemGray4` + 「適用」`themeColor`（角丸 28px ピル）
- **戻り値**: `Future<DateTime?>`
  - 月度モード: `DateTime(year, month+1, 0)`（月末日）
  - 年度モード: `DateTime(year, 1, 1)`

### 5.5 Button 系

#### `MainButton` / `SubButton` / `ButtonColorType`
ファイル: `lib/view/component/button_util.dart`

- **MainButton**: 高さ 40 / メインアクション
- **SubButton**: 高さ 30 / セカンダリアクション
- **色**:
  - `ButtonColorType.main` → `MyColors.buttonPrimary`（= `themeColor`）
  - `ButtonColorType.secondary` → `MyColors.buttonSecondary`（= `systemfill`）
- **elevation**: 0
- **disabled 時**: `hoverColor` を alphaBlend
- **オプション**: `MainButton` はアイコン併設可能

#### `AppFloatingActionButton`
ファイル: `lib/view/component/app_floating_action_button.dart`

- **用途**: 汎用 FAB
- **見た目**:
  - `label` なし → 円形 56×46
  - `label` あり → Extended 高さ 46 / padding H20 / `StadiumBorder`
- **色**: 背景 `themeColor` / 前景 `white` / **elevation 6**
- **InkWell**: `highlightColor: Colors.black.withValues(alpha: 0.1)`

### 5.6 Dialog 系

#### `showConfirmationDialog` / `showDeleteConfirmationDialog`
ファイル: `lib/util/common_widget/app_dialog.dart`

- **用途**: 汎用確認ダイアログ / 削除確認専用ラッパー
- **見た目**: `Dialog` / 背景 `MyColors.systemGray5` / 角丸 24px / padding `fromLTRB(24,24,24,20)`
- **構造**: タイトル(`dialogTitle`) + 16px gap + メッセージ(`dialogLabel`) + 24px gap + `SubButton` 2列(secondary/main, 12px gap)

#### `PriceInputDialog` / `showPriceInputDialog`
ファイル: `lib/util/common_widget/price_input_dialog.dart`

- **用途**: 未確定固定費の金額入力ダイアログ
- **見た目**: `Dialog` / 角丸 24px / padding 16px
- **中身**: タイトル + 中央寄せ `TextFormField`（`cursorColor: themeColor`、`cursorHeight: 25`、最大10文字、`NumberTextInputFormatter`）+ キャンセル / OK ボタン

#### `showMenuDialog` / `MenuDialogItem`
ファイル: `lib/view/component/modal.dart`

- **用途**: 下からスライドアップする iOS ActionSheet 風メニュー
- **見た目**: 背景 `tirtiarySystemBackground` / 角丸 12px
- **構造**: 項目間に `MyColors.separater` 1px Divider、項目の角丸は最初/最後/単独で自動切替。キャンセル別 Container（同スタイル）固定表示
- **項目**: アイコン(24px, デフォルト `themeColor`) + ラベル(`dialogList`)

#### `CheckablePopupMenuItem` / `buildCheckableMenuItem` / `AppPopupMenu`
ファイル: `lib/util/common_widget/checkable_popup_menu_item.dart`

- **用途**: 共通 `PopupMenuButton`
- **見た目**: 背景 `tertiarySystemBackground` / 角丸 12px / オフセット (0, 40)
- **チェック付き項目**: `Icons.check`(20px, `themeColor`) + ラベル(`popupMenuItemLabel`)

### 5.7 Modal 系

#### `showAppModalBottomSheet`
ファイル: `lib/view/component/modal.dart`

- **用途**: アプリ共通のフルスクリーン風モーダル
- **実装**: `PageRouteBuilder` でカスタム下→上スライド（**280ms / `easeOutCubic`**）
- **オプション**: `useRootNavigator` / `useSafeArea` 切替可
- **代表的な呼び出し先**: `RegisaterPageBase` / `DailyExpenseSummaryPage` / `CategorySettingPage`

### 5.8 Interaction 系

#### `AppInkWell`
ファイル: `lib/util/common_widget/inkwell_util.dart`

- **用途**: タップ可能エリアの統一ラッパー
- **実装**: `Material` + `InkWell` / 角丸デフォルト 12px（引数で上書き可）
- **タップ表現**: `splashColor: Colors.transparent` / `highlightColor` デフォルト `Colors.black.withOpacity(0.1)`
- **備考**: `AppListCard` 内部でも使用

### 5.9 Feedback 系

#### `OverlayLoading`
ファイル: `lib/view/component/loading.dart`

- **用途**: 全画面ローディングオーバーレイ
- **見た目**: `ColoredBox` 背景（デフォルト `Colors.black26`） + 中央 `CircularProgressIndicator`

#### `SuccessSnackBar` / `FailureSnackBar`
ファイル: `lib/view/component/success_snackbar.dart` / `failure_snackbar.dart`

- **用途**: 結果通知の共通スナックバー
- **見た目**: `SnackBarBehavior.floating` / 表示 2秒 / 角丸 8px
- **API**: `show(scaffoldMessenger, message)` 静的メソッド（現在表示中を `hideCurrentSnackBar()` してから表示）

### 5.10 その他

#### `AppException`
ファイル: `lib/view/component/app_exception.dart`

- **用途**: アプリ内共通例外クラス
- **デフォルトメッセージ**: 「エラーが発生しました」

---

## 6. Layout & Navigation

定義ファイル: `lib/view/foundation.dart`

### 6.1 全体構造

```
MaterialApp
└─ Foundation [Scaffold + BottomNavigationBar (4タブ)]
   │
   ├─ [0] ホーム  : Navigator(navigatorKeys[0]) → YearPage
   │     ├─ push: BonusHomePage / FixedCostRegistrationListPage
   │     └─ rootNavigator.push: ConfigTop
   │
   ├─ [1] 入力    : Container()（IndexedStack上のダミー）
   │     └─ タップで rootNavigator + showAppModalBottomSheet
   │        → RegisaterPageBase.addExpense（フルモーダル）
   │
   ├─ [2] 分析    : Navigator(navigatorKeys[2]) → MonthlyPage
   │     ├─ push: MonthlyPlanHomePage / YearlyIncomeListPage / MonthlyFixedCostPage
   │     ├─ showAppModalBottomSheet: CategorySettingPage
   │     └─ rootNavigator.push: ConfigTop
   │
   └─ [3] 履歴    : Navigator(navigatorKeys[3]) → ExpenseHistoryPage
         ├─ 日付タップ: showAppModalBottomSheet(DailyExpenseSummaryPage)
         └─ rootNavigator.push: ConfigTop
```

### 6.2 BottomNavigationBar

| プロパティ | 値 |
|----------|-----|
| `type` | `BottomNavigationBarType.fixed` |
| `selectedItemColor` | `MyColors.themeSecondaryColor`（`#3FC8A1`） |
| `backgroundColor` | `MyColors.secondarySystemBackground.withOpacity(0.7)` |
| `elevation` | 0 |
| 背面 | `ClipRect` + `BackdropFilter(blur 15)` でリキッドグラス |

**タブアイコン / ラベル**

| # | アイコン | ラベル |
|---|---------|-------|
| 0 | `Icons.home_outlined` | ホーム |
| 1 | `Icons.add` | 入力 |
| 2 | `Icons.auto_graph_rounded` | 分析 |
| 3 | `Icons.calendar_month_rounded` | 履歴 |

**ナビゲーション挙動**

- `IndexedStack` + タブごとの `GlobalKey<NavigatorState>` で状態保持
- 同タブ再タップ: `popUntil((route) => route.isFirst)` で初期画面までポップ
- タブ切替: `_fadeController.value = 0.0` → タブ変更 → `forward()` で 200ms / `easeIn` フェード
- タブ1（入力）はダミーで、タップで `showAppModalBottomSheet` を起動するのみ

**初回起動時**

- `WidgetsBinding.instance.addPostFrameCallback` で `_showExpenseEntrySheet(context)` を実行
- → 起動と同時に費用入力モーダルが立ち上がる

### 6.3 ルーティングパターン

| パターン | 実装 | 使用シーン |
|---------|------|-----------|
| タブ内 push | `Navigator.of(context).push(MaterialPageRoute(...))` | サブ画面（BonusHomePage 等） |
| rootNavigator push | `Navigator.of(context, rootNavigator: true).push(...)` | 設定画面（タブ上に被せる） |
| モーダル | `showAppModalBottomSheet(context, child: ...)` | 入力・カテゴリ設定・日次サマリー |
| ダイアログ | `showDialog(context: ..., builder: ...)` | 確認・削除確認・色/アイコン選択 |
| 年月ピッカー | `showAppYearMonthPicker(mode: ...)` | AppBar タイトル直下にドロップダウン |

名前付きルートは未使用。すべて `MaterialPageRoute` で型安全に遷移する。

---

## 7. Screen Inventory

### 7.1 タブ 0: ホーム (YearPage)

ファイル: `lib/view/year_page/year_page.dart`

**AppBar**
- 中央: 「YYYY年M月〜YYYY年M月 / X年度」、タップで `showAppYearMonthPicker(mode: year)`
- 背景: `GlassAppBarBackground`
- 右上: 設定アイコン（`rootNavigator.push(ConfigTop)`）

**Body セクション**（縦スクロール）
| セクション | Widget / ファイル | 備考 |
|-----------|------------------|------|
| 年間収支 | `YearlyBalanceArea` (`yearly_balance_area.dart`, `yearly_balance_bar_graph.dart`) | |
| 固定費ボタン | `FixedCostButtonArea` | 0件なら誘導、ありなら管理+追加 |
| ボーナス利用状況 | `resolvedBonusSectionDisplayProvider` 経由 | normal / registerPrompt / hidden 切替。「さらに表示」→ `BonusHomePage` |
| 生活収支 | `AnnualBalanceChart` | fl_chart 非依存の自作 `CustomPaint`（KAN-82 再実装） |

**レイアウト**: `SingleChildScrollView` + `extendBodyBehindAppBar: true` / 左右 `context.leftsidePadding` / 末尾 `SizedBox(128)` でグロナビ分の余白。

### 7.2 タブ 1: 入力 (RegisaterPageBase)

ファイル: `lib/view/register_page/register_page_base.dart`、`submit_button.dart`

`showAppModalBottomSheet` でフルスクリーン風モーダル表示。`ClipRRect(top: 16)` で上端だけ角丸。

**TransactionMode**
- `expense` → `RegisterExpensePage`
- `income` → `RegisterIncomePage`
- `fixedCost` → `RegisterFixedCostPage`
- 切替は `AnimatedSwitcher`

**名前付きコンストラクタ（6パターン）**
- `addExpense` / `editExpense`
- `addIncome` / `editIncome`
- `addFixedCost` / `editFixedCost`

**AppBar**
- 左: 閉じる（`rootNavigator` pop + 入力 state invalidate）
- 中央: モード名
- 右: 編集モード時のみ削除アイコン → `showDeleteConfirmationDialog`

**関連ディレクトリ**
- `category_area/` — カテゴリ選択
- `common_input_field/` — 共通入力
- `fixed_cost_tab/payment_frequency_input_area/` — 頻度ピッカー
- `large_price_display.dart` — 大型金額表示

### 7.3 タブ 2: 分析 (MonthlyPage)

ファイル: `lib/view/monthly_page/monthly_page.dart`

**AppBar**
- 中央: 「M月度 / 一般会計」、タップで `showAppYearMonthPicker(mode: yearMonth)`
- 右上: 設定

**Body セクション**
| セクション | Widget | アクション |
|-----------|--------|-----------|
| 支出グラフ | `PredictionGraph` + skeleton (`prediction_graph_area/`, `skeleton/`) | |
| 今月の収支 | `MonthlyPlanArea` / データなしは `MonthlyPlanRegisterPromptArea` | 「収入を追加」→ `YearlyIncomeListPage`、「予算を編集」→ `MonthlyPlanHomePage` |
| カテゴリー別 | `CategorySumTileList` | 「カテゴリー設定」→ `showAppModalBottomSheet(CategorySettingPage)` |
| 固定費 | `MonthlyFixedCostSummaryArea` | 「さらに表示」→ `MonthlyFixedCostPage` |

### 7.4 タブ 3: 履歴 (ExpenseHistoryPage)

ファイル: `lib/view/historical_calendar_page/expense_history_page.dart`

**AppBar**
- 左: `CalendarPreviousArrowButton`（前月）
- 中央: 「YYYY年 M月」
- 右: `CalendarNextArrowButton`（次月）
- 右上 Stack: 設定アイコン

**Body**
- `CalendarArea` — 月カレンダー（5週/6週可変）
  - 各 `date_box.dart`（日タップで `DailyExpenseSummaryPage` をフルモーダル）
- `ExpenceHistoryArea` — その日の取引リスト
  - 各タイル: `transaction_group_tile.dart` / `tiles/`

### 7.5 push サブ画面（タブ内）

| ページ | ファイル | 概要 |
|-------|---------|------|
| `BonusHomePage` | `year_page/bonus_plan_area/bonus_home_page/` | TabController 2タブ（収入/支出）+ フッター |
| `FixedCostRegistrationListPage` | `year_page/fixed_cost_button_area/fixed_cost_registration_list_page/` | 固定費登録一覧 |
| `MonthlyPlanHomePage` | `monthly_page/monthly_plan_area/monthy_plan_home_page/` | 予算編集（`BudgetCategoryArea` + フッターボタン） |
| `MonthlyFixedCostPage` | `monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/` | カテゴリ別固定費一覧 |
| `YearlyIncomeListPage` | `yearly_income_list_page/` | 収入グラフ + リスト + FAB |

### 7.6 rootNavigator push

| ページ | ファイル | 概要 |
|-------|---------|------|
| `ConfigTop` | `view/config/config_top.dart` | 設定画面（現状: 入力履歴エクスポート1項目） |

### 7.7 モーダル / ダイアログ

**showAppModalBottomSheet 系**
- `RegisaterPageBase`（起動時自動 + 入力タブ）
- `DailyExpenseSummaryPage`（カレンダー日タップ）
- `CategorySettingPage`（`category_edit_page/category_setting_page.dart`）
  - TabController 3タブ: 一般 / 固定費 / 収入
  - 編集モード中はタブ操作を `IgnorePointer` + 半透明化
  - 子: `BigCategoryDetailEditPage`（expense / income / fixedCost 3種）、`SmallCategoryEditArea`
  - ダイアログ: `color_select_dialog.dart` / `icon_select_dialog.dart` / `new_small_category_input_name_dialog.dart`
- `RegisterFixedCostPage`（一部箇所からの単体 push）

**showDialog 系**
- `showDeleteConfirmationDialog`（`util/common_widget/app_delete_dialog.dart`）
- カテゴリ編集の各種ダイアログ（色 / アイコン / 名前）

**Overlay 系**
- `showAppYearMonthPicker`（年月度 / 年度切替）

---

## 8. Standard Values（早見表）

### 角丸

| 用途 | 値 |
|------|-----|
| カード | **18px** (`appCardRadius`) |
| ピル | 50px |
| ダイアログ | 24px |
| メニュー / ポップアップ / AppInkWell | 12px |
| 年月ピッカー（ヘッダー&ピッカー） | 16px |
| 「変動あり」チップ | 4px |
| スナックバー | 8px |
| FAB（円形 / Extended） | `CircleBorder` / `StadiumBorder` |

### サイズ・スペーシング

| 項目 | 値 |
|------|-----|
| `AppListCard` 高さ（2行） | 69px |
| `AppListCard` 高さ（1行） | `69 / 1.3 ≒ 53px` |
| `AppListCard` 値段エリア幅 | 128px |
| `AppListCard` 横 padding | `14.5 * screenHorizontalMagnification` |
| `AppListCard` アイコンサイズ | 25×25 |
| `AppContentsHeader` 高さ | 37px |
| `MainButton` 高さ | 40 |
| `SubButton` 高さ | 30 |
| `AppFloatingActionButton` 円形 | 56×46 |
| `AppFloatingActionButton` Extended 高さ | 46（H padding 20） |
| `CheckBox` | 23×23 |
| 年月ピッカー itemExtent | 38（magnification 1.1） |
| ピッカー高さ | 216px |

### リキッドグラス

| 項目 | 値 |
|------|-----|
| blur | `sigma 15`（X / Y） |
| 背景 | `MyColors.secondarySystemBackground.withOpacity(0.7)` |
| 使用箇所 | `GlassAppBarBackground` / BottomNavigationBar |

### アニメーション

| 項目 | 値 |
|------|-----|
| タブ切替フェード | 200ms / `Curves.easeIn` |
| モーダルスライド（`showAppModalBottomSheet`） | 280ms / `Curves.easeOutCubic` |
| AppBar タイトル月切替 | 200ms フェード（`AnimatedSwitcher`） |

### Elevation

| 項目 | 値 |
|------|-----|
| AppBar | 0 |
| BottomNavigationBar | 0 |
| `MainButton` / `SubButton` | 0 |
| FAB | 6 |

### 主要背景色階層

| 用途 | カラー |
|------|--------|
| 全体背景 | `ThemeData.dark()` デフォルト |
| カード | `MyColors.quarternarySystemfill` |
| ピル / 円形アイコン | `MyColors.secondarySystemfill` |
| ダイアログ | `MyColors.systemGray5` |
| メニュー / ポップアップ | `MyColors.tirtiarySystemBackground` |
| リキッドグラス | `MyColors.secondarySystemBackground` α 70% + blur 15 |

---

## 9. Reference Files

このドキュメントを更新するときに参照する Single Source of Truth 一覧（絶対パス）。

### コアファイル

- `lib/constant/colors.dart`
- `lib/constant/font_style.dart`
- `lib/constant/styles/app_text_styles.dart`
- `lib/constant/styles/register_page_styles.dart`
- `lib/constant/styles/graph_text_styles.dart`
- `lib/constant/styles/calendar_styles.dart`
- `lib/main.dart`
- `lib/view/foundation.dart`
- `lib/view/component/glass_app_bar_background.dart`
- `lib/view/component/card_container.dart`
- `lib/view/component/app_list_card.dart`
- `lib/model/sql_on_create.dart`
- `pubspec.yaml`

### 既存ドキュメント・台帳

- （`lib/docs/font_usage.csv`・`font_issues.csv` は 2026-08-30 KP-007 で廃止。テキストスタイルの一覧は Vault「Kakeibo テキストスタイルルール」§2）
- `lib/docs/providers.csv` — Provider 一覧（参考）

### Skill

- `.claude/skills/kakeibo-style-rules/SKILL.md` — 色・文字・レイアウトの振り分けポインタ（本文は Vault）
- `.claude/skills/kakeibo-common-components/SKILL.md` — 共通widget利用ガイド

---

> **最終更新**: 2026-05-24
> **メンテナンス**: コードの値を変更したら、対応するセクションを更新すること。トークン値の追加・変更は、必ず `MyColors` / `AppTextStyles` 経由で行う（[Design Principles 5](#1-design-principles) 参照）。
