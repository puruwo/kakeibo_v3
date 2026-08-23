import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/i_monthly_fixed_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';

/// 固定費タイル1件ぶんの組み立て結果
///
/// タイルValueに加えて、グルーピングに使う支出大カテゴリーidと
/// 集計に使う実効金額を持つ。
class MonthlyFixedCostTileEntry {
  const MonthlyFixedCostTileEntry({
    required this.expenseBigCategoryId,
    required this.bigCategoryName,
    required this.colorCode,
    required this.resourcePath,
    required this.tile,
    required this.isConfirmed,
    required this.amount,
  });

  /// 支出大カテゴリーid（グルーピングの単位。仕様 §8.3）
  final int expenseBigCategoryId;
  final String bigCategoryName;
  final String colorCode;
  final String resourcePath;

  /// 画面に渡すタイルValue（確定／未確定のどちらか）
  final IMonthlyFixedTileValue tile;

  /// 確定済みか（expense.is_confirmed = 1）
  final bool isConfirmed;

  /// 実効金額（確定＝price／未確定＝estimated_price）
  final int amount;
}

final monthlyFixedCostTileServiceProvider =
    Provider<MonthlyFixedCostTileService>(MonthlyFixedCostTileService.new);

/// expenseの固定費行から月次固定費ビュー用のタイルValueを組み立てるサービス
///
/// v10でデータ源が fixed_cost_record から expense に移り、
/// グルーピングも固定費カテゴリーから支出カテゴリー（大→小）基準になった。
/// 6つの read ユースケースが同じ組み立てを使うため、ここに集約する。
class MonthlyFixedCostTileService {
  MonthlyFixedCostTileService(this._ref);

  final Ref _ref;

  ExpenseRepository get _expenseRepo => _ref.read(expenseRepositoryProvider);

  FixedCostRepository get _fixedCostRepo =>
      _ref.read(fixedCostRepositoryProvider);

  ExpenseSmallCategoryRepository get _smallCategoryRepo =>
      _ref.read(expenseSmallCategoryRepositoryProvider);

  ExpenseBigCategoryRepository get _bigCategoryRepo =>
      _ref.read(expensebigCategoryRepositoryProvider);

  /// 期間内の固定費行をタイルValueに変換する（日付昇順・id昇順）
  Future<List<MonthlyFixedCostTileEntry>> fetchEntries({
    required PeriodValue period,
  }) async {
    // 固定費行（fixed_cost_id IS NOT NULL）を期間で取得する
    final rows = await _expenseRepo.fetchFixedCostRecordByPeriod(
      period: period,
    );
    if (rows.isEmpty) return [];

    // 小カテゴリー → (名称・大カテゴリーid) の対応表
    final smallCategories = await _smallCategoryRepo.fetchAll();
    final smallCategoryMap = {for (final s in smallCategories) s.id: s};

    // 大カテゴリー情報（表示順つき）
    final bigCategories = await _bigCategoryRepo.fetchAll();
    final bigCategoryMap = <int, ExpenseBigCategoryEntity>{
      for (final b in bigCategories) b.id: b,
    };

    // 同じマスタを何度も引かないようにキャッシュする
    final masterCache = <int, FixedCostEntity>{};

    final entries = <MonthlyFixedCostTileEntry>[];

    for (final row in rows) {
      final fixedCostId = row.fixedCostId;
      if (fixedCostId == null) continue;

      final master =
          masterCache[fixedCostId] ??=
              await _fixedCostRepo.fetch(fixedCostId: fixedCostId);

      final small = smallCategoryMap[row.paymentCategoryId];
      final big = small == null ? null : bigCategoryMap[small.bigCategoryKey];

      // 支払い頻度のラベルを取得するために、valueを生成
      final frequencyValue = PaymentFrequencyValue.fromDB(
        intervalNumber: master.intervalNumber,
        intervalUnitNumber: master.intervalUnit,
      );

      final date = DateTime(
        int.parse(row.date.substring(0, 4)),
        int.parse(row.date.substring(4, 6)),
        int.parse(row.date.substring(6, 8)),
      );

      final categoryName = big?.bigCategoryName ?? '';
      final colorCode = big?.colorCode ?? '';
      final resourcePath = big?.resourcePath ?? '';
      final smallCategoryName = small?.smallCategoryName ?? '';

      final IMonthlyFixedTileValue tile;
      if (row.isConfirmed == 1) {
        tile = MonthlyConfirmedFixedCostTileValue(
          // タイルのidはexpense行のid（確定・編集・削除の対象を直接指す）
          id: row.id,
          date: date,
          price: row.effectivePrice,
          name: row.memo,
          variable: master.variable,
          intervalNumber: master.intervalNumber,
          intervalUnit: master.intervalUnit,
          nextPaymentDate: master.nextPaymentDate,
          categoryName: categoryName,
          smallCategoryName: smallCategoryName,
          colorCode: colorCode,
          resourcePath: resourcePath,
          frequencyLabel: frequencyValue.dateLabel,
        );
      } else {
        tile = MonthlyUnconfirmedFixedCostTileValue(
          // タイルのidはexpense行のid（確定操作がこの行を更新する）
          id: row.id,
          date: date,
          // 確定後の推定額の再計算にマスタのidが要るため別に持つ
          fixedCostId: fixedCostId,
          name: row.memo,
          variable: master.variable,
          // 予想額は行が持つ値を優先する（同期漏れがあってもタイルと集計がズレない）
          estimatedPrice: row.estimatedPrice ?? master.estimatedPrice,
          intervalNumber: master.intervalNumber,
          intervalUnit: master.intervalUnit,
          nextPaymentDate: master.nextPaymentDate,
          categoryName: categoryName,
          smallCategoryName: smallCategoryName,
          colorCode: colorCode,
          resourcePath: resourcePath,
          frequencyLabel: frequencyValue.dateLabel,
        );
      }

      entries.add(
        MonthlyFixedCostTileEntry(
          expenseBigCategoryId: small?.bigCategoryKey ?? 0,
          bigCategoryName: categoryName,
          colorCode: colorCode,
          resourcePath: resourcePath,
          tile: tile,
          isConfirmed: row.isConfirmed == 1,
          amount: row.effectivePrice,
        ),
      );
    }

    return entries;
  }
}
