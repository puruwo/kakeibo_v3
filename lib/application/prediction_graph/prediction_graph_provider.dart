import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_usecase.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 予測グラフのデータを提供するプロバイダー
final predictionGraphDataProvider =
    FutureProvider.family<PredictionGraphValue, DateScopeEntity>(
  (ref, dateScope) async {
    // DB更新カウントを監視して、データの変更を検知する
    ref.watch(updateDBCountNotifierProvider);
    
    final usecase = ref.read(predictionGraphUsecaseProvider);
    return await usecase.fetchPredictionGraphData(dateScope);
  },
);
