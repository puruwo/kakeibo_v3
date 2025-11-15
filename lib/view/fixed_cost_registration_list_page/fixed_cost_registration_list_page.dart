import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/fixed_cost_registration_list_page/fixed_cost_category_cards_area.dart';

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
          style: GoogleFonts.notoSans(
            fontSize: 18,
            color: MyColors.white,
            fontWeight: FontWeight.w600,
          ),
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
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: MyColors.secondaryLabel,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }

          return Stack(
            children: [
              // カテゴリーカードのリスト
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: fixedCostList.categoryGroups.length,
                itemBuilder: (context, index) {
                  return FixedCostCategoryCardsArea(
                    group: fixedCostList.categoryGroups[index],
                  );
                },
              ),
              // 「固定費を追加」ボタン
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 固定費追加画面への遷移を実装
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.themeColor,
                    foregroundColor: MyColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '固定費を追加',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: MyColors.red,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
