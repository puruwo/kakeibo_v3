# Figmaコンポーネントライブラリ 棚卸し（C-2）

> `lib/` の共通UI・各画面のタイルを、Figmaコンポーネント化の観点で網羅的に棚卸しした正本。
> figma-builder / figma-from-screenspec が「使ってよい部品」を判断する際に参照する。
> 実装側の利用ガイドは `kakeibo-common-components` スキルを参照（重複させない）。

対象Figmaファイル: `UhV3dLrJDWKuOdG9ik4uHW`（デザインシステムは **kakeibo DS** ページ `3468:4965`。旧Componentページの手作り資産とは分離）

## 整備済みの土台

- Figma Variables: `Primitives`(4) / `Color`(22, Light・Darkモード) / `Category`(13) / `Global`(角丸・寸法・フォント)
- テキストスタイル: `kakeibo/` プレフィックスで21種（`AppTextStyles` 対応）
- フォント代替: Noto Sans JP の W600→**Bold**、SF UI Display→**SF Pro**（ユーザー承認済み）
- 収入系の色: 実機スクショは旧mintBlue青だが、トークン決定（mintBlue→income #21D19F）に従い**incomeグリーン**を使用

## ⚠️ リスト行は2系統ある（重要）

実機のリスト表示は見た目の異なる2系統に分かれる。混同しないこと:

| 系統 | コンポーネント | 見た目 | 使用画面 |
|---|---|---|---|
| **フラット行** | `kakeibo/TransactionRow` | 背景なし・区切り線・高さ49・末尾に符号アイコン・スワイプ削除 | 履歴カレンダー画面の取引一覧 |
| **カード型** | `kakeibo/ListCard` | `fill-quaternary`背景・角丸18・カード | 日次サマリー / ボーナス / 月間固定費 / 月間収入リスト |

---

## 全コンポーネント一覧（カテゴリ別）

`★` = 2026-06-13 の再棚卸しで追加。nodeId は参考（builderは名前検索を正とする）。

### 基礎・コンテナ

| コンポーネント | nodeId | 由来 | 内容 |
|---|---|---|---|
| `kakeibo/Card` | 3469:4965 | CardContainer | fill-quaternary・radius/card・contentスロット |
| `kakeibo/Pill` | 3470:4965 | AppPillContainer | fill-secondary・radius/pill・高さpill-height |
| `kakeibo/IconCircle` | 3471:4969 | AppIconCircleContainer | 円形アイコン背景。Default/Selected |
| `kakeibo/CategoryIcon` | 3504:4995 | カテゴリアイコン | 実SVG 8種（食費/日用品/遊び娯楽/交通費/衣服美容/医療費/雑費/収入）。円バッジ25%+シンボル=カテゴリ色 |

### ボタン・入力コントロール

| コンポーネント | nodeId | 由来 | 内容 |
|---|---|---|---|
| `kakeibo/Button` | 3474:4973 | MainButton | Style=Main/Secondary × Enabled/Disabled。高さ40 Stadium。入力確定ボタンは色上書き（支出expense/収入income） |
| `kakeibo/FAB` | 3477:4978 | AppFloatingActionButton | Circle/Extended |
| `kakeibo/Checkbox` | 3472:4969 | CheckBox | Checked/Unchecked・23px円 |
| `kakeibo/Toggle` ★ | 3529:5109 | PriceTypeSwitchArea | 変動費スイッチ。ラベル+Switch。On=primary/Off=icon |
| `kakeibo/CategorySelectButton` ★ | 3529:5100 | icon_box(normal/selected/none) | 入力画面のカテゴリ選択。58px円+アイコン+ラベル。Normal/Selected(icon色背景)/Empty |
| `kakeibo/TransactionTypePill` | 3480:4987 | TransactionTypePill | Mode=支出/収入/固定費。モード色10%背景+●+▼ |
| `kakeibo/InputRow` | 3482:4984 | DateInputField等 | Kind=Date/Memo/Budget。Pillベースの入力行 |
| `kakeibo/PriceDisplay` | 3483:4971 | LargePriceDisplay | ¥+大型金額(SF42) |
| `kakeibo/YearMonthPicker` | 3484:4971 | showAppYearMonthPicker | ドロップダウンドラム（静止画） |

