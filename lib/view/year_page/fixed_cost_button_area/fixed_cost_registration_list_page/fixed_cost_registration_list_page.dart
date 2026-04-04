import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_category_cards_area.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class FixedCostRegistrationListPage extends ConsumerWidget {
  const FixedCostRegistrationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedCostListAsync = ref.watch(
      fixedCostRegistrationListNotifierProvider,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('固定費', style: AppTextStyles.pageHeaderText),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => {
              // 設定画面にrootのNavigatorで遷移
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const ConfigTop()),
              ),
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
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                    16,
                    16,
                  ),
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
                      showAppModalBottomSheet(
                        context,
                        child: const RegisaterPageBase.addFixedCost(),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error', style: AppTextStyles.errorMessage),
        ),
      ),
    );
  }
}
