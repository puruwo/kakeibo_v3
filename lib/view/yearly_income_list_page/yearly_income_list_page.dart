import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/view/yearly_income_list_page/income_graph_area.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_list_area.dart';

class YearlyIncomeListPage extends ConsumerWidget {
  const YearlyIncomeListPage({
    super.key,
    required this.period,
  });

  final PeriodValue period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: const GlassAppBarBackground(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '収入一覧',
            style: AppTextStyles.pageHeaderText,
          ),
        ),
        body: ListView(
          children: [
            // AppBarのぶんだけスペースをあける
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: IncomeGraphArea(
                period: period,
              ),
            ),
            YearlyIncomeListArea(
              period: period,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ],
        ));
  }
}