### ナビゲーション・ヘッダー

| コンポーネント | nodeId | 由来 | 内容 |
|---|---|---|---|
| `kakeibo/AppBar` | 3488:4975 | GlassAppBarBackground | ガラス風。Show Back(戻る)/Show Settings(歯車)切替・タイトル中央 |
| `kakeibo/BottomNav` | 3489:4984 | foundation | 5タブ+中央円形入力ボタン |
| `kakeibo/TabBar` / `TabItem` | 3475:4974 / 3475:4973 | AppTab | Selected/Unselected・indicator |
| `kakeibo/SectionHeader` | 3476:4979 | AppContentsHeader | Type=Card/ListCard・アイコン/リンク |
| `kakeibo/PeriodSelector` | 3520:4975 | monthly_page ヘッダー | 「2026年6月度 ▼」+サブラベル |
| `kakeibo/DateSeparator` ★ | 3529:5086 | expence_history_list_area | 履歴の日付グループヘッダー「2023年12月31日(金)」 |

### リスト行・タイル

| コンポーネント | nodeId | 由来 | 内容 |
|---|---|---|---|
| `kakeibo/TransactionRow` ★ | 3525:5030 | expense/income/fixed_cost_item_tile | **履歴フラット行**。Type=支出/収入/固定費確定/固定費未確定。アイコン+名前+小カテゴリ/メモ+金額+末尾符号+区切り線 |
| `kakeibo/ListCard` | 3478:4983 | AppListCard | **カード型行**。Type=Expense/Income。アイコン+タイトル/サブ+金額+符号 |
| `kakeibo/CategorySumTile` | 3521:5020 | category_sum_tile | 月間カテゴリ別。Budget=あり/超過/なし。予算バー付き |
| `kakeibo/BudgetRow` ★ | 3531:5086 | budget_category_tile | 予算編集行。アイコン+名前+先月実績+今月予算+区切り線 |
| `kakeibo/Chip` | 3473:4965 | UnconfirmedFixedCostChipLabel | 「変動あり」チップ |

### カレンダー

| コンポーネント | nodeId | 由来 | 内容 |
|---|---|---|---|
| `kakeibo/Calendar` ★ | 3528:4989 | calendar_area | 曜日ヘッダー(日expense/土income)+7×5週グリッド |
| `kakeibo/CalendarDateBox` ★ | 3526:4999 | date_box | 日付セル。Default/Selected(fillTertiary)/OutOfPeriod。支出-/収入+金額 |

### グラフ・サマリー

| コンポーネント | nodeId | 由来 | 内容 |
|---|---|---|---|
| `kakeibo/ChartPlaceholder` | 3489:4971 | CustomPaintグラフ全般 | グラフ領域の枠（実描画は実装時） |
| `kakeibo/StackedBarGraph` ★ | 3530:5097 | summary_bar_graph | 積み上げ横棒。Type=Expense/Income。カテゴリ色セグメント |
| `kakeibo/BudgetSummaryBar` ★ | 3531:5095 | budget_page_summary_area | 予算サマリーカード。予算+総収入+予定収支+積み上げバー |

### オーバーレイ・フィードバック

| コンポーネント | nodeId | 由来 | 内容 |
|---|---|---|---|
| `kakeibo/Dialog` | 3519:5001 | showConfirmationDialog等 | Kind=確認/削除/金額入力。塗りSubButton×2(キャンセルfill/OK primary) |
| `kakeibo/Snackbar` | 3487:4977 | Success/FailureSnackBar | Success/Failure |
| `kakeibo/BottomSheet` | 3488:4972 | showAppModalBottomSheet | モーダル枠+handle+contentスロット |
| `kakeibo/Loader` | 3487:4978 | PageLoadingIndicator | 円弧スピナー |

セクション配置: P1 Atoms / P1 Molecules / P2 Input / P3 Feedback / **P4 Screen Parts**（`3525:4981`、★追加分）。

