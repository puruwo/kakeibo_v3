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
import 'package:kakeibo/view/component/app_contents_header.dart';

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
          final asyncValue = ref.watch(homeDateScopeEntityProvider);
          return asyncValue.when(
            data: (activeDt) => Text(
              yyyyToyyyyGetter(activeDt),
              style: AppTextStyles.pageHeaderText,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
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
              const AppContentsHeader(title: '年間収支'),
              const YearlyBalanceArea(),
              const SizedBox(
                height: 8,
              ),
              const FixedCostButtonArea(),
              const SizedBox(
                height: 16,
              ),
              AppContentsHeader(
                title: 'ボーナス利用状況',
                subLabel: 'さらに表示する',
                isLinkable: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BonusHomePage(),
                    ),
                  );
                },
              ),
              const BonusPlanArea(),
              const SizedBox(
                height: 16,
              ),
              const AppContentsHeader(title: '生活収支'),
              const AnnualBalanceChart(),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
