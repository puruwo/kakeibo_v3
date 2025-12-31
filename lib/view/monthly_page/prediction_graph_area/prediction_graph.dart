import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_provider.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_widget.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph_text_styles.dart';

class PredictionGraph extends ConsumerWidget {
  const PredictionGraph({super.key, required this.dateScope});

  final DateScopeEntity dateScope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidthSize = MediaQuery.of(context).size.width;
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    final predictionGraphData =
        ref.watch(predictionGraphDataProvider(dateScope));

    return CardContainer(
      height: 240,
      width: 343 * screenHorizontalMagnification,
      child: predictionGraphData.when(
        data: (data) {
          if (data.predictionGraphLineType ==
              PredictionGraphLineType.futureMonth) {
            return const Center(
              child: Text(
                '選択月の支出の入力がありません',
                style: PredictionGraphTextStyles.message,
              ),
            );
          }
          return PredictionGraphWidget(data: data);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text(
            'エラーが発生しました',
            style: PredictionGraphTextStyles.message,
          ),
        ),
      ),
    );
  }
}
