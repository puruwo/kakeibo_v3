// packageImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// LocalImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/add_complete_big_category_detail_button.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/big_cotegory_appearance_edit_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/small_category_edit_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/submit_big_category_detail_button.dart';

import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/page_mode_controller/page_mode.dart';

class BigCategoryDetailEditPage extends ConsumerStatefulWidget {
  const BigCategoryDetailEditPage(
      {super.key,
      required this.screenMode,
      this.bigCategoryId,
      this.categoryOrder});
  final int? bigCategoryId;
  final int? categoryOrder;
  final BigCategoryDetailEditScreenMode screenMode;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryDetailEditPage();
}

class _BigCategoryDetailEditPage
    extends ConsumerState<BigCategoryDetailEditPage> {
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
            style: MyFonts.pageHeaderText,
          ),

          backgroundColor: MyColors.secondarySystemBackground,
          //ヘッダー左のアイコンボタン
          leading: IconButton(
              // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
              onPressed: () {
                Navigator.of(context).pop();
                ref.invalidate(isSmallCategoryListEditedNotifierProvider);
                ref.invalidate(edittingSmallCategoryListNotifierProvider);
              },
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: MyColors.white)),
          //ヘッダー右のアイコンボタン
          actions: [
            widget.screenMode == BigCategoryDetailEditScreenMode.edit
                ? UpdateCompleteBigCategoryDetailButton(
                    bigId: widget.bigCategoryId!,
                  )
                : AddCompleteBigCategoryDetailButton(
                    categoryOrder: widget.categoryOrder!,
                  ),
          ],
        ),

        // 本体
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            BigCategoryAppearanceEditArea(bigId: widget.bigCategoryId ?? -1),

            // 余白
            const SizedBox(height: 8.0),

            // 小カテゴリーのリスト
            SmallCategoryEditArea(
              bigId: widget.bigCategoryId ?? -1,
            ),
          ],
        ),
      ),
    );
  }
}
