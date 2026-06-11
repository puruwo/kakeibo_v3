# 色監査レポート (Color Audit) — STEP0

> ✅ **フェーズ0 完了（2026-06-11）**: 本レポートは**移行前(STEP0)のスナップショット（履歴記録）**。
> ここで棚卸しした `MyColors`・生ハードコード色・データ色は、ThemeExtension（`AppColors` / 静的 `AppColorsDark`）
> ＋ `CategoryPalette`（データ色）に全移行し、`lib/constant/colors.dart` は**削除済み**。
> 確定仕様・決定事項・移行結果・残課題は [`token-spec.md`](./token-spec.md) を参照。

> **目的**: 設計→デザイン→実装 自動化パイプライン フェーズ0（デザイントークンの単一ソース化）に向けて、
> `lib/` 配下のDartコードに存在する **色に関する値をすべて棚卸し** したもの。
> **本ドキュメントは棚卸しに徹する。** 命名の是非・統合方針・トークン設計の判断は一切含まない（それは人間の設計判断）。
>
> - 監査対象: `lib/**/*.dart`（`*.g.dart` / `*.freezed.dart` の生成ファイルは除外）
> - 抽出対象: `Color(0x...)` リテラル / `Color.fromARGB`・`Color.fromRGBO` / `Colors.xxx`（Material定数）/ `MyColors.xxx`（自前定数）/ Theme・ColorScheme経由 / 文字列で持つ16進カラー（例 `'FF7070'`）
> - 監査日: 2026-06-06
> - コードは一切変更していない（読み取りのみ）

---

## 0. サマリー

| 指標 | 件数 |
|------|------|
| 色を含むファイル数（ユニーク） | 96 |
| 中央定義 `MyColors` の定数の数 | 47個（`lib/constant/colors.dart`） |
| `MyColors.xxx` の参照箇所（定義ファイル除く） | 約400箇所 |
| 生の Material `Colors.xxx`（`MyColors`非経由） | 69箇所 / 7種 |
| `Color(0x...)` リテラル（`colors.dart`外にハードコード） | 3箇所（2種） |
| `Color.fromARGB` リテラル | 3箇所（`colors.dart`内のみ） |
| 文字列16進カラー（`color_code` シード等） | 30箇所 |

**全体の構造**:
- アプリのUI色はほぼ `MyColors`（`lib/constant/colors.dart`）に集約されており、**事実上の単一パレット層が既に存在する**。
- ただし `MyColors` の中身に **完全重複** と **ごく僅差の色** が混在している（→ 第4章）。
- 一部に `MyColors` を経由しない **生のハードコード色** が残存している（→ 1-2章）。
- カテゴリーの **データ色（`color_code`）** が、`MyColors` のパレットと **同じ16進値をDB/SQL文字列として二重に保持** している（→ 第2章）。
- アプリは `ThemeData.dark()` を強制（`lib/main.dart:116-128`）。Material標準ダークの色は明示リテラルではないため本監査の表からは除外（AppBarのelevation等のみ上書き）。

---

# A. UIクローム色（ボタン・背景・テキスト・区切り線・影 等）

## 1-1. 中央定義パレット `MyColors`（`lib/constant/colors.dart`）

すべて `lib/constant/colors.dart` に定義。`値` は解決後の実色（`#RRGGBB` と不透明度%）。`参照回数` は定義ファイルを除くアプリ内での `MyColors.<名前>` 出現回数。

### ブランド / テーマ色

| 定数名 | リテラル | 解決値 | 定義 | 参照回数 |
|--------|---------|--------|------|---------|
| `themeColor` | `Color.fromARGB(255, 11, 178, 131)` | `#0BB283` / 100% | `colors.dart:4` | 28 |
| `themeThinColor` | `Color(0xFFD7FFF4)` | `#D7FFF4` / 100% | `colors.dart:5` | 1 |
| `themeSecondaryColor` | `Color.fromARGB(255, 63, 200, 161)` | `#3FC8A1` / 100% | `colors.dart:6` | 0 |
| `blackmint` | `Color.fromARGB(255, 11, 178, 131)` | `#0BB283` / 100% | `colors.dart:13` | 0 |
| `buttonPrimary` | `= themeColor` | `#0BB283` / 100% | `colors.dart:94` | 1 |
| `buttonSecondary` | `= systemfill` | `#787880` / 36% | `colors.dart:95` | 3 |

### 基本色 / エイリアス

| 定数名 | リテラル | 解決値 | 定義 | 参照回数 |
|--------|---------|--------|------|---------|
| `transparent` | `Colors.transparent` | `#000000` / 0% | `colors.dart:8` | 7 |
| `white` | `Colors.white` | `#FFFFFF` / 100% | `colors.dart:10` | 50 |
| `black` | `Colors.black` | `#000000` / 100% | `colors.dart:11` | 5 |
| `pink` | `Color(0xFFFF7171)` | `#FF7171` / 100% | `colors.dart:40` | 21 |
| `mintBlue` | `Color(0xFF36C5F1)` | `#36C5F1` / 100% | `colors.dart:41` | 3 |
| `linkColor` | `Color(0xff0a84ff)` | `#0A84FF` / 100% | `colors.dart:67` | 0 |

### グレースケール / 黒系

| 定数名 | リテラル | 解決値 | 定義 | 参照回数 |
|--------|---------|--------|------|---------|
| `lightGray` | `Color(0xFFF6F6F6)` | `#F6F6F6` / 100% | `colors.dart:14` | 0 |
| `dimGray` | `Color(0xFF6A706E)` | `#6A706E` / 100% | `colors.dart:15` | 0 |
| `jet` | `Color(0xFF3F3D3D)` | `#3F3D3D` / 100% | `colors.dart:16` | 8 |
| `eerieBlack` | `Color(0xFF1E1E1E)` | `#1E1E1E` / 100% | `colors.dart:17` | 0 |
| `richBlack` | `Color(0xFF051014)` | `#051014` / 100% | `colors.dart:18` | 0 |

### iOS風 systemGray / 背景

| 定数名 | リテラル | 解決値 | 定義 | 参照回数 |
|--------|---------|--------|------|---------|
| `systemGray` | `Color(0xff8E8E93)` | `#8E8E93` / 100% | `colors.dart:55` | 7 |
| `systemGray2` | `Color(0xff636366)` | `#636366` / 100% | `colors.dart:56` | 5 |
| `systemGray3` | `Color(0xff48484a)` | `#48484A` / 100% | `colors.dart:57` | 0 |
| `systemGray4` | `Color(0xff3a3a3c)` | `#3A3A3C` / 100% | `colors.dart:58` | 3 |
| `systemGray5` | `Color(0xff2c2c2c)` | `#2C2C2C` / 100% | `colors.dart:59` | 1 |
| `systemGray6` | `Color(0xff1c1c1e)` | `#1C1C1E` / 100% | `colors.dart:60` | 0 |
| `systemBackground` | `Color(0xff000000)` | `#000000` / 100% | `colors.dart:62` | 2 |
| `secondarySystemBackground` | `Color(0xff1c1c1e)` | `#1C1C1E` / 100% | `colors.dart:63` | 19 |
| `tirtiarySystemBackground` | `Color(0xff2c2c2e)` | `#2C2C2E` / 100% | `colors.dart:64` | 4 |
| `tertiarySystemBackground` | `Color(0xff2c2c2e)` | `#2C2C2E` / 100% | `colors.dart:65` | 3 |

> `colors.dart:65` には `// typo修正版` のコメントあり（`tirtiary` の綴り誤りを `tertiary` で再定義した経緯）。両者は同一値。

### 半透明フィル（systemFill 系）

| 定数名 | リテラル | 解決値 | 定義 | 参照回数 |
|--------|---------|--------|------|---------|
| `systemfill` | `Color(0x5b787880)` | `#787880` / 36% | `colors.dart:49` | 3 |
| `secondarySystemfill` | `Color(0x51787880)` | `#787880` / 32% | `colors.dart:50` | 16 |
| `tirtiarySystemfill` | `Color(0x3d767680)` | `#767680` / 24% | `colors.dart:51` | 17 |
| `quarternarySystemfill` | `Color(0x39767680)` | `#767680` / 22% | `colors.dart:52` | 15 |
| `quarternarySystemfillOpaque` | `Color(0xFF2c2c30)` | `#2C2C30` / 100% | `colors.dart:53` | 4 |
| `separater` | `Color(0x99545458)` | `#545458` / 60% | `colors.dart:69` | 41 |
| `hoverColor` | `Color(0x33000000)` | `#000000` / 20% | `colors.dart:74` | 1 |
| `barHandler` | `Color(0xFFD9D9D9)` | `#D9D9D9` / 100% | `colors.dart:71` | 1 |

