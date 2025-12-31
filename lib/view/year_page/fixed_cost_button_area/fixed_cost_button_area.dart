import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class FixedCostButtonArea extends StatelessWidget {
  const FixedCostButtonArea({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: FixedCostManagePageButton(),
        ),
        SizedBox(
          width: 8,
        ),
        FixedCostAddButton(),
      ],
    );
  }
}

class FixedCostManagePageButton extends StatelessWidget {
  const FixedCostManagePageButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      color: MyColors.quarternarySystemfill,
      borderRadius: BorderRadius.circular(50.0),
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => const FixedCostRegistrationListPage())));
      },
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '固定費一覧',
                style: AppTextStyles.cardSecondaryTitle,
              ),
              const Icon(
                size: 16,
                Icons.arrow_forward_ios_rounded,
                color: MyColors.secondaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FixedCostAddButton extends StatelessWidget {
  const FixedCostAddButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: () {
        showModalBottomSheet(
          //sccafoldの上に出すか
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          constraints: const BoxConstraints(
            maxWidth: 2000,
          ),
          context: context,
          // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
          builder: (context) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark(),
              themeMode: ThemeMode.dark,
              darkTheme: ThemeData.dark(),
              home: MediaQuery.withClampedTextScaling(
                // テキストサイズの制御
                minScaleFactor: 0.7,
                maxScaleFactor: 0.95,
                child: const RegisaterPageBase.addFixedCost(),
              ),
            );
          },
        );
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: MyColors.quarternarySystemfill,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: const Icon(
          size: 18,
          Icons.add_rounded,
          color: MyColors.secondaryLabel,
        ),
      ),
    );
  }
}
