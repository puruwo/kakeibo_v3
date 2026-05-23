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
    return Scaffold(
        extendBodyBehindAppBar: true,
        floatingActionButton: Padding(
          // extendBody:true により内側のMediaQuery.padding.bottomが0になるため、
          // BottomNavigationBar(56dp) + デバイスセーフエリア(viewPadding.bottom) で底上げ
          padding: EdgeInsets.only(
            bottom: kBottomNavigationBarHeight +
                MediaQuery.of(context).viewPadding.bottom,
          ),
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
            // FABとBottomNavigationBar両方をクリアする末尾余白
            const SizedBox(height: kBottomNavigationBarHeight + 80),
          ],
        ));
  }
}
