# Figmaコンポーネントライブラリ 棚卸し（C-2）

> `lib/` の共通UIを、Figmaコンポーネント化の観点で棚卸しした一覧。
> figma-builder / figma-from-screenspec が「使ってよい部品」を判断する際の正本となる。
> 実装側の利用ガイドは `kakeibo-common-components` スキルを参照（重複させない）。

対象Figmaファイル: `UhV3dLrJDWKuOdG9ik4uHW`（デザインシステムは **kakeibo DS** ページに整備済み。旧Componentページの手作り資産とは共存・分離）

> **✅ 2026-06-12 P1〜P3 作成完了**（22コンポーネント）。
> 「kakeibo DS」ページ（nodeId `3468:4965`）にセクション P1 Atoms / P1 Molecules / P2 Input / P3 Feedback で配置。
> 月間分析ページのドラフト再現による充足度検証も完了（Screen Drafts ページ `Draft/月間分析`）。
> 発見されたギャップは末尾「検証で発見されたギャップ」を参照。

## 前提（整備済みの土台）

- Figma Variables: `Primitives`(4) / `Color`(22, Light・Darkモード) / `Category`(13) / `Global`(12)
- テキストスタイル: `kakeibo/` プレフィックスで21種（`AppTextStyles` 対応、説明欄に対応名を記録）
- フォント代替: Noto Sans JP の W600→**Bold**、SF UI Display→**SF Pro**（ユーザー承認済み）

## 優先度の考え方

| 優先度 | 基準 |
|---|---|
| **P1** | 画面の骨格を組むのに必須。ほぼ全画面で登場 |
| **P2** | 入力ページ・特定機能の頻出部品 |
| **P3** | フィードバック・オーバーレイ系。画面静止画の再現には低優先 |
| 対象外 | CustomPaint製グラフ等。コンポーネント化せずプレースホルダー枠で表現 |

## P1: コア（画面の骨格）

| # | コード | Figmaコンポーネント名（案） | バリアント | 状態 | 主な使用トークン/スタイル |
|---|---|---|---|---|---|
| 1 | `CardContainer` | `kakeibo/Card` | なし（padding可変） | - | fill: `fill-quaternary` / radius: `radius/card` |
| 2 | `AppListCard` | `kakeibo/ListCard` | Price=Expense/Income、Subtitle=あり/なし、SecondaryTitle=あり/なし | Default / Tappable | Card上に `list-tile-primary-title`・`list-tile-secondary-title`・`list-tile-price-label`、金額色 `expense`/`income`、アイコン色=Category変数 |
| 3 | `AppContentsHeader` | `kakeibo/SectionHeader` | Type=Card/ListCard、Icon=あり/なし、SubLabel=なし/テキスト/リンク | - | `card-section-title` / `list-card-section-title`、リンク色 `link` |
| 4 | `MainButton` | `kakeibo/Button` | Style=Main/Secondary、Icon=あり/なし | Enabled / Disabled | bg: `primary`/`fill`、disabled=overlayブレンド、text: `main-button`/`secondary-button`、高さ40 |
| 5 | `AppFloatingActionButton` | `kakeibo/FAB` | Shape=Circle/Extended(ラベル有) | - | bg: `primary`、前景: `on-primary`、高さ46・Stadium形 |
| 6 | `AppTab` | `kakeibo/TabBar` | タブ数=2/3 | Selected / Unselected | indicator: `primary`、text: `tab-selected`/`tab-unselected` |
| 7 | `AppPillContainer` | `kakeibo/Pill` | なし（中身スロット） | - | bg: `fill-secondary` / radius: `radius/pill` / 高さ: `size/pill-height` |
| 8 | `AppIconCircleContainer` | `kakeibo/IconCircle` | - | Default / Selected(色上書き) | bg: `fill-secondary`（既定）、shape: circle |
| 9 | `CheckBox` | `kakeibo/Checkbox` | - | Checked / Unchecked | check色: `primary` 系、shape: circle |
| 10 | `UnconfirmedFixedCostChipLabel` | `kakeibo/Chip` | - | - | border: テーマカラー / radius: `radius/chip` / text: 小サイズ |

## P2: 入力ページ系

