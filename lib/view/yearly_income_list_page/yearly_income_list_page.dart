import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view/component/app_fab_stack.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/yearly_income_list_page/income_graph_area.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_list_area.dart';

class YearlyIncomeListPage extends ConsumerWidget {
  const YearlyIncomeListPage({
    super.key,
    required this.period,
    this.initiallyExpandAll = false,
  });

  final PeriodValue period;

  /// 月別アコーディオンを初回から全月開いた状態にするか（単月で開くときに true）
  final bool initiallyExpandAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fabBottom = fabBottomOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('収入一覧', style: context.textStyles.pageHeaderText),
      ),
      body: AppFabStack(
        fabLabel: '収入を追加',
        onFabTap: () {
          final today = ref.read(systemDatetimeNotifierProvider);
          final newIncome = IncomeEntity(
            date: DateFormat('yyyyMMdd').format(today),
            // 初期選択は小カテゴリー「給与」（大カテゴリーIDではなく小カテゴリーID）
            categoryId: IncomeSmallCategoryConstants.salary,
          );
          showAppModalBottomSheet(
            context,
            child: RegisaterPageBase.addIncome(incomeEntity: newIncome),
          );
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                // extendBodyBehindAppBar:true のとき padding.top はステータスバー高さのみ。
                // AppBar(kToolbarHeight)分も加算してカードをAppBar下端に揃える。
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                  16,
                  0,
                ),
                child: IncomeGraphArea(period: period),
              ),
            ),
            SliverToBoxAdapter(
              child: YearlyIncomeListArea(
                period: period,
                initiallyExpandAll: initiallyExpandAll,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ),
            // コンテンツが短いときは残りスペースを静かに埋める（余分なスクロールなし）
            // コンテンツが長いときはFAB + マージン分の余白だけ確保する
            SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(height: fabBottom + 46),
            ),
          ],
        ),
      ),
    );
  }
}