### ラベル（白系・不透明度違い）

| 定数名 | リテラル | 解決値 | 定義 | 参照回数 |
|--------|---------|--------|------|---------|
| `label` | `Color(0xffffffff)` | `#FFFFFF` / 100% | `colors.dart:43` | 25 |
| `secondaryLabel` | `Color(0x99ebebf5)` | `#EBEBF5` / 60% | `colors.dart:44` | 44 |
| `tirtiaryLabel` | `Color(0x4cebebf5)` | `#EBEBF5` / 30% | `colors.dart:45` | 2 |
| `quarternaryLabel` | `Color(0x2debebf5)` | `#EBEBF5` / 18% | `colors.dart:46` | 0 |

### カテゴリーカラー（パレットとして定数化されているが、用途はデータ寄り → 第2章も参照）

| 定数名 | リテラル | 解決値 | 定義 | 参照回数 |
|--------|---------|--------|------|---------|
| `expenseRed` | `Color(0xFFDF2828)` | `#DF2828` / 100% | `colors.dart:21` | 1 |
| `expensePink` | `Color(0xFFFF7171)` | `#FF7171` / 100% | `colors.dart:22` | 3 |
| `expenseBlue` | `Color(0xFF4BA6FF)` | `#4BA6FF` / 100% | `colors.dart:23` | 1 |
| `expenseMint` | `Color(0xFF3DD8E0)` | `#3DD8E0` / 100% | `colors.dart:24` | 1 |
| `expenseYellow` | `Color(0xFFFFC700)` | `#FFC700` / 100% | `colors.dart:25` | 1 |
| `expenseGiantsOrange` | `Color(0xFFFB5B01)` | `#FB5B01` / 100% | `colors.dart:26` | 1 |
| `expensePurple` | `Color(0xFFBB87FF)` | `#BB87FF` / 100% | `colors.dart:27` | 1 |
| `expenseBrown` | `Color(0xFFAC3E00)` | `#AC3E00` / 100% | `colors.dart:28` | 1 |
| `incomeEmerald` | `Color(0xFF21D19F)` | `#21D19F` / 100% | `colors.dart:31` | 8 |
| `incomeGreen` | `Color(0xFF10B981)` | `#10B981` / 100% | `colors.dart:32` | 2 |
| `incomeDeepGreen` | `Color(0xFF059669)` | `#059669` / 100% | `colors.dart:33` | 1 |
| `incomeMintGreen` | `Color(0xFF6EE7B7)` | `#6EE7B7` / 100% | `colors.dart:34` | 1 |
| `fixedCostGray` | `Color(0xFF8E8E93)` | `#8E8E93` / 100% | `colors.dart:37` | 2 |

> カテゴリーカラーは `lib/view/category_edit_page/.../color_select_dialog.dart:29-45` のカラーパレット（支出8色 / 収入4色）として `MyColors` 定数を直接参照。

---

## 1-2. `MyColors` を経由しない生のハードコード色

トークン化（単一ソース化）の観点で **ドリフト要注意箇所**。`colors.dart` 内のエイリアス定義は除く。

### `Color(0x...)` リテラルのハードコード（`colors.dart`・`fixed_cost_constants.dart`以外）

| リテラル値 | 出現箇所（file:line） | 回数 |
|-----------|---------------------|------|
| `Color(0xFF2C2C2E)` | `lib/view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart:32`<br>`lib/view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_tooltip.dart:35`（コメント「ダークグレー背景」） | 2 |

> 補足: `lib/constant/fixed_cost_constants.dart:22` に `Color(0xFF8E8E93)`（`FixedCostColors.colorList`、コメント「MatBlue統一」）。これは定数クラス内だが `MyColors.fixedCostGray`(`#8E8E93`) と同値の別定義。

### 生の Material `Colors.xxx`（`MyColors`非経由）

| リテラル値 | 出現箇所（file:line） | 回数 |
|-----------|---------------------|------|
| `Colors.transparent` | `util/common_widget/checkable_popup_menu_item.dart:51`<br>`util/common_widget/app_dialog.dart:37,82,143`<br>`util/common_widget/inkwell_util.dart:24,29`<br>`view/config/config_top.dart:19`<br>`view/daily_expense_summary_page/daily_expense_summary_page.dart:31`<br>`view/register_page/register_page_base.dart:139`<br>`view/register_page/fixed_cost_tab/price_input_area/price_type_switch_area.dart:56`<br>`view/register_page/category_area/category_reorder_page.dart:219,354`<br>`view/component/app_year_month_picker.dart:357,498,520`<br>`view/component/app_floating_action_button.dart:42`<br>`view/component/check_box.dart:31`<br>`view/category_edit_page/category_setting_page.dart:59`<br>`view/category_edit_page/.../expense_category_detail_edit_page/category_detail_edit_page.dart:60`<br>`view/category_edit_page/.../expense_category_detail_edit_page/add_complete_big_category_detail_button.dart:67`<br>`view/category_edit_page/.../income_category_detail_edit_page/add_complete_button/add_complete_income_category_detail_button.dart:64`<br>`view/year_page/year_page.dart:85`<br>`view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart:24`<br>`view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart:72`<br>`view/monthly_page/monthly_page.dart:91`<br>`view/monthly_page/category_tile/all_no_budget_type_category_sum_tile.dart:49,50`<br>`view/monthly_page/category_tile/category_sum_tile.dart:45,46`<br>`view/monthly_page/category_tile/big_category_expense_history_page/expanded_category_sum_tile.dart:39,40`<br>`view/monthly_page/category_tile/big_category_expense_history_page/category_expense_hisotry_page.dart:16`<br>`view/monthly_page/category_tile/big_category_expense_history_page/small_category_expanded_history_page/small_category_expanded_history_page.dart:17`<br>`view/monthly_page/monthly_plan_area/.../monthly_plan_graph_area/monthly_plan_graph_parts.dart:64`<br>`view/monthly_page/monthly_plan_area/.../monthly_income_graph_area/monthly_income_graph_parts.dart:67`<br>`view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart:18`<br>`view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/monthly_fixed_cost_page.dart:20`<br>`view/yearly_income_list_page/yearly_income_list_page.dart:37`<br>`view/historical_calendar_page/expense_history_page.dart:20` | 40 |
| `Colors.white` | `view/register_page/fixed_cost_tab/price_input_area/price_type_switch_area.dart:66`（コメント「トグルの丸の色」）<br>`view/component/app_floating_action_button.dart:33`<br>`view/category_edit_page/.../dialog/color_select_dialog.dart:137`<br>`view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart:27,33`<br>`view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart:345`<br>`view/monthly_page/monthly_plan_area/.../monthly_plan_graph_area/monthly_plan_graph_parts.dart:62,63`<br>`view/monthly_page/monthly_plan_area/.../monthly_income_graph_area/monthly_income_graph_parts.dart:65,66`<br>`view/yearly_income_list_page/yearly_income_list_page.dart:40` | 12 |
| `Colors.black` | `util/common_widget/checkable_popup_menu_item.dart:52`（`.withOpacity(0.1)`）<br>`util/common_widget/inkwell_util.dart:30`（`.withOpacity(0.1)`）<br>`view/component/app_year_month_picker.dart:364`（`.withValues(alpha:0.75)`）<br>`view/component/app_floating_action_button.dart:43`（`.withValues(alpha:0.1)`）<br>`view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart:36`（`.withValues(alpha:0.3)`）<br>`view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_tooltip.dart:39`（`.withOpacity(0.3)`） | 7 |
| `Colors.black26` | `view/component/loading.dart:6`<br>`view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart:131`<br>`view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/fixed_cost_summary_header.dart:56,75` | 4 |
| `Colors.white24` | `view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart:48`<br>`view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_tooltip.dart:78`<br>`view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_category_summary_list.dart:28` | 3 |
| `Colors.lightBlue` | `view/register_page/common_input_field/const_getter.dart/color_getter.dart:10`<br>`view/register_page/common_input_field/const_getter.dart/color_getter.dart:18`（`.withOpacity(0.1)`） | 2 |
| `Colors.blue` | `view/register_page/category_area/category_reorder_page.dart:279`（`disabledButtonColor`） | 1 |

---

## 1-3. 不透明度・グラデーションを伴う派生使用

