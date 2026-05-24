---
name: kakeibo-period-patterns
description: >
  kakeiboの集計期間計算で踏みやすい落とし穴と正しいパターン集。
  fetchMonthPeriod / fetchYearPeriod を呼ぶとき、
  「現在月度」で未来/過去を判定するとき、
  年度ラベルを表示するときに必ず参照すること。
---

# kakeibo 集計期間計算パターン集

## TL;DR（よくあるバグの一覧）

| バグの症状 | 原因 | 正しい対処 |
|---|---|---|
| `fetchMonthPeriod` が1ヶ月ずれた月度を返す | 月初日（day=1）を渡すと集計開始日設定によって前月度になる | 月末日（`DateTime(year, month+1, 0)`）を渡す |
| `fetchYearPeriod` が前年度を返す | `DateTime(year, 1, 1)` は集計開始月（例:4月）より前になる | `DateTime(year, startMonth, startDay)` を渡す |
| 過去年度を選択したとき生活収支グラフが4月分しか描画されない | `selectedDate` 由来の月度を「現在月度」として未来判定に使っている | `systemDatetimeNotifierProvider` から現在月度を導出する |
| ホーム画面のAppBarが「2024年 - 2025年」と表示される | `yearPeriod.startDatetime.year` と `endDatetime.year` を直接使っている | `dateScope.representativeYear.year` を使う（YearBasis設定に従う） |

---

## パターン1: fetchMonthPeriod に渡す日付

### ❌ やってはいけないパターン

```dart
// 月初日を渡すと集計開始日が1日以外のとき前月度が返る
final period = await monthPeriodService.fetchMonthPeriod(DateTime(year, month, 1));
```

**例**: 集計開始日=25 のとき、`DateTime(2025, 4, 1)` を渡すと
- `includedDate(4/1) < aggregationStartDay(4/25)` → 前月度（3/25〜4/24）が返る
- ユーザーが「4月度」を選んでいるのに3月度の集計になるバグ

### ✅ 正しいパターン: 月末日を渡す

```dart
// 月末日を渡すことで、集計開始日設定に依存せず選んだ月の月度が必ず返る
final lastDayOfMonth = DateTime(year, month + 1, 0);
final period = await monthPeriodService.fetchMonthPeriod(lastDayOfMonth);
```

**なぜ月末日が安全か**: `DateTime(year, month+1, 0)` はDartの自動補正で月末日になる。
月末日は必ず「その月のどの集計開始日設定でも、その月を含む月度」に属する。

---

## パターン2: fetchYearPeriod に渡す日付

### ❌ やってはいけないパターン

```dart
// 1月1日を渡すと集計開始月が4月以降のとき前年度が返る
final period = await yearPeriodService.fetchYearPeriod(DateTime(year, 1, 1));
```

**例**: 集計開始月=4月、集計開始日=1日 のとき、`DateTime(2025, 1, 1)` を渡すと
- `includedDate(1/1) < aggregationStartDay(4/1)` → 前年度（2024/4〜2025/3）が返る
- ピッカーで「2025年度」を選んでいるのに2024年度の期間が表示されるバグ

### ✅ 正しいパターン: 集計開始月・日を使う

```dart
// 集計開始月・開始日を取得してから渡す
final startMonth = await ref.read(aggregationStartMonthProvider).fetchAggregationStartMonth();
final startDay = await ref.read(aggregationStartDayProvider).fetchAggregationStartDay();
final period = await yearPeriodService
    .fetchYearPeriod(DateTime(year, startMonth.month, startDay.day));
```

必要なインポート:
```dart
import 'package:kakeibo/domain_service/year_period_service/aggregation_start_month_provider.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_start_day_provider.dart';
```

---

## パターン3: 「現在月度」の取り方（未来/過去の判定）

### ❌ やってはいけないパターン

```dart
// dateScope.aggregationMonthPeriod は selectedDate 由来
// 年度切替で selectedDate が年度開始日に正規化されると、
// 開始月以降が全部「未来」扱いになるバグになる
final currentMonthPeriod = dateScope.aggregationMonthPeriod;

if (queryPeriod.startDatetime.isAfter(currentMonthPeriod.endDatetime)) {
  type = MonthlyBalanceType.future;  // ← 過去年度のデータが全て future になる
}
```

**バグの再現**: 今日=2026/5/24 で 2025年度を選択
- `updateStateAsYear(2025)` → `selectedDate = 2025/4/1`
- `aggregationMonthPeriod = 2025/4月度`
- 2025/5〜2026/3 すべてが `startDatetime.isAfter(2025/4/30)` = true → future 判定

### ✅ 正しいパターン: systemDatetime から現在月度を導出

```dart
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';

// 「今日」を基準に現在月度を導出する（selectedDate とは無関係）
final systemDate = ref.read(systemDatetimeNotifierProvider);
final currentMonthPeriod = await monthPeriodService.fetchMonthPeriod(systemDate);

if (queryPeriod.startDatetime.isAfter(currentMonthPeriod.endDatetime)) {
  type = MonthlyBalanceType.future;  // ← 今日より後だけが future になる
}
```

**使い分けの判断基準**:
- 「今この瞬間より未来か」→ `systemDatetime` を使う
- 「ユーザーが選択中の月度か」→ `dateScope.aggregationMonthPeriod` を使う

---

## パターン4: 年度ラベルの表示

### ❌ やってはいけないパターン

