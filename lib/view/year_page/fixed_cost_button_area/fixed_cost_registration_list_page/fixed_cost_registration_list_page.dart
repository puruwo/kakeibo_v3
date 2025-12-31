import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_category_cards_area.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class FixedCostRegistrationListPage extends ConsumerWidget {
  const FixedCostRegistrationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedCostListAsync =
        ref.watch(fixedCostRegistrationListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '固定費',
          style: AppTextStyles.pageHeaderText,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: 設定画面への遷移を実装
            },
          ),
        ],
      ),
      body: fixedCostListAsync.when(
        data: (fixedCostList) {
          if (fixedCostList.categoryGroups.isEmpty) {
            return Center(
              child: Text(
                '固定費が登録されていません',
                style: AppTextStyles.listEmptyMessage,
              ),
            );
          }

          return Column(
            children: [
              // カテゴリーカードのリスト（残りのスペースを全て使う）
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: fixedCostList.categoryGroups.length,
                  itemBuilder: (context, index) {
                    return FixedCostCategoryCardsArea(
                      group: fixedCostList.categoryGroups[index],
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // フッターボタンエリア（固定高さ）
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: MainButton(
                    buttonType: ButtonColorType.main,
                    buttonText: '固定費を追加',
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
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'エラーが発生しました: $error',
            style: AppTextStyles.errorMessage,
          ),
        ),
      ),
    );
  }
}