ベース色に `.withOpacity()` / `.withValues(alpha:)` を掛けて使っている箇所（=実効的に新しい色値が生成される箇所）。第1-1/1-2の回数に内包される。

### `.withOpacity(...)`

| ベース色 | alpha | 出現箇所（file:line） |
|---------|-------|---------------------|
| `Colors.black` | 0.1 | `util/common_widget/inkwell_util.dart:30`, `util/common_widget/checkable_popup_menu_item.dart:52` |
| `Colors.black` | 0.3 | `view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_tooltip.dart:39` |
| `MyColors.secondarySystemBackground` | 0.7 | `view/foundation.dart:139`, `view/component/glass_app_bar_background.dart:16` |
| `MyColors.pink` | 0.1 | `view/register_page/common_input_field/const_getter.dart/color_getter.dart:17,19` |
| `Colors.lightBlue` | 0.1 | `view/register_page/common_input_field/const_getter.dart/color_getter.dart:18` |
| `MyColors.jet` | 0.0 | `income_category_appearance_edit_area.dart:185,191`, `cotegory_appearance_edit_area.dart:214,221`, `fixed_cost_category_appearance_edit_area.dart:193,199`, `budget_category_tile.dart:223,230` |
| `MyColors.tirtiarySystemfill` | 0.5 / 0.4 / 0.3 | `monthly_plan_skeleton.dart:44,53,62,74,86,95,104,116`, `history_list_skeleton.dart:60,97,111,120,133` |

### `.withValues(alpha:...)`（新API）

| ベース色 | alpha | 出現箇所（file:line） |
|---------|-------|---------------------|
| `Colors.black` | 0.75 | `view/component/app_year_month_picker.dart:364` |
| `Colors.black` | 0.3 | `view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart:36` |
| `Colors.black` | 0.1 | `view/component/app_floating_action_button.dart:43` |
| `MyColors.systemGray4` | 0.6 | `view/component/app_year_month_picker.dart:538` |
| `MyColors.quarternarySystemfillOpaque` | 0.0 | `view/year_page/annual_balance_chart/annual_balance_chart.dart:158` |

### グラデーション（`LinearGradient`）

| 出現箇所（file:line） | 構成色 |
|---------------------|--------|
| `view/year_page/annual_balance_chart/annual_balance_chart.dart:151-160` | `quarternarySystemfillOpaque` ×2 → `quarternarySystemfillOpaque.withValues(alpha:0.0)`（stops 0.0/0.6/1.0） |
| `view/monthly_page/monthly_plan_area/.../monthly_plan_graph_area/monthly_plan_graph_parts.dart:58-67` | `Colors.white` ×2 → `Colors.transparent`（ShaderMask, stops 0.0/0.85/1.0） |
| `view/monthly_page/monthly_plan_area/.../monthly_income_graph_area/monthly_income_graph_parts.dart:61-67` | `Colors.white` ×2 → `Colors.transparent`（ShaderMask） |

---

# B. データとしての色（カテゴリー `color_code` 等）

UIクロームではなく、**DBに保存され実行時に色へ変換される文字列値**（`#`なし6桁HEX）。
変換は `MyColors.getColorFromHex(String colorCode)`（`colors.dart:76-79`、`'FF$colorCode'` を `Color` 化）で行う。

## 2-1. 初期データ（`lib/model/sql_on_create.dart`）

### 支出大カテゴリー `expense_big_category`（`sql_on_create.dart:106-112`）

| 色コード | 解決値 | カテゴリー | file:line | 同値の `MyColors` |
|---------|--------|-----------|-----------|------------------|
| `FF7171` | `#FF7171` | 食費 | `sql_on_create.dart:106` | `pink` / `expensePink` |
| `FB5B01` | `#FB5B01` | 日用品 | `sql_on_create.dart:107` | `expenseGiantsOrange` |
| `3DD8E0` | `#3DD8E0` | 遊び娯楽 | `sql_on_create.dart:108` | `expenseMint` |
| `4BA6FF` | `#4BA6FF` | 交通費 | `sql_on_create.dart:109` | `expenseBlue` |
| `BB87FF` | `#BB87FF` | 衣服美容 | `sql_on_create.dart:110` | `expensePurple` |
| `DF2828` | `#DF2828` | 医療費 | `sql_on_create.dart:111` | `expenseRed` |
| `FFC700` | `#FFC700` | 雑費 | `sql_on_create.dart:112` | `expenseYellow` |

### 収入大カテゴリー `income_big_category`（`sql_on_create.dart:154-155`）

| 色コード | 解決値 | カテゴリー | file:line | 同値の `MyColors` |
|---------|--------|-----------|-----------|------------------|
| `21D19F` | `#21D19F` | 月次収入 | `sql_on_create.dart:154` | `incomeEmerald` |
| `10B981` | `#10B981` | ボーナス | `sql_on_create.dart:155` | `incomeGreen` |

### 固定費カテゴリー `fixed_cost_category`（`sql_on_create.dart:245-249`）

| 色コード | 解決値 | カテゴリー | file:line | 同値の `MyColors` |
|---------|--------|-----------|-----------|------------------|
| `8E8E93` | `#8E8E93` | 住居費 | `sql_on_create.dart:245` | `systemGray` / `fixedCostGray` |
| `8E8E93` | `#8E8E93` | サブスク | `sql_on_create.dart:246` | 〃 |
| `8E8E93` | `#8E8E93` | 通信費 | `sql_on_create.dart:247` | 〃 |
| `8E8E93` | `#8E8E93` | 光熱費 | `sql_on_create.dart:248` | 〃 |
| `8E8E93` | `#8E8E93` | その他 | `sql_on_create.dart:249` | 〃 |

## 2-2. マイグレーション内の色（`lib/model/sql_on_update.dart`）

### 固定費カテゴリー初期投入（`sql_on_update.dart:94-98`）— ※後続の更新で `8E8E93` に上書きされる中間値

| 色コード | 解決値 | カテゴリー | file:line |
|---------|--------|-----------|-----------|
| `FF5722` | `#FF5722` | 住居費 | `sql_on_update.dart:94` |
| `2196F3` | `#2196F3` | 通信費 | `sql_on_update.dart:95` |
| `9C27B0` | `#9C27B0` | サブスク | `sql_on_update.dart:96` |
| `FFC107` | `#FFC107` | 光熱費 | `sql_on_update.dart:97` |
| `607D8B` | `#607D8B` | その他 | `sql_on_update.dart:98` |

### 既存データの色コード再設定 UPDATE 文（`sql_on_update.dart:164-177`）

| 色コード | 解決値 | 対象 | file:line |
|---------|--------|------|-----------|
| `FF7171` | `#FF7171` | 支出 食費(id=1) | `sql_on_update.dart:164` |
| `FB5B01` | `#FB5B01` | 支出 日用品(id=2) | `sql_on_update.dart:165` |
| `3DD8E0` | `#3DD8E0` | 支出 遊び娯楽(id=3) | `sql_on_update.dart:166` |
| `4BA6FF` | `#4BA6FF` | 支出 交通費(id=4) | `sql_on_update.dart:167` |
| `BB87FF` | `#BB87FF` | 支出 衣服美容(id=5) | `sql_on_update.dart:168` |
| `DF2828` | `#DF2828` | 支出 医療費(id=6) | `sql_on_update.dart:169` |
| `FFC700` | `#FFC700` | 支出 雑費(id=7) | `sql_on_update.dart:170` |
| `8E8E93` | `#8E8E93` | 固定費 全カテゴリー | `sql_on_update.dart:173` |
| `21D19F` | `#21D19F` | 収入 月次収入(id=1) | `sql_on_update.dart:176` |
| `10B981` | `#10B981` | 収入 ボーナス(id=2) | `sql_on_update.dart:177` |

## 2-3. データ色のフォールバック / 空値

| 内容 | file:line |
|------|-----------|
| `colorCode: ''`（空文字フォールバック） | `repository/income_big_category_repository.dart:38,72`<br>`repository/expense_big_category_repository.dart:66`<br>`view_model/state/register_page/select_category_controller/select_category_controller.dart:19` |
| `MyColors().getHexFromColor(MyColors.fixedCostGray)`（固定費グレーをHEX文字列化してデータ色に注入） | `application/prediction_graph/prediction_graph_data_source.dart:245,258` |

---

# C. ほぼ同じ・完全重複の色（統合候補の棚卸し）

> ※ どれを残すか・どう統合するかの判断はしない。値が同一/僅差である事実のみを列挙する。

## 4-1. 完全重複（同一の解決値が別名/別箇所に存在）

