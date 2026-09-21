import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/category_detail_edit_page.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/category_expence_history_list_area.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/expanded_category_sum_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_category_tile_entity_provider.dart';
import 'package:kakeibo/view_model/state/page_mode_controller/page_mode.dart';

/// カテゴリーのホーム画面（大カテゴリー支出履歴。KP-027 で「カテゴリー別利用状況」から作り替え）
///
/// タイトルはアイコン＋カテゴリー名。AppBar 右の歯車でこのカテゴリーの設定へ、
/// 集計タイルの「予算を設定」でこのカテゴリーの予算入力シートへ進める。
class CategoryExpenseHistoryPage extends ConsumerWidget {
  const CategoryExpenseHistoryPage({super.key, required this.bigId});
  final int bigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // タイトル用のカテゴリー名。読み込み中・取得失敗のときは名前を出さない
    final category = ref
        .watch(resolvedCategoryTileEntityProvider(bigId))
        .valueOrNull
        ?.monthlyExpenseByCategoryEntity;

    return Scaffold(
      // 地は AppTheme の scaffoldBackgroundColor（surface）。カード地 card-surface と同色になる surfaceElevated を明示しない（KP-013）
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: category == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CategoryHandler().sisytIconGetterFromBigCategoryKey(
                    category.id,
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      category.bigCategoryName,
                      style: context.textStyles.pageHeaderText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
        // このカテゴリーの設定（大カテゴリー詳細編集）への入口
        actions: [
          IconButton(
            tooltip: 'カテゴリーの設定',
            icon: Icon(AppIcons.settings, color: context.colors.text),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CategoryDetailEditPage(
                  screenMode: BigCategoryDetailEditScreenMode.edit,
                  categoryType: CategoryType.expense,
                  bigCategoryId: bigId,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ExpandedCategoryTile(
              bigId: bigId,
            ),
          ),
          CategoryExpenceHistoryArea(
              listAreaMode: ListAreaMode.bigCategory, bigId: bigId),
        ],
      ),
    );
  }
}