---

## 画面別カバレッジ（これで組める画面）

| 画面 | 構成コンポーネント | 可否 |
|---|---|---|
| 履歴（カレンダー） | AppBar + Calendar(CalendarDateBox) + DateSeparator + TransactionRow + BottomNav | ✅ |
| 月間分析 | AppBar + PeriodSelector + SectionHeader + ChartPlaceholder + CategorySumTile + BottomNav | ✅ |
| 予算編集 | AppBar + BudgetSummaryBar + BudgetRow + Button + BottomNav | ✅ |
| 入力モーダル | BottomSheet + TransactionTypePill + PriceDisplay + CategorySelectButton + InputRow + Toggle + Button | ✅ |
| 今月の収入/固定費 | AppBar + ListCard + ChartPlaceholder + FAB + BottomNav | ✅ |
| 全体（年間） | AppBar + ChartPlaceholder(生活収支) + ListCard + BottomNav | ✅（グラフは枠） |

---

## 未整備（残ギャップ・優先度低）

主要画面は上記でカバー済み。以下は専用性が高く、必要になった時点で追加する:

| 項目 | 由来 | 扱い |
|---|---|---|
| カテゴリ編集ダイアログ | color_select_dialog / icon_select_dialog | 色・アイコンのグリッド選択。カテゴリ編集画面で必要時に追加 |
| メニューダイアログ | showMenuDialog | 下からのリスト型メニュー（角丸12・別枠キャンセル）。Dialogとは別系統 |
| 空状態プロンプト | monthly_plan_register_prompt / bonus_register_prompt | 「予算を登録しましょう」等の促しエリア |
| カテゴリ並べ替えリスト | category_reorder_page / big_category_list | ドラッグ並べ替えUI |
| 専用グラフ | annual_balance / prediction / monthly_plan_graph | ChartPlaceholderで代替（実装時にCustomPaint） |
| ListCard詳細スロット | AppListCard | secondaryTitle(1行目右)・customUnderPriceLabel(金額下) は未対応。必要時に拡張 |

---

## Figma操作の落とし穴（builder向けメモ）

- **ネストインスタンスのfill不透明度**: コンポーネント側のpaint opacityがインスタンスに伝播しないことがある。インスタンス側で `fills` を明示再設定する
- **プロパティキーのsuffix**: `setProperties` のキーは `Name#123:4` 形式。`instance.componentProperties` から前方一致で解決する
- **バリアント軸名とTEXTプロパティ名の衝突回避**: 同名にしない（ListCardは Price軸→Type軸へ改名で解消）
- **共有TEXTプロパティの伝播（重要）**: TransactionRow・InputRow は Title/Sub/Price 等を**コンポーネントTEXTプロパティ**として全バリアントで共有している。1バリアントの文字を直接編集すると**全バリアントに伝播**する。バリアントで変えられるのは icon・符号・色・dim のみで、**文字列は変えられない**。固定費行の「固定費」「固定費(未確定)」、未確定の価格「未確定」等は**画面生成時にインスタンス側でプロパティ設定**すること（コンポーネント既定値は汎用サンプル＝支出例のまま）
- アイコン背景の形状: リスト行（TransactionRow/ListCard/BudgetRow）のカテゴリアイコンは**円背景なし**（実装は25pxのSVGを49×49 boxに配置するだけ）。一方カテゴリ選択ボタンの背景は**58×58の円**（`AppIconCircleContainer`=`BoxShape.circle`）。ナビ中央の入力ボタンは**42×42・角丸16の角丸スクエア**（円ではない）
- 汎用アイコン（ナビ・歯車・矢印等）は近似ベクター。CategoryIconのみ実SVG
- **CategoryIconのバリアントswap手順（行ごとに別カテゴリを出す）**: TransactionRow/BudgetRowのネスト`icon`インスタンスは`Category`バリアントを持つ。`icon.setProperties({Category:'日用品'})`で形状＋色を切替できる。**ただしswap直後はバッジ円が100%不透明で出てシンボルを覆う**（変数バインドpaintの不透明度が伝播しないため）。`icon.fills = []` で背景塗りを除去するとカテゴリシンボルだけ残る（リスト行は円背景なしが正）。`fills`のJSONクローン＋opacity変更は変数バインドを壊して無効化されるので**空配列が確実**
- **ピル系（TransactionTypePill等）の10%背景**: インスタンス化すると10%背景が100%不透明になりテキストを覆うことがある。bgノードに `setBoundVariableForPaint` 後 `paint.opacity = 0.1` を再設定して直す
- **CategorySelectButton/StackedBarGraph/Calendar のアイコン・シンボルはベイク**（CategoryIconインスタンスではない）。色だけはVector fillの直接RGBA指定で変えられるが形状swapは不可。将来CategorySelectButtonのアイコンをCategoryIconインスタンス化すれば選択グリッドも実アイコンになる（未整備）
- **画面ドラフトはダークモードを明示設定**: 新規frameは既定でLightに解決され白背景になることがある。アプリは常時ダーク固定なので `frame.setExplicitVariableModeForCollection(ColorCollection, DarkModeId)` を必ず設定する