| 解決値 | 重複している定義・箇所 |
|--------|----------------------|
| `#0BB283` (100%) | `MyColors.themeColor`(`colors.dart:4`) ＝ `MyColors.blackmint`(`colors.dart:13`) ＝ `MyColors.buttonPrimary`(`colors.dart:94`) |
| `#FF7171` (100%) | `MyColors.pink`(`colors.dart:40`) ＝ `MyColors.expensePink`(`colors.dart:22`) ＝ データ色 `FF7171`（食費, `sql_on_create.dart:106` / `sql_on_update.dart:164`） |
| `#8E8E93` (100%) | `MyColors.systemGray`(`colors.dart:55`) ＝ `MyColors.fixedCostGray`(`colors.dart:37`) ＝ `FixedCostColors.colorList[0]`(`fixed_cost_constants.dart:22`) ＝ 固定費データ色 `8E8E93`（`sql_on_create.dart:245-249` / `sql_on_update.dart:173`） |
| `#1C1C1E` (100%) | `MyColors.systemGray6`(`colors.dart:60`) ＝ `MyColors.secondarySystemBackground`(`colors.dart:63`) |
| `#2C2C2E` (100%) | `MyColors.tirtiarySystemBackground`(`colors.dart:64`) ＝ `MyColors.tertiarySystemBackground`(`colors.dart:65`, typo修正版) ＝ ハードコード `Color(0xFF2C2C2E)`（`annual_balance_tooltip.dart:32` / `prediction_graph_tooltip.dart:35`） |
| `#FFFFFF` (100%) | `MyColors.white`(`= Colors.white`, `colors.dart:10`) ＝ `MyColors.label`(`Color(0xffffffff)`, `colors.dart:43`) ＝ 生 `Colors.white`（12箇所, 1-2章） |
| `#000000` (100%) | `MyColors.black`(`= Colors.black`, `colors.dart:11`) ＝ `MyColors.systemBackground`(`Color(0xff000000)`, `colors.dart:62`) |
| `#000000` (0%) | `MyColors.transparent`(`= Colors.transparent`, `colors.dart:8`) ＝ 生 `Colors.transparent`（40箇所, 1-2章） |
| 支出/収入カテゴリーパレット | `MyColors.expense*`/`income*` 定数群（`colors.dart:21-34`） と データ色 `color_code`（`sql_on_create.dart` / `sql_on_update.dart`）が **同一HEX値を二重保持**（対応は第2章の表を参照） |

## 4-2. 僅差（数値が近く視覚的に判別困難なグループ）

| グループ | 色 | 差分 |
|---------|-----|------|
| ダークグレー背景 `#2C2C2x` | `#2C2C2C`(`systemGray5`) / `#2C2C2E`(`tirtiary/tertiarySystemBackground`+ハードコード) / `#2C2C30`(`quarternarySystemfillOpaque`) | 下位バイトのみ `2C`/`2E`/`30` の差 |
| 黒に近いグレー `#1x1x1x` | `#1C1C1E`(`systemGray6`/`secondarySystemBackground`) / `#1E1E1E`(`eerieBlack`) | R/G/Bが各2前後の差 |
| systemFill ベース | `#787880`（`systemfill` 36% / `secondarySystemfill` 32%）/ `#767680`（`tirtiarySystemfill` 24% / `quarternarySystemfill` 22%） | ベースRGBが `78/78/80` vs `76/76/80`、加えてalphaが4段階 |
| ラベル白系 | `#FFFFFF` 100%(`label`) / `#EBEBF5` 60%(`secondaryLabel`) / 30%(`tirtiaryLabel`) / 18%(`quarternaryLabel`) | 同一ベース`#EBEBF5`のalpha違い（最上位のみ純白） |
| 緑（ブランド/収入） | `#0BB283`(`themeColor`) / `#3FC8A1`(`themeSecondaryColor`) / `#21D19F`(`incomeEmerald`) / `#10B981`(`incomeGreen`) / `#059669`(`incomeDeepGreen`) / `#6EE7B7`(`incomeMintGreen`) | いずれもティール〜グリーン系の近接色 |
| 赤/ピンク | `#FF7171`(`pink`/`expensePink`) / `#DF2828`(`expenseRed`) | 明度・彩度違いの赤系 |
| 青 | `#4BA6FF`(`expenseBlue`) / `#0A84FF`(`linkColor`) / `#36C5F1`(`mintBlue`) / `#03A9F4`(`Colors.lightBlue`) / `#2196F3`(`Colors.blue` ＝ 旧固定費データ色 `2196F3`) | 青〜水色系の近接色 |
| ジェット系暗グレー | `#3F3D3D`(`jet`) / `#3A3A3C`(`systemGray4`) / `#48484A`(`systemGray3`) | 暗いニュートラルグレーの近接 |
| 半透明黒（オーバーレイ/ホバー） | `#000000` 20%(`hoverColor`) / 10%(`Colors.black.withOpacity/withValues 0.1`) / 30%(0.3) / 75%(0.75) | 同一黒のalpha違いが各所に分散 |

---

# 付録: 補足メモ

- `getColorFromHex` / `getColorCodeFromColor` / `getHexFromColor`（`colors.dart:76-91`）がDB文字列⇄`Color`の相互変換を担う。データ色とUI色の橋渡し点。
- テーマ系で参照0回の定数: `themeSecondaryColor`, `blackmint`, `linkColor`, `lightGray`, `dimGray`, `eerieBlack`, `richBlack`, `systemGray3`, `systemGray6`, `quarternaryLabel`（＝定義のみで未使用）。
- `Theme.of(context)` / `ColorScheme` の参照はあるが、いずれも `copyWith` での部分上書き（`outline: Colors.transparent` 等）に留まり、色の発生源は上記リテラル/定数。アプリ全体は `ThemeData.dark()` 固定（`main.dart:116-128`）。
- 本章末の「全参照インデックス」に、`MyColors.*` の全出現箇所（file:line）を機械生成で添付する。

---

## 付録A: `MyColors.*` 全参照インデックス（自動生成 / file:line）

> `grep -rEn "MyColors\.<name>" lib`（生成ファイル・定義ファイル除く）の結果をそのまま掲載。

### `MyColors.white`（49箇所）

```
constant/icon.dart:9:    color: MyColors.white,
util/common_widget/app_delete_dialog.dart:122:                color: isPrimary ? MyColors.white : MyColors.white,
constant/styles/app_text_styles.dart:15:    color: MyColors.white,
constant/styles/app_text_styles.dart:34:    color: MyColors.white,
constant/styles/app_text_styles.dart:41:    color: MyColors.white,
constant/styles/app_text_styles.dart:48:    color: MyColors.white,
constant/styles/app_text_styles.dart:171:    color: MyColors.white,
constant/styles/app_text_styles.dart:335:    color: MyColors.white,
constant/styles/app_text_styles.dart:345:        color: MyColors.white,
constant/styles/app_text_styles.dart:352:    color: MyColors.white,
constant/styles/app_text_styles.dart:387:        color: MyColors.white,
constant/styles/app_text_styles.dart:403:    color: MyColors.white,
constant/styles/app_text_styles.dart:440:    color: MyColors.white,
constant/styles/calendar_styles.dart:22:    color: MyColors.white,
constant/styles/calendar_styles.dart:35:    color: MyColors.white,
constant/styles/register_page_styles.dart:86:    color: MyColors.white,
constant/styles/register_page_styles.dart:150:    color: MyColors.white,
view/foundation.dart:179:              color: isSelected ? MyColors.white : MyColors.secondaryLabel,
view/foundation.dart:210:              color: MyColors.white,
view/register_page/register_page_base.dart:156:              color: MyColors.white,
view/register_page/register_page_base.dart:167:                      color: MyColors.white,
view/register_page/category_area/category_reorder_page.dart:224:          icon: const Icon(Icons.close, color: MyColors.white),
view/component/app_year_month_picker.dart:413:                  ? MyColors.white
view/component/app_year_month_picker.dart:438:                  ? MyColors.white
view/component/app_year_month_picker.dart:571:                const Icon(Icons.check, color: MyColors.white, size: 18),
view/category_edit_page/category_setting_page.dart:80:            icon: const Icon(Icons.close, color: MyColors.white),
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/category_detail_edit_page.dart:86:              color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/add_complete_big_category_detail_button.dart:38:          color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/add_complete_button/add_complete_income_category_detail_button.dart:37:        color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/income_category_appearance_edit_area.dart:176:                                color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/update_complete_button/update_complete_income_category_detail_button.dart:39:              color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/update_complete_button/update_complete_income_category_detail_button.dart:49:                      style: TextStyle(color: MyColors.white),
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/update_complete_button/update_complete_income_category_detail_button.dart:53:                      style: TextStyle(color: MyColors.white),
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/update_complete_button/update_complete_income_category_detail_button.dart:111:            color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/cotegory_appearance_edit_area.dart:202:                                color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/add_complete_button/add_complete_fixed_cost_category_detail_button.dart:34:        color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/fixed_cost_category_appearance_edit_area.dart:184:                                color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/update_complete_button/update_complete_fixed_cost_category_detail_button.dart:33:        color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/update_complete_button/update_complete_big_category_detail_button.dart:34:          color: MyColors.white,
view/category_edit_page/big_category_detail_edit_page/dialog/icon_select_dialog.dart:129:                .iconWidget(url, MyColors.white, width: 15, height: 15),
view/category_edit_page/big_category_detail_edit_page/dialog/icon_select_dialog.dart:139:                .iconWidget(url, MyColors.white, width: 15, height: 15),
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:186:                                          color: MyColors.white,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:416:                                          color: MyColors.white,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:629:                                          color: MyColors.white,
view/monthly_page/monthly_page.dart:294:                                  MyColors.white,
view/historical_calendar_page/calendar_previous_arrow_button.dart:21:      color: MyColors.white,
view/historical_calendar_page/calendar_next_arrow_button.dart:19:      color: MyColors.white,
view/budget_setting_page/submit_budget_button.dart:91:          color: MyColors.white,
view/budget_setting_page/submit_budget_button.dart:98:          color: MyColors.white,
```

