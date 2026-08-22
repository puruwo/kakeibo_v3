---
name: kakeibo-common-components
description: >
  kakeiboプロジェクトの共通UIコンポーネント一覧と利用ガイド。
  カード・タイル・ピル・アイコン背景などのUIを実装するときは
  必ずこのSkillを参照し、既存の共通widgetを優先的に使うこと。
  Containerに BoxDecoration（色・角丸・border・shape）を直接書こうとしたら、
  まずこのSkillの該当widgetを使えないか確認すること。
---

# kakeibo 共通UIコンポーネントガイド

Containerに `BoxDecoration` を直接書く前に、必ずこのドキュメントの共通widgetが使えないか確認すること。  
新しい画面実装・既存画面の修正どちらでも、共通widgetを優先利用する。

---

## 共通widget一覧

| Widget | 用途 | 主なスタイル | ファイル |
|---|---|---|---|
| `CardContainer` | 汎用カード（背景＋角丸18px） | 背景: `quarternarySystemfill` / 角丸: 18px | `lib/view/component/card_container.dart` |
| `AppListCard` | 履歴・リストタイル | アイコン＋タイトル＋金額の統一レイアウト | `lib/view/component/app_list_card.dart` |
| `AppPillContainer` | ピル型（角丸50px）コンテナ | 背景: `secondarySystemfill` / 角丸: 50px / 高さ: `pillHeight` | `lib/view/component/app_pill_container.dart` |
| `AppIconCircleContainer` | アイコンボタン用円形背景 | shape: circle / 色は省略時 `secondarySystemfill` | `lib/view/component/app_icon_circle_container.dart` |
| `UnconfirmedFixedCostChipLabel` | 「変動あり」表示用チップ | 角丸4px + テーマカラーborder | `lib/view/component/unconfirmed_fixed_cost_chip_label.dart` |
| `FixedCostChipLabel` | 明細行が固定費由来であることを示す「固定費」チップ | 角丸4px + `icon` border / 背景 `fillTertiary` | `lib/view/component/fixed_cost_chip_label.dart` |
| `CheckBox` | 円形チェックボックス | shape: circle / 状態で色切替 | `lib/view/component/check_box.dart` |
| `showAppYearMonthPicker` | AppBar下ドロップダウン年月度・年度ピッカー | Overlay式。月度モード（年＋月ドラム）と年度モード（年ドラム）の2種 | `lib/view/component/app_year_month_picker.dart` |
| `AppEmptyState` | 次アクションがある空状態の共通カード（ADR-022） | CardContainer + アイコン32px + 見出し + 説明1行 + Primaryボタン | `lib/view/component/app_empty_state.dart` |
| `AppInsetGroup` / `AppInsetRow` | 設定アプリ風のインセットグループリスト | 背景: `fillQuaternary` / 1px `surfaceBorder` / 角丸14px / 行高46 / 行間0.5px `separator` | `lib/view/component/app_inset_group.dart` |

---

## 各widgetの使い方

### 1. CardContainer

汎用カード。`Container` + `decoration: BoxDecoration(color: quarternarySystemfill, borderRadius: 18px)` のラッパー。

```dart
import 'package:kakeibo/view/component/card_container.dart';

CardContainer(
  padding: const EdgeInsets.all(16),
  child: Text('カード内容'),
)
```

**こういうContainerを見つけたら置き換え:**
```dart
// ❌ Before
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: MyColors.quarternarySystemfill,
    borderRadius: BorderRadius.circular(18),
  ),
  child: ...,
)

// ✅ After
CardContainer(
  padding: EdgeInsets.all(16),
  child: ...,
)
```

カードの統一角丸は `appCardRadius`（`BorderRadius.circular(18)`）として `card_container.dart` でexportされているので、`InkWell` などで角丸を合わせたい場合はこれを使う。

---

### 2. AppListCard

履歴・リスト系のタイル。アイコン＋タイトル＋金額の統一レイアウトを提供する。

```dart
import 'package:kakeibo/view/component/app_list_card.dart';

AppListCard(
  iconPath: 'assets/icons/food.svg',
  primaryTitle: '食費',
  subtitleLeading: 'スーパー',
  priceLabel: '1,200',
  isIncome: false,
  onTap: () {},
)
```

履歴・カレンダー・分析画面のリストはすべてこれを利用すること。新たに `Container` + `Row` で似たレイアウトを書かない。

2行目に色を混在させたテキスト（例: 月次固定費ビューの「小カテゴリー › 日付」）を置きたい場合は、
`subtitleLeading`（String）ではなく `subtitleLeadingWidget`（Widget）を渡す。

---

### 3. AppPillContainer

入力ページのピル型UI（日付ボタン・予算行など）。

```dart
import 'package:kakeibo/view/component/app_pill_container.dart';

AppPillContainer(
  width: InputPageWidgetSize.pillWidth,  // 省略可
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(...),
)
```

