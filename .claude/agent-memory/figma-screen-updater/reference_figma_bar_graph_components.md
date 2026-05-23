---
name: Figma棒グラフコンポーネント構造
description: kakeiboアプリのFigmaファイル内にある棒グラフ(graph/graph_all_category)コンポーネントのノードID・構造マッピング
type: reference
---

## Figmaファイル
- fileKey: UhV3dLrJDWKuOdG9ik4uHW
- URL: https://www.figma.com/design/UhV3dLrJDWKuOdG9ik4uHW/

## 棒グラフ関連コンポーネントセット

### 1. graph (カテゴリ別カード用) - id: 474:1412
- ページ: Component
- バリアント: category=pink, red, green, purple, mintGreen, yellow, blown, orange
- 高さ: 7px
- 対応コード: CategorySumGraph (元々7px)

### 2. graph_all_category (月次プラン用 / 3バリアント) - id: 2733:12850
- ページ: Component
- バリアント: デフォルト(背景枠あり), 予算なし(背景枠なし), バリアント3(背景枠あり+超過表示)
- 高さ: 7px (2026-04-05に10->7に修正)
- 対応コード: MnothlyPlanGraph, MonthlyIncomeGraph, SummaryBarGraph

### 3. graph_all_category (収入用 / 2バリアント) - id: 2733:12991
- ページ: Component
- バリアント: デフォルト, バリアント2
- 高さ: 7px (2026-04-05に10->7に修正)
- 対応コード: 月次プラン内の収入バーグラフ

### 4. graph フレーム (カテゴリー別展開用) - id: 1914:8591
- ページ: Component
- 親コンポーネント: Component 49 (id: 1914:8619)
- 高さ: 7px (2026-04-05に10->7に修正)
- 対応コード: ExpandedCategoryTile内のバーグラフ

## Componentページとコードの対応

| Figmaコンポーネント | Flutter Widget | ファイル |
|---|---|---|
| graph (474:1412) | CategorySumGraph | category_sum_graph.dart |
| graph_all_category (2733:12850) | MnothlyPlanGraph / MonthlyIncomeGraph / SummaryBarGraph | monthly_plan_graph_parts.dart / monthly_income_graph_parts.dart / summary_bar_graph.dart |
| graph_all_category (2733:12991) | (収入バー) | monthly_income_graph_parts.dart |
| graph (1914:8591) | ExpandedCategoryTile | expanded_category_sum_tile.dart |

## 月次プラン親コンポーネント
- Group 93 (id: 2671:17777) - 月次プランカードのコンポーネントセット
  - 6つの状態バリアント: 支出+予算(未超過)+収入あり, 支出超過+収入あり, 予算なし+収入あり, 支出のみ, 収入のみ, データなし
- Group 24 (id: 2667:16877) - 別の月次プランコンポーネント