### `MyColors.secondaryLabel`（44箇所）

```
constant/styles/register_page_styles.dart:38:    color: MyColors.secondaryLabel,
constant/styles/register_page_styles.dart:99:    color: MyColors.secondaryLabel,
constant/styles/register_page_styles.dart:160:    color: MyColors.secondaryLabel,
constant/styles/register_page_styles.dart:201:    color: MyColors.secondaryLabel,
constant/styles/register_page_styles.dart:211:        color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:22:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:76:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:113:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:129:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:141:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:189:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:196:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:214:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:221:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:235:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:264:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:271:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:296:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:328:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:362:        color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:369:    color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:377:        color: MyColors.secondaryLabel,
constant/styles/app_text_styles.dart:447:    color: MyColors.secondaryLabel,
constant/styles/calendar_styles.dart:52:    color: MyColors.secondaryLabel,
constant/styles/calendar_styles.dart:57:  //   color: MyColors.secondaryLabel,
constant/styles/calendar_styles.dart:99:    color: MyColors.secondaryLabel,
constant/styles/graph_text_styles.dart:14:      color: MyColors.secondaryLabel,
constant/styles/graph_text_styles.dart:20:      color: MyColors.secondaryLabel,
constant/styles/graph_text_styles.dart:26:      color: MyColors.secondaryLabel,
constant/styles/graph_text_styles.dart:57:    color: MyColors.secondaryLabel,
view/foundation.dart:179:              color: isSelected ? MyColors.white : MyColors.secondaryLabel,
view/register_page/common_input_field/budget_row.dart:98:                  color: MyColors.secondaryLabel,
view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_picker.dart:76:                  color: MyColors.secondaryLabel,
view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_picker.dart:102:                  color: MyColors.secondaryLabel,
view/register_page/category_area/category_area.dart:193:              color: MyColors.secondaryLabel,
view/component/app_year_month_picker.dart:414:                  : MyColors.secondaryLabel,
view/component/app_year_month_picker.dart:439:                  : MyColors.secondaryLabel,
view/year_page/fixed_cost_button_area/fixed_cost_button_area.dart:88:                    color: MyColors.secondaryLabel,
view/year_page/fixed_cost_button_area/fixed_cost_button_area.dart:124:          color: MyColors.secondaryLabel,
view/year_page/fixed_cost_button_area/fixed_cost_button_area.dart:150:              color: MyColors.secondaryLabel,
view/year_page/bonus_plan_area/bonus_register_prompt_area.dart:34:              color: MyColors.secondaryLabel,
view/year_page/yearly_balance_area/yearly_balance_area.dart:61:                        color: MyColors.secondaryLabel,
view/year_page/yearly_balance_area/yearly_balance_area.dart:215:                                color: MyColors.secondaryLabel,
view/monthly_page/monthly_plan_area/monthly_plan_register_prompt_area.dart:27:              color: MyColors.secondaryLabel,
```

### `MyColors.separater`（41箇所）

```
util/common_widget/app_dialog.dart:65:                        color: MyColors.separater,
view/foundation.dart:132:            top: BorderSide(color: MyColors.separater, width: 0.5),
view/register_page/category_area/category_area.dart:165:                : MyColors.separater,
view/register_page/category_area/category_reorder_page.dart:433:                : MyColors.separater,
view/category_edit_page/big_category_detail_edit_page/small_category_edit_area.dart:161:            color: MyColors.separater,
view/category_edit_page/big_category_detail_edit_page/small_category_edit_area.dart:342:                        color: MyColors.separater,
view/category_edit_page/big_category_detail_edit_page/small_category_edit_area.dart:392:                            color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:99:                  color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:200:                                color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:255:                                  color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:328:                  color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:430:                                color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:487:                                  color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:555:                  color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:643:                                color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_list_area.dart:699:                                  color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_edit_area.dart:142:          color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_edit_area.dart:266:                    color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_edit_area.dart:321:          color: MyColors.separater,
view/category_edit_page/big_category_setting_page/big_category_edit_area.dart:425:                    color: MyColors.separater,
view/year_page/bonus_plan_area/bonus_plan_area.dart:61:                      color: MyColors.separater,
view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart:170:      ..color = MyColors.separater
view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart:260:      ..color = MyColors.separater
view/year_page/yearly_balance_area/yearly_balance_area.dart:254:                          color: MyColors.separater,
view/monthly_page/category_tile/big_category_expense_history_page/expanded_category_sum_tile.dart:89:                    color: MyColors.separater,
view/monthly_page/category_tile/big_category_expense_history_page/category_expence_history_list_area.dart:127:                      color: MyColors.separater,
view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_painter.dart:234:      ..color = MyColors.separater
view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_painter.dart:496:      ..color = MyColors.separater
view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_painter.dart:599:      ..color = MyColors.separater
view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_painter.dart:622:      ..color = MyColors.separater
view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_painter.dart:828:        ..color = MyColors.separater
view/historical_calendar_page/calendar_area/calendar_area.dart:143:                        color: MyColors.separater,
view/historical_calendar_page/calendar_area/calendar_area.dart:164:                              color: MyColors.separater,
view/historical_calendar_page/expense_history_area/history_list_skeleton.dart:73:                  color: MyColors.separater,
view/historical_calendar_page/expense_history_area/expence_history_list_area.dart:108:                        color: MyColors.separater,
view/historical_calendar_page/expense_history_area/tiles/confirmed_fixed_cost_item_tile.dart:141:            color: MyColors.separater,
view/historical_calendar_page/expense_history_area/tiles/unconfirmed_fixed_cost_item_tile.dart:145:              color: MyColors.separater,
view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart:183:              color: MyColors.separater,
view/historical_calendar_page/expense_history_area/tiles/income_item_tile.dart:176:              color: MyColors.separater,
view/budget_setting_page/budget_cotegory_area.dart:62:          color: MyColors.separater,
view/budget_setting_page/budget_category_tile.dart:301:              color: MyColors.separater,
```

### `MyColors.themeColor`（28箇所）