```dart
// yearPeriod をまたぐと「2024年 - 2025年」のような2年並記になる
final label = '${dateScope.yearPeriod.startDatetime.year}年 - ${dateScope.yearPeriod.endDatetime.year}年';
```

### ✅ 正しいパターン: representativeYear を使う

```dart
// YearBasis 設定（デフォルト=start）に従って「2024年度」のように表示
final label = '${dateScope.representativeYear.year}年度';
```

`representativeYear.year` は String 型。
- `YearBasis.start`（デフォルト）: `yearPeriod.startDatetime.year` = 開始年 = 日本の会計年度慣例と一致
- `YearBasis.end`: `yearPeriod.endDatetime.year` = 終了年

実装: `lib/domain_service/year_period_service/aggregation_representative_year_service.dart`

---

## パターン5: 年度ピッカーのドラム項目ラベル計算

年度ドラムに「2025年4月〜2026年3月」のような年度範囲ラベルを表示するパターン。

```dart
String _formatYearItem(int year, int startMonth, int startDay) {
  // DateTime補正で月跨ぎ・年跨ぎが自動解決される
  // 例: DateTime(2026, 4, 0) = 2026/3/31
  final endDate = DateTime(year + 1, startMonth, startDay - 1);
  return '$year年$startMonth月〜${endDate.year}年${endDate.month}月';
}
```

**集計開始日=1 の場合（月初から）:**
- `DateTime(2026, 4, 0)` = 2026/3/31 → 終了月=3 → 「2025年4月〜2026年3月」

**集計開始日=25 の場合（月中から）:**
- `DateTime(2026, 4, 24)` = 2026/4/24 → 終了月=4 → 「2025年4月〜2026年4月」

**集計開始月=1、開始日=1 の場合（暦年）:**
- `DateTime(2026, 1, 0)` = 2025/12/31 → 終了年=2025、終了月=12 → 「2025年1月〜2025年12月」

---

## パターン6: 「今日が属する月度/年度」の正しい取り方

「今月度に戻す」「今年度に戻す」など、今日の日付が属する期間を取得する場面での落とし穴。

### ❌ やってはいけないパターン

```dart
// now.month や now.year を直接使う
final now = ref.read(systemDatetimeNotifierProvider);
final newYear = now.year;   // ← 集計開始月をまたぐと1年度ずれる
final newMonth = now.month; // ← 集計開始日をまたぐと1月度ずれる
```

**バグの例（月モード）**: 集計開始日=25、今日=2026/5/24
- `newMonth = 5`（5月）を `_computePeriod(2026, 5)` に渡す
- → `DateTime(2026, 6, 0)` = 5/31 → `fetchMonthPeriod(5/31)` → 5/25〜6/24（翌月度！）
- 「今月度に戻す」のに未来の月度が選択される

**バグの例（年モード）**: 集計開始月=9、今日=2026/5/24
- `newYear = 2026` → `fetchYearPeriod(2026/9/1)` → 2026年度（2026/9〜2027/8）
- 今日は2025年度（2025/9〜2026/8）に属するはずなのに次年度が選択される

### ✅ 正しいパターン: fetchMonthPeriod(now) / fetchYearPeriod(now) に now を直接渡す

```dart
Future<void> _onResetToCurrent() async {
  final now = ref.read(systemDatetimeNotifierProvider);

  if (mode == yearMonth) {
    // now が属する月度の開始月・年を取得して選択状態に反映
    final currentPeriod =
        await ref.read(monthPeriodServiceProvider).fetchMonthPeriod(now);
    final start = currentPeriod.startDatetime;
    // start.year / start.month が正しい選択年・月
  } else {
    // now が属する年度の開始年を取得して選択状態に反映
    final currentPeriod = await ref
        .read(yearPeriodServiceProvider)
        .fetchYearPeriod(now);
    // currentPeriod.startDatetime.year が正しい代表年
  }
}
```

**ポイント**:
- `now` をそのまま渡せば `fetchMonthPeriod` / `fetchYearPeriod` が集計設定を考慮して正しい期間を返してくれる
- 月度の選択状態に使うのは `currentPeriod.startDatetime.month`（末日ベースの `_computePeriod` の入力と一致する）
- 年度の選択状態に使うのは `currentPeriod.startDatetime.year`（representativeYear ではなく開始年で良い）
- 非同期関数になるため `if (!mounted) return;` を setState の前に忘れずに入れる

---

## 関連ファイル・サービス

| サービス | ファイル | 主なメソッド |
|---|---|---|
| `MonthPeriodService` | `lib/domain_service/month_period_service/month_period_service.dart` | `fetchMonthPeriod(date)` / `fetchShiftedMonthPeriod(period, shift)` |
| `YearPeriodService` | `lib/domain_service/year_period_service/month_period_service.dart` | `fetchYearPeriod(date)` |
| `AggregationRepresentativeYearService` | `lib/domain_service/year_period_service/aggregation_representative_year_service.dart` | `fetchYear(selectedDate)` → `YearValue` |
| `systemDatetimeNotifierProvider` | `lib/domain_service/system_datetime/system_datetime.dart` | アプリ起動時の「今日」を保持 |
| `aggregationStartMonthProvider` | `lib/domain_service/year_period_service/aggregation_start_month_provider.dart` | `fetchAggregationStartMonth()` |
| `aggregationStartDayProvider` | `lib/domain_service/month_period_service/aggregation_start_day_provider.dart` | `fetchAggregationStartDay()` |
