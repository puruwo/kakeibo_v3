import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/fixed_cost_summary_header.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/fixed_cost_by_category_list_area.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';

class MonthlyFixedCostPage extends ConsumerWidget {
  const MonthlyFixedCostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          '固定費',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ヘッダー
                  FixedCostSummaryHeader(),

                  // カテゴリー別リスト
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    child: FixedCostByCategoryListArea(),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // フッターボタンエリア
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Row(
              children: [
                // 固定費を管理ボタン
                Expanded(
                  child: MainButton(
                    buttonType: ButtonColorType.secondary,
                    buttonText: '固定費を管理',
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: ((context) =>
                              const FixedCostRegistrationListPage())));
                    },
                  ),
                ),

                // 間の隙間
                const SizedBox(
                  width: 8,
                ),

                // 固定費を新しく登録する
                Expanded(
                  child: MainButton(
                    buttonType: ButtonColorType.main,
                    buttonText: '固定費を登録',
                    onPressed: () {
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
