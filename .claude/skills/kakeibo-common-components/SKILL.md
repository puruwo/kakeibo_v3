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
| `CheckBox` | 円形チェックボックス | shape: circle / 状態で色切替 | `lib/view/component/check_box.dart` |

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

### 5. UnconfirmedFixedCostChipLabel

「変動あり」表示専用のチップ。固定費の変動表示でのみ使用する。新規にチップ系UIを作るときは、まずこれが流用できないか確認すること。

---

### 6. CheckBox

円形のチェックボックス。`isChecked` で表示切替。

```dart
import 'package:kakeibo/view/component/check_box.dart';

CheckBox(isChecked: selected)
```

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
| circle | 円形（アイコン背景・チェックボックス） | `AppIconCircleContainer`, `CheckBox` |
| 8px | セカンダリーボックス（設定画面など） | （共通widget未作成・必要なら新規追加） |
| 6px | カレンダータイル | （共通widget未作成・必要なら新規追加） |
| 4px | チップ・スケルトン | `UnconfirmedFixedCostChipLabel` ほか |