| # | コード | Figmaコンポーネント名（案） | バリアント | 状態 | 備考 |
|---|---|---|---|---|---|
| 11 | `TransactionTypePill` | `kakeibo/TransactionTypePill` | Mode=支出/収入/固定費 | Enabled / Disabled | 色がモードで動的に変わるためPillとは別部品。●インジケータ+ラベル+▼ |
| 12 | `DateInputField` / `MemoInputField` / `BudgetRow` | `kakeibo/InputRow` | Kind=Date/Memo/Budget | Empty / Filled | `kakeibo/Pill` の中身バリエーションとして1コンポーネント+INSTANCE_SWAPで表現 |
| 13 | `showAppYearMonthPicker` | `kakeibo/YearMonthPicker` | Mode=年月度/年度 | - | AppBar下ドロップダウン+ドラム。**静止画再現のみ**（ドラムの中身は1状態でよい） |
| 14 | 価格入力エリア（`price_input_row`） | `kakeibo/PriceDisplay` | - | - | `large_price_display`。SF Pro大サイズの金額表示 |

## P3: フィードバック・オーバーレイ系

| # | コード | Figmaコンポーネント名（案） | バリアント | 備考 |
|---|---|---|---|---|
| 15 | `AppDialog` / `AppDeleteDialog` / `PriceInputDialog` | `kakeibo/Dialog` | Kind=確認/削除/金額入力 | bg: `fill-opaque`、title: `dialog-title`、本文: `dialog-label`、ボタン: `secondary-button` |
| 16 | `SuccessSnackBar` / `FailureSnackBar` | `kakeibo/Snackbar` | Kind=Success/Failure | floating・radius 8 |
| 17 | `showAppModalBottomSheet` | `kakeibo/BottomSheet` | - | コンテナ枠のみ（中身はスロット）。handle色: `handle` |
| 18 | `GlassAppBarBackground` | `kakeibo/AppBar` | - | ブラー背景。Figmaでは背景ブラー+透過surfaceで近似 |
| 19 | `PageLoadingIndicator` / `Loading` | `kakeibo/Loader` | - | 静止画再現の優先度低 |

## 対象外（コンポーネント化しない）

| コード | 理由 / Figmaでの扱い |
|---|---|
| 生活収支グラフ（`annual_balance_chart`・CustomPaint） | 自作描画。`kakeibo/ChartPlaceholder` 枠（タイトル+凡例+グレー領域）で表現 |
| 予測グラフ（`prediction_graph_painter`） | 同上 |
| 各種棒グラフ（`summary_bar_graph` 等） | 単純な矩形構成なので画面側で都度組む（Category変数でバインド） |
| `AppFabStack` | FAB配置のレイアウトルール。コンポーネントではなく画面テンプレート側の規約 |
| `inkwell_util` / `app_exception` | 非視覚要素 |

## Claudeが叩き台を作れる範囲 / 人間が決める範囲

- **Claude（MCP）で作成可**: 上記P1〜P3の全コンポーネントの構造（Auto Layout・Variables/スタイルのバインド・バリアント組み）。値はすべて整備済みVariables/スタイルを参照し、新しい色・サイズを発明しない
- **人間の判断が必要**:
  - 各コンポーネントの見た目の最終確認（特にW600→Bold代替の見え方）
  - 余白・サイズ感の微調整（コードのpadding値を初期値にする）
  - ライブラリとしてのpublish操作（Figma UI上の手動操作）

## 作成済みコンポーネントのnodeID（2026-06-12時点）

| コンポーネント | nodeId | | コンポーネント | nodeId |
|---|---|---|---|---|
| kakeibo/Card | 3469:4965 | | kakeibo/TransactionTypePill | 3480:4987 |
| kakeibo/Pill | 3470:4965 | | kakeibo/InputRow | 3482:4984 |
| kakeibo/IconCircle | 3471:4969 | | kakeibo/PriceDisplay | 3483:4971 |
| kakeibo/Checkbox | 3472:4969 | | kakeibo/YearMonthPicker | 3484:4971 |
| kakeibo/Chip | 3473:4965 | | kakeibo/Dialog | 3486:4993 |
| kakeibo/Button | 3474:4973 | | kakeibo/Snackbar | 3487:4977 |
| kakeibo/TabItem | 3475:4973 | | kakeibo/Loader | 3487:4978 |
| kakeibo/TabBar | 3475:4974 | | kakeibo/BottomSheet | 3488:4972 |
| kakeibo/SectionHeader | 3476:4979 | | kakeibo/AppBar | 3488:4975 |
| kakeibo/FAB | 3477:4978 | | kakeibo/ChartPlaceholder | 3489:4971 |
| kakeibo/ListCard | 3478:4983 | | kakeibo/BottomNav | 3489:4984 |
| kakeibo/CategoryIcon | 3504:4995 | | kakeibo/Dialog（作り直し後） | 3519:5001 |
| kakeibo/PeriodSelector | 3520:4975 | | kakeibo/CategorySumTile | 3521:5020 |

※IDは参考。figma-builder は名前（`kakeibo/` プレフィックス）での検索を正とする。