**こういうContainerを見つけたら置き換え:**
```dart
// ❌ Before
Container(
  height: InputPageWidgetSize.pillHeight,
  decoration: BoxDecoration(
    color: MyColors.secondarySystemfill,
    borderRadius: BorderRadius.circular(50),
  ),
  padding: ...,
  child: ...,
)

// ✅ After
AppPillContainer(
  padding: ...,
  child: ...,
)
```

**使えないケース:** 色やborderが動的に変わるピル（例: `TransactionTypePill`）はそのまま `Container` を使う。共通化を無理にしない。

---

### 4. AppIconCircleContainer

アイコンボタン用の円形背景。色を省略すると通常状態の `secondarySystemfill` になる。

```dart
import 'package:kakeibo/view/component/app_icon_circle_container.dart';

// 通常状態（色省略OK）
AppIconCircleContainer(
  child: SvgPicture.asset(...),
)

// 選択状態など色を変えたい場合
AppIconCircleContainer(
  color: MyColors.systemGray,
  child: SvgPicture.asset(...),
)
```

**こういうContainerを見つけたら置き換え:**
```dart
// ❌ Before
Container(
  decoration: const BoxDecoration(
    color: MyColors.secondarySystemfill,
    shape: BoxShape.circle,
  ),
  child: ...,
)

// ✅ After
AppIconCircleContainer(
  child: ...,
)
```

---

### 5. UnconfirmedFixedCostChipLabel / FixedCostChipLabel

`UnconfirmedFixedCostChipLabel` は「変動あり」表示専用のチップ。固定費マスタの変動表示でのみ使用する。

`FixedCostChipLabel` は「固定費」チップ。v10で固定費の実績が expense に統合されたため、
履歴・日次サマリ・カテゴリー詳細の明細行で通常支出と区別する目的で使う
（判定は `ExpenseHistoryTileValue.fixedCostId != null`。仕様 §7.2 / §8.4）。

新規にチップ系UIを作るときは、まずこの2つが流用できないか確認すること。

---

### 6. CheckBox

円形のチェックボックス。`isChecked` で表示切替。

```dart
import 'package:kakeibo/view/component/check_box.dart';

CheckBox(isChecked: selected)
```

---

### 7. showAppYearMonthPicker

AppBar の下にドロップダウン展開する年月度・年度ピッカー。
`Future<DateTime?>` を返し、「適用」で日時・背景タップで `null` が返る。

**モード**

| モード | ピッカー | 戻り値 |
|---|---|---|
| `AppYearMonthPickerMode.yearMonth` | 年列＋月度列の2ドラム | `DateTime(year, month末日)` |
| `AppYearMonthPickerMode.year` | 年ドラム（項目は「2025年4月〜2026年3月」形式） | `DateTime(year, 1, 1)` |

**基本の使い方（月度モード・分析画面）**

```dart
import 'package:kakeibo/view/component/app_year_month_picker.dart';

final picked = await showAppYearMonthPicker(
  context: context,
  mode: AppYearMonthPickerMode.yearMonth,
  // 分析画面表示中の月度の startDatetime を渡すと、ピッカー初期選択が表示月度と一致する
  initialDateTime: monthPeriod?.startDatetime ?? selectedDate,
);
if (picked == null) return;
ref.read(analyzePageSelectedDatetimeNotifierProvider.notifier).updateState(picked);
```

**基本の使い方（年度モード・ホーム画面）**

```dart
final picked = await showAppYearMonthPicker(
  context: context,
  mode: AppYearMonthPickerMode.year,
  initialDateTime: selectedDate,
);
if (picked == null) return;
// picked.year のみ使い、updateStateAsYear() で集計開始月・日に正規化する
await ref.read(homeSelectedDatetimeNotifierProvider.notifier)
    .updateStateAsYear(picked.year);
```

**重要な注意点**

- **月度モード**: ピッカー内部は `DateTime(year, month+1, 0)`（月末日）を `fetchMonthPeriod` に渡す。月初日（day=1）では集計開始日設定によって前月度が返るため。
- **年度モード**: ピッカー内部は `DateTime(year, startMonth, startDay)` を `fetchYearPeriod` に渡す。`DateTime(year, 1, 1)` では集計開始月（例:4月）より前になり、前年度が返るバグになる。
- 戻り値の `DateTime` 全体は信頼せず、`picked.year` / `picked.month` のみ使うのが安全。正規化は呼び出し側（`updateStateAsYear` など）が行う。

詳細は `kakeibo-period-patterns` スキルも参照。

---

### 8. AppEmptyState

ADR-022「空状態パターンの使い分け」に基づく、**次アクションがある空状態**の共通カード。
記録が0件で、そのセクションから登録導線（Primaryボタン）を出せる場合に使う。

```dart
import 'package:kakeibo/view/component/app_empty_state.dart';

AppEmptyState(
  icon: Icons.show_chart_rounded,
  title: '家計簿をはじめましょう',
  description: '毎日の収支を記録するとグラフが表示されます',
  buttonLabel: '＋ 記録を追加する',
  onPressed: () {
    showAppModalBottomSheet(
      context,
      child: const RegisaterPageBase.addExpense(),
    );
  },
)
```

**使い分け（ADR-022）**

