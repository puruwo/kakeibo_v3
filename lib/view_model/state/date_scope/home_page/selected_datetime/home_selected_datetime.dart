import 'package:kakeibo/domain_service/month_period_service/aggregation_start_day_provider.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/domain_service/year_period_service/aggregation_start_month_provider.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_selected_datetime.g.dart';

@Riverpod(keepAlive: true)
class HomeSelectedDatetimeNotifier extends _$HomeSelectedDatetimeNotifier {
  @override
  DateTime build() {
    // 最初のデータ
    final now = ref.read(systemDatetimeNotifierProvider);
    return now;
  }

  void updateState(DateTime dateTime) {
    // データを上書き
    state = dateTime;
  }

  void updateToNextMonth() {
    state = state.addMonths(1);
  }

  void updateToPreviousMonth() {
    state = state.addMonths(-1);
  }

  /// 年を指定して、その年度の集計開始月・開始日に正規化してstateを更新する
  ///
  /// 集計開始月が4月・開始日が1日の場合、2025年を指定すると
  /// selectedDate = DateTime(2025, 4, 1) となり、年度として2025年度が選択される。
  Future<void> updateStateAsYear(int year) async {
    final startMonth = await ref
        .read(aggregationStartMonthProvider)
        .fetchAggregationStartMonth();
    final startDay = await ref
        .read(aggregationStartDayProvider)
        .fetchAggregationStartDay();
    state = DateTime(year, startMonth.month, startDay.day);
  }
}
