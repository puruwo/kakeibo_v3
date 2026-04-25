---
name: annual-balance-chart
description: >
  生活収支グラフ（年間の月次収支をまとめて表示するチャート）の設計・実装ガイド。
  このグラフの UI / 描画 / データ計算 / インタラクションに関する修正・調査を行うときは必ずこの Skill を参照すること。
  fl_chart 非依存の自作 CustomPaint 実装（KAN-82 で再実装）。
---

# 生活収支グラフ（AnnualBalanceChart）

ホームタブ（year_page）に表示される、その年の月別収入・支出・収支を 1 つにまとめたグラフ。
上段折れ線（収入/支出）＋ 中段棒（収支）＋ 下段月ラベルの 3 段構成。
`fl_chart` を使わず、`CustomPaint` + `GestureDetector` + `Stack(Positioned tooltip)` で実装されている。

---

## 主要ファイル早見表

| 層 | パス | 役割 |
|---|---|---|
| Widget | `lib/view/year_page/annual_balance_chart/annual_balance_chart.dart` | 外枠・スクロール・タップ/ホールドハンドラ・ツールチップ Positioned 配置 |
| Painter | `lib/view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart` | 3 段描画の CustomPainter、レイアウト定数、Dimensions、固定ラベル用 Painter |
| Tooltip | `lib/view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart` | 月/収入/支出/収支を表示する Widget。本体タップで分析タブへ遷移 |
| Usecase | `lib/application/annual_balance_chart_usecase/annual_balance_chart_usecase.dart` | 12ヶ月分の収支取得、Y軸スケール計算、`representativeDate` 埋め込み |
| ValueObject | `lib/domain/ui_value/annual_balance_chart_value/annual_balance_chart_value.dart` | `monthIndex` / `monthlyBalanceValues` / `hasNoRecord` / `yAxisScale` |
| ValueObject | `lib/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart` | 各月のデータ。`monthlyBalanceType` と `representativeDate` を持つ |
| ValueObject | `lib/domain/ui_value/annual_balance_chart_value/y_axis_scale.dart` | Y軸の `minValue` / `maxValue` / `interval` / `gridValues` |
| Provider | `lib/view_model/middle_provider/.../resolved_annual_balance_chart_value_provider.dart` | Widget が watch するミドルプロバイダ |

---

## データフロー

```
AnnualBalanceChartUsecaseNotifier.fetch
  ├─ 12ヶ月分の income/expense を取得し MonthlyBalanceValue にマッピング
  ├─ 未来月は MonthlyBalanceType.future で除外
  └─ _calculateYAxisScale で YAxisScale を同梱
       ↓
resolvedAnnualBalanceChartValueProvider
       ↓
AnnualBalanceChart (ConsumerStatefulWidget)
  ├─ AnnualBalanceChartDimensions.from(values) でバー領域の高さを動的決定
  ├─ SingleChildScrollView + CustomPaint(AnnualBalanceChartPainter) で本体描画
  ├─ Stack に IgnorePointer で AnnualBalanceAxisLabelsPainter を固定オーバーレイ
  └─ タップ / ロングプレス → _updateSelection → _selectedMonthIndex を setState
       ↓
Positioned AnnualBalanceTooltip
  ├─ 本体タップ: analyzePageSelectedDatetimeNotifier.updateState(representativeDate)
  └─           : navigationBarNumberNotifier.updateState(2) で分析タブへ遷移
```

---

## レイアウト定数（`AnnualBalanceChartLayout`）

パス: `annual_balance_chart_painter.dart`

| 定数 | 値 | 意図 |
|---|---|---|
| `scrollAreaWidth` | 700.0 | カード全体の幅（横スクロール対象） |
| `horizontalPadding` | 8.0 | カード内側左右パディング |
| `drawingAreaWidth` | 684.0 | キャンバス幅（= Painter の Size.width） |
| `reservedSize` | **40.0** | Y軸ラベルに確保する左側幅。「250万」が折り返さないサイズ |
| `chartAreaWidth` | 644.0 | 実際に 12 ヶ月分を割り振る幅 |
| `lineAreaHeight` | 150.0 | 上段折れ線エリア |
| `barAreaHeight` | 80.0 | 中段バーエリア（黒字/赤字で上下分割） |
| `monthLabelAreaHeight` | 20.0 | 下段月ラベル |
| `maxBarHeight` | 24.0 | バー最大高さ（金額テキスト分 16px を控除） |
| `barWidth` | 25.0 | 棒の太さ |
| `leftCellMargin` / `rightCellMargin` | 0.3 | 端セルのマージン比率 |