## コードドリフト（design-auditor向けメモ）

- `color_getter.dart`: 収入モードのピル色が `Colors.lightBlue` ハードコード（incomeトークン未使用）。DS側は income に正規化済み

## Screen Drafts（画面ドラフト）

「Screen Drafts」ページ(`3490:4965`)に、画面フロー図(`3407:4927`)・画面一覧(`55:251`)の実機スクショとソースを正本として、確立済みコンポーネントだけで組んだ画面ドラフトを置く。命名は `Draft/<画面名>`、375×812、ダークモード明示。

| ドラフト | 主な構成部品 | 状態 |
|---|---|---|
| `Draft/全体`(YearPage) | PeriodSelector+年間収支カード(StackedBar)+ボーナスカード+ChartPlaceholder+BottomNav(全体active) | ✅ 2026-06-14 |
| `Draft/月間分析`(MonthlyPage) | AppBar+SectionHeader+ChartPlaceholder+CategorySumTile+BottomNav | ✅（既存） |
| `Draft/履歴`(ExpenseHistoryPage) | AppBar+Calendar+DateSeparator+TransactionRow×4+BottomNav(履歴active) | ✅ 2026-06-14 |
| `Draft/入力モーダル`(RegisterPage) | ヘッダー+TransactionTypePill+PriceDisplay+InputRow×3+CategorySelectButton×15+完了Button(支出色) | ✅ 2026-06-14 |
| `Draft/予算設定`(BudgetSettingPage) | AppBar(戻る)+BudgetSummaryBar+BudgetRow×7+Secondary Button+BottomNav | ✅ 2026-06-14 |

**画面フロー図の全16画面のドラフトを作成済み（2026-06-14）**。最初の5（全体/月間分析/履歴/入力モーダル/予算設定）に加え、実機golden(実データ)を正本に追加11を構築: 固定費一覧 / カテゴリ設定 / 年間収入一覧 / 月次固定費 / 日別収支サマリ / 小カテゴリ履歴 / カテゴリ別支出履歴 / ボーナス計画 / カテゴリ並替 / カテゴリ詳細編集 / 月次プラン。いずれも確立済みコンポーネント＋トークンのみで構築（命名 `Draft/<名>`・375×812・ダークモード明示）。

## Golden実描画検証（実機ウィジェット vs Figma）

`test/golden/` のGoldenハーネス（実 `ThemeData.dark`＋`AppColors`＋バンドル実フォント noto/sf でウィジェットをPNG描画）で、実装ウィジェットとFigmaを突き合わせて精度検証した（2026-06-14）。実描画で炙り出せた実質的なズレと対応:

| 対象 | 結果 / 修正 |
|---|---|
| TransactionTypePill | 実装に`border: Border.all(モード色)`あり→Figmaに枠線追加。収入色は実コードが`Colors.lightBlue`ハードコード→`context.colors.income`に修正(青→緑) |
| 履歴フラット行4種 / ListCard | 構造一致 ✅ |
| CategorySelectButton 円・状態・None | 一致 ✅。アイコンはベイク→**CategoryIconインスタンス化**しグリッドを実アイコンに修正 |
| BudgetCategoryTile | 一致 ✅。先月実績の書式を「円後置」→「¥前置」に修正 |

