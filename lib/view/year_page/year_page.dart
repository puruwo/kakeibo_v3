/// Package imports
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

/// Local imports
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/year_page/annual_balance_chart/annual_balance_chart.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_area.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_button_area.dart';
import 'package:kakeibo/view/year_page/yearly_balance_area/yearly_balance_area.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/home_date_scope.dart';

class YearPage extends ConsumerStatefulWidget {
  const YearPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _YearPageState();
}

class _YearPageState extends ConsumerState<YearPage> {
  @override
  Widget build(BuildContext context) {
    //レイアウト------------------------------------------------------------------------------------

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Consumer(builder: (context, ref, _) {
          final activeDt = ref.watch(homeDateScopeEntityProvider).value!;
          final label = yyyyToyyyyGetter(activeDt);
          return Text(
            label,
            style: AppTextStyles.pageHeaderText,
          );
        }),
        actions: [
          IconButton(
              onPressed: () => {
                    // 設定画面にrootのNavigatorで遷移
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => const ConfigTop(),
                      ),
                    )
                  },
              icon: const Icon(Icons.settings_rounded)),
        ],
      ),
      backgroundColor: MyColors.secondarySystemBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.leftsidePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      ' 年間収支',
                      style: AppTextStyles.cardPrimaryTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const YearlyBalanceArea(),
              const SizedBox(
                height: 8,
              ),
              const FixedCostButtonArea(),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      ' ボーナス利用状況',
                      style: AppTextStyles.cardPrimaryTitle,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BonusHomePage(),
                            ),
                          );
                        },
                        child: Text(
                          'さらに表示する',
                          style: AppTextStyles.secondaryButtonText,
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const BonusPlanArea(),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      ' 生活収支',
                      style: AppTextStyles.cardPrimaryTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const AnnualBalanceChart(),
            ],
          ),
        ),
      ),
    );
  }
}