### セル幅
- 左端（1月）・右端（12月）セルはマージン分だけ広い
- 中央 10 セル（2〜11月）は `chartAreaWidth / (11 + 0.6)` で等分
- `cellCenterX(i)` でセル中心 X 座標を取得

### ヒットテスト
- `hitTestCell(Offset, {monthLabelTopY})` で X/Y を月 index (0-11) に変換
- 左端 `reservedSize` 未満は常に `null`（Y軸ラベル領域）
- `monthLabelTopY` より下は `null`（月ラベル領域のタップを無反応に）

---

## バー領域の動的サイズ（`AnnualBalanceChartDimensions`）

その年に赤字月がない場合、バー領域の下半分が空くため、月ラベルとの隙間を縮める。

| 条件 | `barAreaTopHeight` | `barAreaBottomHeight` |
|---|---|---|
| 黒字月あり / 赤字月なし | `barAreaHeight / 2`（40） | 0 |
| 黒字月なし / 赤字月あり | 0 | `barAreaHeight / 2`（40） |
| 両方あり | 40 | 40 |

- `factory AnnualBalanceChartDimensions.from(values)` で未来月を除外しつつ判定
- `monthLabelTop` / `totalHeight` が動的に短くなる
- Widget 側の `SizedBox.height` とオーバーレイ `height` に適用

---

## Y軸スケール計算

パス: `annual_balance_chart_usecase.dart` の `_calculateYAxisScale` / `_niceInterval`

### アルゴリズム
1. 未来月を除いた income / expense を全て結合
2. `rawMax` を算出（`rawMin` は常に 0）
3. `_niceInterval(rawMax, targetGridCount=5)` で 1/2/5 系列から `interval` を選出
4. `maxValue = ceil(rawMax / interval) * interval`
5. `minValue = 0` 固定
6. `gridValues` = `[0, interval, 2*interval, ..., maxValue]`

### `_niceInterval`
- `rawStep = range / 5` を `10^n × {1, 2, 5}` で丸める
- `base < 1.5 → 1` / `< 3.5 → 2` / `< 7.5 → 5` / それ以上 → `10`
- **下限 10000**（1 万未満のグリッドは出さない）

### 外れ値の扱い
- 賞与月などで `rawMax` が大きくても **キャップしない**（方針2を採択）
- 折れ線は raw 値でスパイクさせる / 棒は `max(|savings|)` ベースでスケーリング
- ▲▼ 等のオーバーフロー表示は**導入していない**

---

## 描画レイヤ構造

`AnnualBalanceChart` Widget の構造:

```
CardContainer
└── Stack
    ├── SingleChildScrollView (horizontal, scrollController)
    │   └── Padding (horizontal=8, vertical=16)
    │       └── SizedBox (width=drawingAreaWidth, height=dimensions.totalHeight)
    │           └── Stack (clipBehavior: none)
    │               ├── GestureDetector
    │               │   └── CustomPaint(AnnualBalanceChartPainter)
    │               │       [上段折れ線 → 中段バー → 下段月ラベル]
    │               └── Positioned AnnualBalanceTooltip（_selectedMonthIndex != null のとき）
    │
    └── Positioned(left: 0, top: 16, width: reservedSize)  ← 固定オーバーレイ
        └── IgnorePointer
            └── DecoratedBox(LinearGradient: opaque → transparent)
                └── CustomPaint(AnnualBalanceAxisLabelsPainter)
                    [N万 ラベル + 「収支」ラベル]
```

### 固定 Y軸ラベルオーバーレイ
- `reservedSize=40` 幅、`totalHeight` 高さ
- 背景は `MyColors.quarternarySystemfillOpaque`（カード同色）からフェードアウト（stops `[0.0, 0.6, 1.0]`）
  - 左端〜60%: 不透明でスクロール中のコンテンツを隠す
  - 60%〜100%: 透過してグラフと自然にブレンド
- `IgnorePointer` でタップは裏側のグラフに透過
- 描画は `AnnualBalanceAxisLabelsPainter`（`scale` と `dimensions` を受け取る）

---

## インタラクション仕様