```
util/common_widget/app_delete_dialog.dart:111:      color: isPrimary ? MyColors.themeColor : MyColors.systemGray4,
util/common_widget/price_input_dialog.dart:76:              cursorColor: MyColors.themeColor,
util/common_widget/checkable_popup_menu_item.dart:98:                  color: selectedColor ?? MyColors.themeColor, size: 20)
util/common_widget/checkable_popup_menu_item.dart:132:                    color: selectedColor ?? MyColors.themeColor, size: 20)
util/common_widget/app_dialog.dart:158:                color: item.iconColor ?? MyColors.themeColor,
constant/styles/app_text_styles.dart:64:    color: MyColors.themeColor,
constant/styles/app_text_styles.dart:96:    color: MyColors.themeColor,
constant/styles/app_text_styles.dart:429:    color: MyColors.themeColor,
view/foundation.dart:205:              color: MyColors.themeColor,
view/register_page/common_input_field/memo_input_field.dart:99:                    cursorColor: MyColors.themeColor,
view/register_page/common_input_field/price_input_row/large_price_display.dart:91:              cursorColor: MyColors.themeColor,
view/register_page/fixed_cost_tab/price_input_area/price_type_switch_area.dart:64:                  activeTrackColor: MyColors.themeColor, // トグルON時のバー色
view/component/unconfirmed_fixed_cost_chip_label.dart:18:          border: Border.all(color: MyColors.themeColor)),
view/component/unconfirmed_fixed_cost_chip_label.dart:25:            color: MyColors.themeColor,
view/component/unconfirmed_fixed_cost_chip_label.dart:32:              color: MyColors.themeColor,
view/component/app_year_month_picker.dart:564:            color: MyColors.themeColor,
view/component/app_component.dart:20:      indicatorColor: MyColors.themeColor,
view/component/check_box.dart:17:              color: MyColors.themeColor,
view/component/app_floating_action_button.dart:7:/// 背景色・前景色は引数で上書き可。既定は [MyColors.themeColor] / 白。
view/component/app_floating_action_button.dart:24:  /// ボタン背景色。省略時は [MyColors.themeColor]。
view/component/app_floating_action_button.dart:32:    final bgColor = backgroundColor ?? MyColors.themeColor;
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/cotegory_appearance_edit_area.dart:136:                    // cursorColor: MyColors.themeColor,
view/category_edit_page/big_category_detail_edit_page/dialog/new_small_category_input_name_dialog.dart:68:              cursorColor: MyColors.themeColor,
view/year_page/bonus_plan_area/bonus_plan_bar_graph.dart:76:                color: MyColors.themeColor,
view/year_page/bonus_plan_area/bonus_plan_bar_graph.dart:93:              color: MyColors.themeColor,
view/year_page/yearly_balance_area/yearly_balance_bar_graph.dart:81:                  color: MyColors.themeColor,
view/year_page/yearly_balance_area/yearly_balance_bar_graph.dart:100:                  color: MyColors.themeColor,
view/monthly_page/monthly_page.dart:274:                                color: MyColors.themeColor,
```

### `MyColors.label`（25箇所）

```
constant/styles/app_text_styles.dart:90:    color: MyColors.label,
constant/styles/app_text_styles.dart:105:    color: MyColors.label,
constant/styles/app_text_styles.dart:161:    color: MyColors.label,
constant/styles/app_text_styles.dart:182:    color: MyColors.label,
constant/styles/app_text_styles.dart:207:    color: MyColors.label,
constant/styles/app_text_styles.dart:228:    color: MyColors.label,
constant/styles/app_text_styles.dart:242:    color: MyColors.label,
constant/styles/app_text_styles.dart:257:        color: MyColors.label,
constant/styles/app_text_styles.dart:281:    color: MyColors.label,
constant/styles/app_text_styles.dart:290:        color: MyColors.label,
constant/styles/app_text_styles.dart:314:    color: MyColors.label,
constant/styles/app_text_styles.dart:419:      color: textColor ?? MyColors.label,
constant/styles/register_page_styles.dart:50:    color: MyColors.label,
constant/styles/register_page_styles.dart:71:    color: MyColors.label,
constant/styles/register_page_styles.dart:177:    color: MyColors.label,
constant/styles/register_page_styles.dart:189:    color: MyColors.label,
constant/styles/graph_text_styles.dart:36:    color: MyColors.label,
constant/styles/graph_text_styles.dart:43:    color: MyColors.label,
constant/styles/graph_text_styles.dart:51:    color: MyColors.label,
view/register_page/common_input_field/memo_input_field.dart:80:                    color: MyColors.label,
view/register_page/common_input_field/date_input_field.dart:63:              color: MyColors.label,
view/register_page/common_input_field/budget_row.dart:84:                  color: MyColors.label,
view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_input_field.dart:72:              color: MyColors.label,
view/register_page/fixed_cost_tab/payment_frequency_input_area/initial_payment_date_input_field.dart:76:              color: MyColors.label,
view/component/check_box.dart:22:              color: MyColors.label,
```

### `MyColors.pink`（21箇所）

```
constant/styles/app_text_styles.dart:302:    color: MyColors.pink,
constant/styles/calendar_styles.dart:69:    color: MyColors.pink,
constant/styles/calendar_styles.dart:112:    color: MyColors.pink,
view/register_page/common_input_field/const_getter.dart/color_getter.dart:9:    TransactionMode.expense => MyColors.pink,
view/register_page/common_input_field/const_getter.dart/color_getter.dart:11:    TransactionMode.fixedCost => MyColors.pink,
view/register_page/common_input_field/const_getter.dart/color_getter.dart:17:    TransactionMode.expense => MyColors.pink.withOpacity(0.1),
view/register_page/common_input_field/const_getter.dart/color_getter.dart:19:    TransactionMode.fixedCost => MyColors.pink.withOpacity(0.1),
view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart:24:    final savingsColor = isSurplus ? MyColors.incomeEmerald : MyColors.pink;
view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart:52:            _row(label: '支出', amount: value.monthlyExpense, color: MyColors.pink),
view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart:193:      color: MyColors.pink,
view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart:296:        ..color = isSurplus ? MyColors.incomeEmerald : MyColors.pink
view/year_page/yearly_balance_area/yearly_balance_area.dart:181:                                  color: MyColors.pink,
view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_painter.dart:692:      ..color = MyColors.pink
view/historical_calendar_page/calendar_area/date_box.dart:143:            color: isIncome ? MyColors.mintBlue : MyColors.pink,
view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart:74:          color: MyColors.pink,
view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart:172:                      child: Icon(size: 18, Icons.remove, color: MyColors.pink),
view/historical_calendar_page/expense_history_area/tiles/income_item_tile.dart:58:          color: MyColors.pink,
view/historical_calendar_page/expense_history_area/tiles/unconfirmed_fixed_cost_item_tile.dart:52:          color: MyColors.pink,
view/historical_calendar_page/expense_history_area/tiles/unconfirmed_fixed_cost_item_tile.dart:134:                      child: Icon(size: 18, Icons.remove, color: MyColors.pink),
view/historical_calendar_page/expense_history_area/tiles/confirmed_fixed_cost_item_tile.dart:48:        color: MyColors.pink,
view/historical_calendar_page/expense_history_area/tiles/confirmed_fixed_cost_item_tile.dart:130:                    child: Icon(size: 18, Icons.remove, color: MyColors.pink),
```

### `MyColors.secondarySystemBackground`（19箇所）

```
view/foundation.dart:139:              color: MyColors.secondarySystemBackground.withOpacity(0.7),
view/daily_expense_summary_page/daily_expense_summary_page.dart:29:      backgroundColor: MyColors.secondarySystemBackground,
view/register_page/register_page_base.dart:136:        backgroundColor: MyColors.secondarySystemBackground,
view/register_page/income_tab/register_income_page.dart:61:        backgroundColor: MyColors.secondarySystemBackground,
view/register_page/fixed_cost_tab/register_fixed_cost_page.dart:66:        backgroundColor: MyColors.secondarySystemBackground,
view/register_page/category_area/category_reorder_page.dart:217:      backgroundColor: MyColors.secondarySystemBackground,
view/register_page/expense_tab/register_expense_page.dart:55:        backgroundColor: MyColors.secondarySystemBackground,
view/component/glass_app_bar_background.dart:16:          color: MyColors.secondarySystemBackground.withOpacity(0.7),
view/component/page_loading_indicator.dart:16:      color: MyColors.secondarySystemBackground,
view/category_edit_page/category_setting_page.dart:56:        backgroundColor: MyColors.secondarySystemBackground,
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/category_detail_edit_page.dart:54:        backgroundColor: MyColors.secondarySystemBackground,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/update_complete_button/update_complete_income_category_detail_button.dart:46:                    backgroundColor: MyColors.secondarySystemBackground,
view/year_page/year_page.dart:163:      backgroundColor: MyColors.secondarySystemBackground,
view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart:69:        backgroundColor: MyColors.secondarySystemBackground,
view/monthly_page/monthly_page.dart:171:      backgroundColor: MyColors.secondarySystemBackground,
view/monthly_page/category_tile/big_category_expense_history_page/category_expense_hisotry_page.dart:14:      backgroundColor: MyColors.secondarySystemBackground,
view/monthly_page/category_tile/big_category_expense_history_page/small_category_expanded_history_page/small_category_expanded_history_page.dart:15:      backgroundColor: MyColors.secondarySystemBackground,
view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart:16:        backgroundColor: MyColors.secondarySystemBackground,
view/historical_calendar_page/expense_history_page.dart:62:      backgroundColor: MyColors.secondarySystemBackground,
```