- iOSシミュレータは旧Flutter×iOS26で `path_provider→objective_c` のネイティブエラー＋タップ自動化不可のため、Golden方式を採用
- 制約: Material系アイコン(Icons.*)はflutter test環境でFontLoaderがハングし読込不可→golden上は豆腐□（レイアウト/色/フォント/SVG/余白/枠線は正確）。テストには `timeout: Timeout(seconds:60)` 必須

### Goldenカバレッジ（2026-06-14）

- **部品 9種**（`test/golden/component_golden_test.dart`）: TransactionTypePill / 履歴行4種 / ListCard / CategorySelectButton / BudgetRow / Button / 小物(Checkbox・Chip・FAB・SectionHeader) / Toggle / DateBox
- **フルページ 15ページ＝画面フロー図の全16画面をカバー**（`test/golden/page_golden_test.dart` + `db_harness.dart`(ffi+pathモックで実DB) + `page_harness.dart`(18リポジトリ注入) + runAsyncで実DB I/O完了）:
  - 描画OK(12): 固定費一覧 / カテゴリ設定 / 履歴 / 全体 / 月次固定費 / カテゴリ並替 / 日別収支 / カテゴリ別支出履歴 / ボーナス計画 / 小カテゴリ履歴 / 年間収入一覧 / カテゴリ詳細編集(編集モード)
  - skip(3, goldenは生成済み): 入力モーダル(金額欄autofocusのカーソルTimerで!timersPending) / MonthlyPage・MonthlyPlanHomePage(集計の並行DBクエリがsqflite ffiで完了せずTimerリーク=実装側の直列化要)
  - BudgetSettingPageは独立ページでなくMonthlyPlan内エリア（=skip側に含まれる）。CategoryDetailEditは add モードで例外、edit モード(bigCategoryId指定)なら描画OK
- **Golden由来の追加発見**: 入力グリッドは**小カテゴリ名**(コンビニ/外食/社食/消耗品/雑貨/飲み/ライブ/ご褒美/帰省/カット…)を**所属大カテゴリのアイコンでグルーピング**して表示→**Figma入力ドラフトを実機準拠に修正済(2026-06-14、15ボタンを小カテゴリ名＋大カテゴリ単位アイコンに、末尾Emptyもカテゴリボタン化)** / MonthlyPageの集計クエリにsqflite並行トランザクションのデッドロック懸念(実装側の直列化要) / Chipのgoogle_fontsドリフト(修正済)

## 次のステップ

1. ~~P1〜P3作成~~ ✅ / ~~実機擦り合わせ・実アイコン化~~ ✅ / ~~Dialog作り直し~~ ✅ / ~~リスト行・カレンダー・予算・入力系の網羅追加~~ ✅ 2026-06-13
   - ~~画面遷移図と再照合し2件修正：CategorySelectButton(Normal/Selected)の背景を縦ピル→**58×58円**化／BottomNav中央入力ボタンを円→**角丸16の角丸スクエア**化~~ ✅ 2026-06-13。TransactionRow固定費行は共有TEXTプロパティ設計のためコンポーネント側では汎用サンプルのまま（上記builderメモ参照）
   - ~~主要4タブ＋予算設定の画面ドラフトを作成~~ ✅ 2026-06-14（上記 Screen Drafts 表）
2. ~~CategorySelectButtonのアイコンをCategoryIconインスタンス化（選択グリッドを実アイコンに）~~ ✅ 2026-06-14（Goldenで差を検出し修正）。残: TransactionRow/ListCard等の行アイコンを CategoryIcon INSTANCE_SWAP プロパティ化（現状は手動swap）
3. 残りの画面ドラフト（ボーナス計画/固定費一覧/カテゴリ設定 等）／カレンダーDateBox等のGolden追加
4. C-3: confluence-reader → figma-builder の通し実行（1画面）
