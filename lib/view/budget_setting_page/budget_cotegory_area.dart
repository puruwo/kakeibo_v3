import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/domain_service/month_period_service/period_status_service.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/budget_setting_page/budget_category_tile.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_budget_provider.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

class BudgetCategoryArea extends ConsumerWidget {
  const BudgetCategoryArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    // 期間ステータスを取得してラベルを動的に変更
    final dateScopeAsync = ref.watch(analyzePageDateScopeEntityProvider);
    final expenseLabel = dateScopeAsync.when(
      data: (dateScope) =>
          dateScope.periodStatus == PeriodStatus.current ? '先月の支出' : '当月の支出',
      loading: () => '先月の支出',
      error: (_, __) => '先月の支出',
    );

    return Column(
      children: [
        // 見出し「カテゴリー別予算」と、その右に凡例「先月の支出／今月の予算」を置く（仕様 §8.5）
        Padding(
          padding: EdgeInsets.fromLTRB(leftsidePadding, 8, leftsidePadding, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'カテゴリー別予算',
                  style: AppTextStyles.insetGroupHeader,
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  expenseLabel,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.listTileLegendTitle,
                ),
              ),
              SizedBox(
                width: 116,
                child: Text(
                  '今月の予算',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.listTileLegendTitle,
                ),
              ),
            ],
          ),
        ),

        //区切り線
        Divider(
          thickness: 0.25,
          height: 0.25,
          indent: leftsidePadding,
          endIndent: leftsidePadding,
          color: context.colors.separator,
        ),

        // リスト部分
        Expanded(
          child: ref
              .watch(resolvedBudgetEditValueProvider)
              .when(
                data: (valueList) {
                  return ListView.builder(
                    // コンテンツが収まる場合はスクロールしない、はみ出る場合はバウンス付きスクロール
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: valueList.length,
                    itemBuilder: (BuildContext context, int i) {
                      return BudgetCategoryTile(budgetEditValue: valueList[i]);
                    },
                  );
                },
                error: (Object error, StackTrace stackTrace) {
                  return const AppErrorState();
                },
                loading: () {
                  return const CircularProgressIndicator();
                },
              ),
        ),
      ],
    );
  }
}