### `MyColors.tirtiarySystemfill`（17箇所）

```
view/config/config_top.dart:37:                color: MyColors.tirtiarySystemfill,
view/register_page/category_area/category_area.dart:164:                ? MyColors.tirtiarySystemfill
view/register_page/category_area/category_reorder_page.dart:432:                ? MyColors.tirtiarySystemfill
view/monthly_page/skeleton/monthly_plan_skeleton.dart:44:                    color: MyColors.tirtiarySystemfill.withOpacity(0.5),
view/monthly_page/skeleton/monthly_plan_skeleton.dart:53:                    color: MyColors.tirtiarySystemfill.withOpacity(0.4),
view/monthly_page/skeleton/monthly_plan_skeleton.dart:62:                    color: MyColors.tirtiarySystemfill.withOpacity(0.3),
view/monthly_page/skeleton/monthly_plan_skeleton.dart:74:                color: MyColors.tirtiarySystemfill.withOpacity(0.4),
view/monthly_page/skeleton/monthly_plan_skeleton.dart:86:                    color: MyColors.tirtiarySystemfill.withOpacity(0.5),
view/monthly_page/skeleton/monthly_plan_skeleton.dart:95:                    color: MyColors.tirtiarySystemfill.withOpacity(0.4),
view/monthly_page/skeleton/monthly_plan_skeleton.dart:104:                    color: MyColors.tirtiarySystemfill.withOpacity(0.3),
view/monthly_page/skeleton/monthly_plan_skeleton.dart:116:                color: MyColors.tirtiarySystemfill.withOpacity(0.4),
view/historical_calendar_page/calendar_area/date_box.dart:171:      color: MyColors.tirtiarySystemfill,
view/historical_calendar_page/expense_history_area/history_list_skeleton.dart:60:                          color: MyColors.tirtiarySystemfill.withOpacity(0.5),
view/historical_calendar_page/expense_history_area/history_list_skeleton.dart:97:              color: MyColors.tirtiarySystemfill.withOpacity(0.5),
view/historical_calendar_page/expense_history_area/history_list_skeleton.dart:111:                    color: MyColors.tirtiarySystemfill.withOpacity(0.5),
view/historical_calendar_page/expense_history_area/history_list_skeleton.dart:120:                    color: MyColors.tirtiarySystemfill.withOpacity(0.3),
view/historical_calendar_page/expense_history_area/history_list_skeleton.dart:133:              color: MyColors.tirtiarySystemfill.withOpacity(0.5),
```

### `MyColors.secondarySystemfill`（16箇所）

```
view/register_page/common_input_field/memo_input_field.dart:65:          color: MyColors.secondarySystemfill,
view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_input_field.dart:62:          color: MyColors.secondarySystemfill,
view/register_page/fixed_cost_tab/payment_frequency_input_area/initial_payment_date_input_field.dart:66:          color: MyColors.secondarySystemfill,
view/register_page/category_area/category_reorder_page.dart:132:          color: MyColors.secondarySystemfill,
view/register_page/category_area/icon_box/normal_icon_button.dart:41:                color: MyColors.secondarySystemfill,
view/component/check_box.dart:30:              border: Border.all(color: MyColors.secondarySystemfill),
view/component/app_pill_container.dart:7:/// 背景色: MyColors.secondarySystemfill
view/component/app_pill_container.dart:29:        color: MyColors.secondarySystemfill,
view/component/app_icon_circle_container.dart:10:    this.color = MyColors.secondarySystemfill,
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/cotegory_appearance_edit_area.dart:154:                      fillColor: MyColors.secondarySystemfill,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/income_category_appearance_edit_area.dart:137:                      fillColor: MyColors.secondarySystemfill,
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/fixed_cost_category_appearance_edit_area.dart:149:                      fillColor: MyColors.secondarySystemfill,
view/year_page/bonus_plan_area/bonus_plan_bar_graph.dart:65:                color: MyColors.secondarySystemfill,
view/year_page/yearly_balance_area/yearly_balance_bar_graph.dart:70:                  color: MyColors.secondarySystemfill,
view/monthly_page/category_tile/category_sum_graph.dart:54:                  color: MyColors.secondarySystemfill,
view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_graph_area/monthly_plan_graph_parts.dart:82:            color: MyColors.secondarySystemfill,
```

### `MyColors.quarternarySystemfill`（15箇所）

```
view/component/card_container.dart:6:/// 背景色: MyColors.quarternarySystemfill
view/component/card_container.dart:74:        color: MyColors.quarternarySystemfill,
view/component/app_list_card.dart:95:  /// 背景色 (デフォルト: MyColors.quarternarySystemfill)
view/component/app_list_card.dart:244:        color: backgroundColor ?? MyColors.quarternarySystemfill,
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/cotegory_appearance_edit_area.dart:74:              color: MyColors.quarternarySystemfill,
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/cotegory_appearance_edit_area.dart:273:                color: MyColors.quarternarySystemfill,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/income_category_appearance_edit_area.dart:71:              color: MyColors.quarternarySystemfill,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/income_category_appearance_edit_area.dart:236:                color: MyColors.quarternarySystemfill,
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/fixed_cost_category_appearance_edit_area.dart:96:              color: MyColors.quarternarySystemfill,
view/year_page/fixed_cost_button_area/fixed_cost_button_area.dart:54:      color: MyColors.quarternarySystemfill,
view/year_page/fixed_cost_button_area/fixed_cost_button_area.dart:118:          color: MyColors.quarternarySystemfill,
view/monthly_page/category_tile/all_no_budget_type_category_sum_tile.dart:37:      color: MyColors.quarternarySystemfill,
view/monthly_page/category_tile/category_sum_tile.dart:30:      color: MyColors.quarternarySystemfill,
view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/fixed_cost_summary_header.dart:60:                  color: MyColors.quarternarySystemfill,
view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/fixed_cost_summary_header.dart:79:                  color: MyColors.quarternarySystemfill,
```

### `MyColors.jet`（8箇所）

```
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/income_category_appearance_edit_area.dart:185:                          color: MyColors.jet.withOpacity(0.0),
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/income_category_appearance_edit_area.dart:191:                          color: MyColors.jet.withOpacity(0.0),
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/cotegory_appearance_edit_area.dart:214:                          color: MyColors.jet.withOpacity(0.0),
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/cotegory_appearance_edit_area.dart:221:                          color: MyColors.jet.withOpacity(0.0),
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/fixed_cost_category_appearance_edit_area.dart:193:                          color: MyColors.jet.withOpacity(0.0),
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/fixed_cost_category_appearance_edit_area.dart:199:                          color: MyColors.jet.withOpacity(0.0),
view/budget_setting_page/budget_category_tile.dart:223:                                          color: MyColors.jet.withOpacity(0.0),
view/budget_setting_page/budget_category_tile.dart:230:                                          color: MyColors.jet.withOpacity(0.0),
```

### `MyColors.incomeEmerald`（8箇所）

```
constant/styles/app_text_styles.dart:308:    color: MyColors.incomeEmerald,
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:41:    MyColors.incomeEmerald,
view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart:24:    final savingsColor = isSurplus ? MyColors.incomeEmerald : MyColors.pink;
view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart:50:            _row(label: '収入', amount: value.monthlyIncome, color: MyColors.incomeEmerald),
view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart:186:      color: MyColors.incomeEmerald,
view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart:296:        ..color = isSurplus ? MyColors.incomeEmerald : MyColors.pink
view/year_page/yearly_balance_area/yearly_balance_area.dart:243:                                  color: MyColors.incomeEmerald,
view/historical_calendar_page/expense_history_area/tiles/income_item_tile.dart:164:                        color: MyColors.incomeEmerald,
```

### `MyColors.transparent`（7箇所）

```
util/common_widget/price_input_dialog.dart:118:                    color: MyColors.transparent,
util/common_widget/price_input_dialog.dart:125:                    color: MyColors.transparent,
view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_color_controller/fixed_cost_category_color_controller.dart:14:    return MyColors.transparent;
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:27:  Color selectedColor = MyColors.transparent;
view/category_edit_page/big_category_detail_edit_page/dialog/new_small_category_input_name_dialog.dart:109:                  borderSide: const BorderSide(color: MyColors.transparent),
view/category_edit_page/big_category_detail_edit_page/dialog/new_small_category_input_name_dialog.dart:114:                  borderSide: const BorderSide(color: MyColors.transparent),
view/monthly_page/category_tile/category_sum_graph.dart:84:                  color: MyColors.transparent,
```