| 状況 | 使うもの |
|---|---|
| 次アクションがある（そのセクションから登録導線を出せる） | `AppEmptyState`（カード形式） |
| 次アクションが無い従属領域（グラフ・サブリスト・絞り込み結果） | `AppTextStyles.listEmptyMessage` の1行テキスト |
| 取得失敗（エラー） | `AppErrorState`（`AppTextStyles.errorMessage`） |

カード形式の空状態は1画面につき原則1つまで。

---

### 9. AppInsetGroup / AppInsetRow

登録シート・編集シート・固定費の設定画面で共用する、iOS設定アプリ風のグループ化リスト。
`CardContainer`（角丸18・カード）とは用途が違い、**行を並べて属性を編集させる面**で使う。

```dart
import 'package:kakeibo/view/component/app_inset_group.dart';

AppInsetGroup(
  header: '設定',        // 任意のグループ見出し
  note: '補足文',         // 任意。グループの下に添える説明
  children: [
    AppInsetRow.navigation(
      icon: Icons.repeat_rounded,
      label: '頻度',
      value: '毎月',
      onTap: () {},
    ),
    AppInsetRow.switchRow(
      icon: Icons.trending_up_rounded,
      label: '支払い額が毎回変わる',
      switchValue: isVariable,
      onSwitchChanged: (v) {},
    ),
    AppInsetRow.textField(
      icon: Icons.drive_file_rename_outline_rounded,
      label: '名称',
      controller: nameController,
      hintText: '未入力',
      maxLength: 20,
    ),
    AppInsetRow.display(
      icon: Icons.calendar_today_outlined,
      label: '支払日',
      value: '8/25',
    ),
  ],
)
```

**行の型（4種）**

| 型 | 右端 | 用途 |
|---|---|---|
| `AppInsetRow.navigation` | 値＋右矢印 | 別画面・シート・ピッカーを開く |
| `AppInsetRow.switchRow` | スイッチ | ON/OFFの切り替え |
| `AppInsetRow.textField` | インライン入力欄 | その場でテキスト・金額を入力 |
| `AppInsetRow.display` | 値のみ | 表示専用（編集させない属性） |

**寸法・仕様**

- 行高 `kAppInsetRowHeight` = 46px、先頭アイコン `kAppInsetRowIconSize` = 18px
- 行の左インデント `kAppInsetRowIndent` = 16px（行間の区切り線もこの位置から）
- `icon` を省略してもアイコン枠は確保され、ラベル位置が揃う
- SVGのカテゴリーアイコンなど任意のウィジェットを置きたい場合は `leading` を使う（`icon` より優先）
- 使うTextStyleは `AppTextStyles.insetGroup*`（見出し／ラベル／値／プレースホルダー／補足文）

**AppListCard との使い分け**

| 用途 | 使うもの |
|---|---|
| 取引・固定費などの**レコードの一覧**（アイコン＋タイトル＋金額） | `AppListCard` |
| **属性の編集面**（ラベルと値が1対1で並ぶ設定リスト） | `AppInsetGroup` + `AppInsetRow` |

---

## 実装ルール

### 必ず守ること

1. **新規実装時**: `BoxDecoration` を書く前に、本ドキュメントの該当widgetがないか確認する
2. **既存修正時**: 修正対象のContainerが共通widget化できる場合は、可能な範囲で置き換える（ただし「修正に関係ない改行・インデントのみの修正をしない」ルールに従い、主作業を優先）
3. **新しい共通パターンを発見したとき**: 同じパターンが3箇所以上で使われていれば、共通widgetを新規作成して本ドキュメントに追記する

### 共通widgetを使わない判断基準

以下のような場合は無理に共通化せず、Containerをそのまま使ってよい:

- 色やborderが**動的に変わる**（例: 状態によってテーマカラーが入れ替わる `TransactionTypePill`）
- スタイルが**本当に1箇所のみ**でしか使われない
- 共通化することで**カスタマイズパラメータが過剰**（4個以上）になる場合

---

## 共通widgetを新規作成するときのルール

1. 配置先は必ず `lib/view/component/` 配下
2. ファイル名は `app_<用途>_container.dart` または `app_<名前>.dart`
3. クラス名は `App` プレフィックス + 用途名（例: `AppPillContainer`）
4. dartdocコメントで「背景色」「角丸」「主用途」を明記する
5. 作成後は本Skillのwidget一覧に追記する

---

## 参考: 角丸のパターン

| 値 | 用途 | 対応widget |
|---|---|---|
| 18px | 汎用カード | `CardContainer` |
| 50px | ピル形状 | `AppPillContainer` |
| 14px | インセットグループ（設定リスト） | `AppInsetGroup` |
| circle | 円形（アイコン背景・チェックボックス） | `AppIconCircleContainer`, `CheckBox` |
| 8px | セカンダリーボックス（設定画面など） | （共通widget未作成・必要なら新規追加） |
| 6px | カレンダータイル | （共通widget未作成・必要なら新規追加） |
| 4px | チップ・スケルトン | `UnconfirmedFixedCostChipLabel` ほか |