### タップ系
| 操作 | 挙動 |
|---|---|
| 短タップ（`onTapDown`） | タップした月のツールチップを即時表示 |
| ロングプレス開始（`onLongPressStart`） | タップした月のツールチップ表示 |
| ロングプレス中の移動（`onLongPressMoveUpdate`） | スライド先の月にツールチップ追従 |
| 未来月タップ / `reservedSize` 未満 / 月ラベル領域 | ツールチップを閉じる |
| ツールチップ本体タップ | `representativeDate` を分析タブの state に反映し、タブを分析（index=2）へ切替、同時に選択解除 |

**注意**: 横スクロールと競合するため、追従はロングプレス経由（`onPanUpdate` は使わない）。
短タップ直後にそのまま横スライドすると通常のスクロールが優先される。

### スクロール初期位置
- 初回ビルドの `WidgetsBinding.addPostFrameCallback` で一度だけ設定
- `_didInitialScroll` フラグで再実行を防止（他月タップ → 勝手にスクロール戻りを防ぐ）
- `monthIndex <= 3` → 左端、`<= 7` → 中央、それ以外 → 右端にアニメーションスクロール

### ツールチップ位置
- 月中心 `cellCenterX(_selectedMonthIndex)` を中心にして固定幅 160px で配置
- 左右見切れ防止の clamp あり（`left < 0` / `left + 160 > drawingAreaWidth`）

---

## よくある修正パターン

### 1. レイアウトを変えたい（高さ・幅など）
1. `AnnualBalanceChartLayout` の定数を変更
2. 影響範囲:
   - `reservedSize` を縮めると 3 桁万円ラベルが改行する → `TextPainter` は `maxLines: 1` なので切れる
   - `drawingAreaWidth` を縮めると `cellCenterX` の中心位置も連動
   - `maxBarHeight` を変えると金額テキストとバーの重なりに注意

### 2. Y軸の刻みを変えたい
- `_niceInterval` の `targetGridCount` / 下限値 / `niceBase` しきい値を調整
- グリッド本数は「スケール計算時点での rawMax ベース」で決まる

### 3. バー領域の高さ動的化ルールを変えたい
- `AnnualBalanceChartDimensions.from(values)` の `keepTop` / `hasDeficit` 判定を変更
- 「赤字0でも下半分を残したい」等のケースはここをいじる

### 4. ツールチップの見た目を変えたい
- `annual_balance_tooltip.dart` のみ編集
- 色は `MyColors.incomeEmerald`（収入・黒字）/ `MyColors.pink`（支出・赤字）

### 5. 現在月の強調を変えたい
- Painter の月ラベル描画部分で `currentMonth` と一致するセルの `TextStyle` を変更
- 現状は `Colors.white + FontWeight.bold`（緑字ではない）

---

## 陥りやすい罠

- **`reservedSize` を狭める** → 「250万」など 3 桁万円ラベルが切れる。40 未満にしないこと
- **現在月の色を緑に戻す** → 視認性が落ちるため NG。白+太字で統一する
- **スクロール追従を `onPanUpdate` で実装** → 横スクロールと競合する。ロングプレス系で実装
- **初期スクロールフラグを削除** → 他月タップ時に勝手にスクロール位置が戻るバグが再発する
- **`hasNoRecord == true` のときに描画を試みる** → Widget 側で早期 return（「まだ記録がありません」）しているが、Painter 側でも `incomeExpense.isEmpty` ならダミー値を返す二重防御
- **Painter の未来月描画漏れ** → 未来月は折れ線・バーを描かず、月ラベルのみ薄色で表示するのが現行仕様
- **`MonthlyBalanceValue` フィールド追加** → Freezed なので `dart run build_runner build --delete-conflicting-outputs` 必須

---

## 依存関係

- `fl_chart` は**このグラフ本体では使っていない**
- ただし `pubspec.yaml` からの `fl_chart` 依存削除は **別チケット**（`PieChart` が `income_graph_area.dart` / `daily_expense_graph_area.dart` で残存）
- 他の折れ線 + ツールチップ実装の参考: `lib/view/monthly_page/prediction_graph_area/prediction_graph_parts/`
  （`PredictionGraphWidget` + `PredictionGraphPainter` + `GraphTooltip` が同じ構造）

---

## 関連

- Jira: KAN-82（fl_chart から自作実装への置換）
- Pull Request: https://github.com/puruwo/kakeibo_v3/pull/15
- 先行改修: KAN-75（Y軸グリッド調整）