### `MyColors.systemGray`（7箇所）

```
view/register_page/fixed_cost_tab/price_input_area/price_type_switch_area.dart:65:                  inactiveTrackColor: MyColors.systemGray, // トグルOFF時のバー色
view/register_page/category_area/icon_box/selected_icon_button.dart:35:                color: MyColors.systemGray,
view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_painter.dart:357:      ..color = MyColors.systemGray
view/historical_calendar_page/expense_history_area/tiles/income_item_tile.dart:63:              child: Icon(Icons.delete, color: MyColors.systemGray),
view/historical_calendar_page/expense_history_area/tiles/unconfirmed_fixed_cost_item_tile.dart:57:              child: Icon(Icons.delete, color: MyColors.systemGray),
view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart:79:              child: Icon(Icons.delete, color: MyColors.systemGray),
view/historical_calendar_page/expense_history_area/tiles/confirmed_fixed_cost_item_tile.dart:53:            child: Icon(Icons.delete, color: MyColors.systemGray),
```

### `MyColors.systemGray2`（5箇所）

```
view/category_edit_page/big_category_detail_edit_page/small_category_edit_area.dart:327:                                    color: MyColors.systemGray2,
view/category_edit_page/big_category_setting_page/big_category_edit_area.dart:251:                                color: MyColors.systemGray2,
view/category_edit_page/big_category_setting_page/big_category_edit_area.dart:410:                                color: MyColors.systemGray2,
view/year_page/year_page.dart:136:                                  color: MyColors.systemGray2, size: 30),
view/monthly_page/monthly_page.dart:145:                              color: MyColors.systemGray2, size: 30),
```

### `MyColors.black`（5箇所）

```
view/register_page/category_area/icon_box/none_icon_button.dart:21:              color: MyColors.black,
view/historical_calendar_page/expense_history_area/tiles/income_item_tile.dart:56:        background: Container(color: MyColors.black),
view/historical_calendar_page/expense_history_area/tiles/unconfirmed_fixed_cost_item_tile.dart:50:        background: Container(color: MyColors.black),
view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart:72:        background: Container(color: MyColors.black),
view/historical_calendar_page/expense_history_area/tiles/confirmed_fixed_cost_item_tile.dart:46:      background: Container(color: MyColors.black),
```

### `MyColors.tirtiarySystemBackground`（4箇所）

```
util/common_widget/app_dialog.dart:49:                color: MyColors.tirtiarySystemBackground,
util/common_widget/app_dialog.dart:78:                color: MyColors.tirtiarySystemBackground,
view/component/app_year_month_picker.dart:404:        color: MyColors.tirtiarySystemBackground,
view/component/app_year_month_picker.dart:452:        color: MyColors.tirtiarySystemBackground,
```

### `MyColors.quarternarySystemfillOpaque`（4箇所）

```
view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart:124:                          color: MyColors.quarternarySystemfillOpaque,
view/year_page/annual_balance_chart/annual_balance_chart.dart:155:                              MyColors.quarternarySystemfillOpaque,
view/year_page/annual_balance_chart/annual_balance_chart.dart:156:                              MyColors.quarternarySystemfillOpaque,
view/year_page/annual_balance_chart/annual_balance_chart.dart:157:                              MyColors.quarternarySystemfillOpaque
```

### `MyColors.tertiarySystemBackground`（3箇所）

```
util/common_widget/checkable_popup_menu_item.dart:56:        color: MyColors.tertiarySystemBackground,
view/yearly_income_list_page/income_graph_area.dart:175:              color: MyColors.tertiarySystemBackground,
view/yearly_income_list_page/income_graph_area.dart:184:              color: MyColors.tertiarySystemBackground,
```

### `MyColors.systemGray4`（3箇所）

```
util/common_widget/app_delete_dialog.dart:111:      color: isPrimary ? MyColors.themeColor : MyColors.systemGray4,
view/component/app_year_month_picker.dart:538:        color: MyColors.systemGray4.withValues(alpha: 0.6),
view/component/app_year_month_picker.dart:549:            color: MyColors.systemGray4,
```

### `MyColors.systemfill`（3箇所）

```
view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/cotegory_appearance_edit_area.dart:179:                                color: MyColors.systemfill,
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/income_category_appearance_edit_area.dart:155:                                color: MyColors.systemfill,
view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/fixed_cost_category_appearance_edit_area.dart:167:                                color: MyColors.systemfill,
```

### `MyColors.mintBlue`（3箇所）

```
constant/styles/calendar_styles.dart:82:        color: MyColors.mintBlue,
constant/styles/calendar_styles.dart:125:    color: MyColors.mintBlue,
view/historical_calendar_page/calendar_area/date_box.dart:143:            color: isIncome ? MyColors.mintBlue : MyColors.pink,
```

### `MyColors.expensePink`（3箇所）

```
view_model/state/big_category_detail_edit_page/big_category_color_contoroller/big_category_color_contoroller.dart:15:    return MyColors.expensePink;
view/category_edit_page/big_category_detail_edit_page/income_category_detail_edit_page/update_complete_button/update_complete_income_category_detail_button.dart:66:                          style: TextStyle(color: MyColors.expensePink),
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:31:    MyColors.expensePink,
```

### `MyColors.buttonSecondary`（3箇所）

```
view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_picker.dart:132:                  backgroundColor: MyColors.buttonSecondary,
view/component/button_util.dart:6:  secondary(MyColors.buttonSecondary);
view/category_edit_page/big_category_detail_edit_page/dialog/new_small_category_input_name_dialog.dart:140:                    backgroundColor: MyColors.buttonSecondary,
```

### `MyColors.tirtiaryLabel`（2箇所）

```
constant/styles/app_text_styles.dart:249:    color: MyColors.tirtiaryLabel,
constant/styles/calendar_styles.dart:139:        color: MyColors.tirtiaryLabel,
```

### `MyColors.systemBackground`（2箇所）

```
view/family_page/family_page.dart:12:      backgroundColor: MyColors.systemBackground,
view/family_page/family_page.dart:14:        backgroundColor: MyColors.systemBackground,
```

### `MyColors.incomeGreen`（2箇所）

```
view_model/state/big_category_detail_edit_page/income_big_category_color_controller/income_big_category_color_controller.dart:12:    return MyColors.incomeGreen;
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:42:    MyColors.incomeGreen,
```

### `MyColors.fixedCostGray`（2箇所）

```
application/prediction_graph/prediction_graph_data_source.dart:245:          colorCode: MyColors().getHexFromColor(MyColors.fixedCostGray),
application/prediction_graph/prediction_graph_data_source.dart:258:          colorCode: catInfo?.colorCode ?? MyColors().getHexFromColor(MyColors.fixedCostGray),
```

### `MyColors.themeThinColor`（1箇所）

```
view/component/unconfirmed_fixed_cost_chip_label.dart:16:          color: MyColors.themeThinColor,
```

### `MyColors.systemGray5`（1箇所）

```
util/common_widget/app_delete_dialog.dart:30:            backgroundColor: MyColors.systemGray5,
```

### `MyColors.incomeMintGreen`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:44:    MyColors.incomeMintGreen,
```

### `MyColors.incomeDeepGreen`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:43:    MyColors.incomeDeepGreen,
```

### `MyColors.hoverColor`（1箇所）

```
view/component/button_util.dart:45:              Color.alphaBlend(MyColors.hoverColor, backgroundColor),
```

### `MyColors.expenseYellow`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:34:    MyColors.expenseYellow,
```

### `MyColors.expenseRed`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:30:    MyColors.expenseRed,
```

### `MyColors.expensePurple`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:37:    MyColors.expensePurple,
```

### `MyColors.expenseMint`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:33:    MyColors.expenseMint,
```

### `MyColors.expenseGiantsOrange`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:35:    MyColors.expenseGiantsOrange,
```

### `MyColors.expenseBrown`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:36:    MyColors.expenseBrown,
```

### `MyColors.expenseBlue`（1箇所）

```
view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart:32:    MyColors.expenseBlue,
```

### `MyColors.buttonPrimary`（1箇所）

```
view/component/button_util.dart:5:  main(MyColors.buttonPrimary),
```

### `MyColors.barHandler`（1箇所）

```
view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart:113:                              color: MyColors.barHandler,
```
