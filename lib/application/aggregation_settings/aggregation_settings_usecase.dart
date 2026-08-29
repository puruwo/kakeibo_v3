import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain_service/system_datetime/date_scope.dart';
import 'package:kakeibo/model/aggregation_settings_store.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/historical_date_scope.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/home_date_scope.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 集計開始日の下限・上限（29日以降は存在しない月があるため設定不可）
const int kAggregationStartDayMin = 1;
const int kAggregationStartDayMax = 28;

/// 集計開始月の下限・上限
const int kAggregationStartMonthMin = 1;
const int kAggregationStartMonthMax = 12;

final aggregationSettingsUsecaseProvider =
    Provider<AggregationSettingsUsecase>(AggregationSettingsUsecase.new);

class AggregationSettingsUsecase {
  AggregationSettingsUsecase(this._ref);
  final Ref _ref;

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get _updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// 現在の集計開始日・開始月を取得する
  Future<({int startDay, int startMonth})> fetch() async {
    final store = AggregationSettingsStore();
    final startDay = await store.fetchStartDay();
    final startMonth = await store.fetchStartMonth();
    return (startDay: startDay, startMonth: startMonth);
  }

  /// 集計開始日・開始月を保存し、全画面の集計期間を再計算させる
  Future<void> save({required int startDay, required int startMonth}) async {
    //エラーチェック
    // 29〜31日は存在しない月があるため設定不可とする
    if (startDay < kAggregationStartDayMin || startDay > kAggregationStartDayMax) {
      throw const AppException('開始日は1〜28日の間で設定してください');
    }
    if (startMonth < kAggregationStartMonthMin ||
        startMonth > kAggregationStartMonthMax) {
      throw const AppException('開始月は1〜12月の間で設定してください');
    }

    final store = AggregationSettingsStore();
    await store.saveStartDay(startDay);
    await store.saveStartMonth(startMonth);

    // 集計はすべて都度計算のため、日付スコープを破棄すると
    // 過去の記録も含めて新しい区切りで再計算される
    _ref.invalidate(systemDateScopeEntityProvider);
    _ref.invalidate(homeDateScopeEntityProvider);
    _ref.invalidate(analyzePageDateScopeEntityProvider);
    _ref.invalidate(historicalDateScopeEntityProvider);

    // DBの更新回数をインクリメントして各画面を再取得させる
    _updateDBCountNotifier.incrementState();
  }
}
