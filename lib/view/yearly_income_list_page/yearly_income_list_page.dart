import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view/component/app_floating_action_button.dart';
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
  });

  final PeriodValue period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // extendBody:true によって MediaQuery.padding / viewPadding の bottom が
    // どちらも 0 にリセットされるため、View(FlutterView) から直接取得する
    final view = View.of(context);
    final bottomSafeArea = view.padding.bottom / view.devicePixelRatio;
    // FAB下端の位置: BottomNavigationBar高さ + デバイスセーフエリア + FAB標準マージン
    final fabBottom =
        kBottomNavigationBarHeight + bottomSafeArea + kFloatingActionButtonMargin;

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
        body: Stack(
          children: [
            ListView(
              children: [
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
                // FABがリスト末尾に被らないよう余白を確保
                // 可視余白 = FAB高さ(46) + FABマージン(kFABMargin=16) = 62dp
                SizedBox(height: fabBottom + 46),
              ],
            ),
            Positioned(
              right: 16,
              bottom: fabBottom,
              child: AppFloatingActionButton(
                icon: Icons.add_rounded,
                label: '収入を追加',
                onTap: () {
                  final today = ref.read(systemDatetimeNotifierProvider);
                  final newIncome = IncomeEntity(
                    date: DateFormat('yyyyMMdd').format(today),
                    categoryId: IncomeBigCategoryConstants.incomeSourceIdSalary,
                  );
                  showAppModalBottomSheet(
                    context,
                    child: RegisaterPageBase.addIncome(incomeEntity: newIncome),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
