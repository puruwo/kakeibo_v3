// packageImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// LocalImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/add_complete_button/add_complete_big_category_detail_button.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/cotegory_appearance_edit_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/small_category_edit_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/update_complete_button/update_complete_big_category_detail_button.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/fixed_cost_category_appearance_edit_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/add_complete_button/add_complete_fixed_cost_category_detail_button.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/update_complete_button/update_complete_fixed_cost_category_detail_button.dart';

import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_big_category_appearance_edited/is_big_category_appearance_edited.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/page_mode_controller/page_mode.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_name_controller/fixed_cost_category_name_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_icon_controller/fixed_cost_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_color_controller/fixed_cost_category_color_controller.dart';

class CategoryDetailEditPage extends ConsumerStatefulWidget {
  const CategoryDetailEditPage({
    super.key,
    required this.screenMode,
    required this.categoryType,
    this.bigCategoryId,
    this.categoryOrder,
  });
  final int? bigCategoryId;
  final int? categoryOrder;
  final BigCategoryDetailEditScreenMode screenMode;
  final CategoryType categoryType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryDetailEditPage();
}

class _BigCategoryDetailEditPage extends ConsumerState<CategoryDetailEditPage> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,

        // ヘッダー
        appBar: AppBar(
          title: Text(
            'カテゴリーの設定',
            style: AppTextStyles.pageHeaderText,
          ),

          backgroundColor: MyColors.secondarySystemBackground,
          //ヘッダー左のアイコンボタン
          leading: IconButton(
              // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.categoryType == CategoryType.expense) {
                  ref.invalidate(isBigCategoryAppearanceEditedNotifierProvider);
                  ref.invalidate(isSmallCategoryListEditedNotifierProvider);
                  ref.invalidate(edittingSmallCategoryListNotifierProvider);
                } else {
                  ref.invalidate(
                      fixedCostCategoryNameControllerNotifierProvider);
                  ref.invalidate(
                      fixedCostCategoryIconControllerNotifierProvider);
                  ref.invalidate(
                      fixedCostCategoryColorControllerNotifierProvider);
                }
              },
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: MyColors.white)),
          //ヘッダー右のアイコンボタン
          actions: [
            _buildActionButton(),
          ],
        ),

        // 本体
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildAppearanceEditArea(),

            // 余白（固定費の場合は不要）
            if (widget.categoryType == CategoryType.expense)
              const SizedBox(height: 8.0),

            // 小カテゴリーのリスト（固定費の場合は表示しない）
            if (widget.categoryType == CategoryType.expense)
              SmallCategoryEditArea(
                bigId: widget.bigCategoryId ?? -1,
              ),
          ],
        ),
      ),
    );
  }

  // アクションボタン（追加/完了ボタン）を構築
  Widget _buildActionButton() {
    if (widget.categoryType == CategoryType.expense) {
      return widget.screenMode == BigCategoryDetailEditScreenMode.edit
          ? UpdateCompleteBigCategoryDetailButton(
              bigId: widget.bigCategoryId!,
            )
          : AddCompleteBigCategoryDetailButton(
              categoryOrder: widget.categoryOrder!,
            );
    } else {
      return widget.screenMode == BigCategoryDetailEditScreenMode.edit
          ? UpdateCompleteFixedCostCategoryDetailButton(
              fixedCostCategoryId: widget.bigCategoryId!,
            )
          : AddCompleteFixedCostCategoryDetailButton(
              categoryOrder: widget.categoryOrder!,
            );
    }
  }

  // 外観編集エリア（アイコン・色・名前）を構築
  Widget _buildAppearanceEditArea() {
    if (widget.categoryType == CategoryType.expense) {
      return CategoryAppearanceEditArea(
        bigId: widget.bigCategoryId ?? -1,
        categoryType: widget.categoryType,
      );
    } else {
      return FixedCostCategoryAppearanceEditArea(
        fixedCostCategoryId: widget.bigCategoryId ?? -1,
      );
    }
  }
}
