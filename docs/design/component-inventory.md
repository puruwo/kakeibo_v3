# Figmaコンポーネントライブラリ 棚卸し（C-2）

> `lib/` の共通UIを、Figmaコンポーネント化の観点で棚卸しした一覧。
> figma-builder / figma-from-screenspec が「使ってよい部品」を判断する際の正本となる。
> 実装側の利用ガイドは `kakeibo-common-components` スキルを参照（重複させない）。

対象Figmaファイル: `UhV3dLrJDWKuOdG9ik4uHW`（デザインシステムは Component ページに整備）

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

## 次のステップ

1. P1の10個を1個ずつFigmaのComponentページに作成（各コンポーネントごとに人間レビュー）
2. P2・P3を同様に作成
3. `figma-from-screenspec` スキルに「画面スペック要素→本一覧のコンポーネント」マッピング表を記載
4. 既存画面1つ（候補: 月間分析ページ）をコンポーネントだけで再現し充足度を検証
