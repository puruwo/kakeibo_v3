import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_provider.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

final resolvedPredictionGraphValueProvider =
    FutureProvider<PredictionGraphValue?>((ref) async {
  
  // 選択された日付から集計期間を取得する
  final dateScope = await ref.watch(analyzePageDateScopeEntityProvider.selectAsync((dateScope) => dateScope));

  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(predictionGraphDataProvider(dateScope).future);
  return result;
});