## 実機スクリーンショットとの擦り合わせ（2026-06-13・画面遷移図参照）

画面一覧ページの実機スクリーンショットと照合し、以下を実機準拠に修正済み:

- **kakeibo/CategoryIcon を新設**: `assets/images/icon_*.svg` の実SVG 8種（食費/日用品/遊び娯楽/交通費/衣服美容/医療費/雑費/収入）。円形バッジ=カテゴリー色25% + シンボル=カテゴリー色（Category変数バインド）
- **ListCard**: アイコンをCategoryIconインスタンスに差し替え。金額は実機準拠の「金額=text色（白）+ 末尾符号のみ色付き（- = expense / + = income）」構造へ変更。バリアント軸名を Price→**Type** に改名（TEXTプロパティPriceとの衝突解消）
- **BottomNav**: 中央の入力ボタンを実機準拠の**円形**（52px）に修正
- **AppBar**: 左=戻る矢印（Show Back、既定OFF）/ 右=設定ギア（Show Settings、既定ON）を追加。タイトル中央揃え
- **Button**: 入力画面の確定ボタンはこのButtonの色上書き（モード色: 支出=expense/収入=income/固定費=expense）で表現する（`submit_button.dart` 準拠）

※実機スクショの収入系は青（旧mintBlue系）だが、トークン決定（mintBlue→income #21D19F、承認済み）に従いDSは**incomeグリーン**を使用。

### Dialogの作り直し（2026-06-13・実装コード準拠）

旧Dialog（iOS風テキストボタン）は実装と乖離していたため削除し、`showConfirmationDialog`（app_delete_dialog.dart）準拠で再構築:

- 角丸 **radius/dialog(24)**（トークン新設）、padding 24/24/24/20
- タイトル（dialog-title 18）・本文（dialog-label 13）とも**中央揃え**
- ボタンは **SubButton準拠の塗りつぶしStadiumボタン×2を均等幅**（高さ30・gap12）: キャンセル=fill背景 / OK=primary背景、文字はどちらも text色 Bold 14
- 削除ダイアログも実装どおり**OKボタンはprimary**（赤の削除ボタンは存在しない）
- 別系統の `showMenuDialog`（下からのメニューリスト・角丸12）は未コンポーネント化（必要時に追加）

## 検証で発見されたギャップ（月間分析ドラフト再現より）

| # | ギャップ | 状態 |
|---|---|---|
| 1 | **年月度セレクタ行**（AppBar下の「2026年6月度 ▼」） | ✅ 解消（kakeibo/PeriodSelector: pageHeaderText+▼+サブラベル、TEXT/BOOLEANプロパティ付き） |
| 2 | **CategorySumTile**（カテゴリー別タイル: 棒グラフ+予算付き） | ✅ 解消（kakeibo/CategorySumTile: Budget=あり/超過/なし。バーh7・track=fill-secondary・fill=Category色・超過=overlay暗色。バー比率は画面側でfill幅調整） |
| 3 | **スロット制約**: Card/Pill/BottomSheet の contentスロットはインスタンスに子を追加できない | ✅ ルール化済み（画面側でラッパーフレーム+重ね配置・detach禁止。figma-from-screenspec 参照） |
| 4 | **実アイコン未整備** | ✅ 解消（kakeibo/CategoryIcon 8種を実SVGから作成） |
| 5 | **カテゴリー色の切替**: ListCardのアイコンがType既定（食費/収入）固定 | 一部解消（行ごとの差し替えはネストインスタンスのバリアント切替で可能。INSTANCE_SWAPプロパティ化は今後） |

### Figma操作の落とし穴（builder向けメモ）

- **ネストインスタンスのfill不透明度**: コンポーネント側のpaint opacityがインスタンスに伝播しないことがある。インスタンス側で `fills` を明示再設定する
- CategoryIcon以外のアイコン（ナビ・歯車・矢印等）は近似ベクター。必要に応じて実SVGへ差し替え

### コードドリフト（design-auditor向けメモ）

- `color_getter.dart`: 収入モードのピル色が `Colors.lightBlue` ハードコード（incomeトークン未使用）。DS側は income トークンに正規化済み

## 次のステップ

1. ~~P1〜P3作成~~ ✅ / ~~充足度検証~~ ✅ / ~~実機擦り合わせ・実アイコン化~~ ✅ / ~~Dialog作り直し・PeriodSelector・CategorySumTile追加~~ ✅ 2026-06-13
2. CategoryIconのINSTANCE_SWAPプロパティ化（ListCard/CategorySumTileの行ごとアイコン指定を簡便に）
3. C-3: confluence-reader → figma-builder の通し実行（1画面）
