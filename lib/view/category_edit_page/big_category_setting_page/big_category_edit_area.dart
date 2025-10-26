/// packegeImport
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/domain/ui_value/fixed_cost_category_value/edit_fixed_cost_category_value.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/component/check_box.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/editting_big_category_list/editting_big_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/is_big_category_list_edited/is_big_category_list_edited.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_edit_page/editting_fixed_cost_category_list/editting_fixed_cost_category_list.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_edit_page/is_fixed_cost_category_list_edited/is_fixed_cost_category_list_edited.dart';

class BigCategoryEditArea extends ConsumerStatefulWidget {
  const BigCategoryEditArea({
    super.key,
    required this.categoryType,
  });

  final CategoryType categoryType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryEditAreaState();
}

class _BigCategoryEditAreaState extends ConsumerState<BigCategoryEditArea> {
  @override
  void initState() {
    super.initState();

    // 取得したデータを編集用プロバイダーに格納
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future(() async {
        if (widget.categoryType == CategoryType.expense) {
          final initialList =
              await ref.read(allBigCategoriesWithSmallListProvider.future);
          ref
              .read(edittingBigCategoryListNotifierProvider.notifier)
              .setData(initialList);
        } else {
          // 固定費カテゴリーの場合
          final categories =
              await ref.read(allFixedCostCategoriesProvider.future);
          final editList = categories.map((category) {
            return EditFixedCostCategoryValue(
              id: category.id,
              name: category.categoryName,
              colorCode: category.colorCode,
              resourcePath: category.resourcePath,
              displayOrder: category.displayOrder,
              isDisplayed: category.isDisplayed,
              editedStateDisplayOrder: category.displayOrder,
              editedStateIsChecked: category.isDisplayed == 1,
            );
          }).toList();
          ref
              .read(edittingFixedCostCategoryListNotifierProvider.notifier)
              .setData(editList);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // リスト内テキストボックスの拡大部を計算
    final listSTextBoxOffset = listSmallcategoryMemoOffsetGetter() / 2;

    // 左のpaddingの大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    if (widget.categoryType == CategoryType.expense) {
      return _buildExpenseCategoryEditArea(leftsidePadding, listSTextBoxOffset);
    } else {
      return _buildFixedCostCategoryEditArea(leftsidePadding, listSTextBoxOffset);
    }
  }

  // 一般カテゴリーの編集エリア
  Widget _buildExpenseCategoryEditArea(
      double leftsidePadding, double listSTextBoxOffset) {
    final itemList = ref.watch(edittingBigCategoryListNotifierProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      '表示',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    SizedBox(
                      width: 110 + listSTextBoxOffset,
                      child: Text(
                        'カテゴリー',
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: MyColors.secondaryLabel,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Text(
                      '項目',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Text(
                '並べ替え',
                style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: MyColors.secondaryLabel,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),

        //区切り線
        Divider(
          thickness: 0.25,
          height: 0.25,
          indent: leftsidePadding,
          endIndent: leftsidePadding,
          color: MyColors.separater,
        ),

        // リスト部分
        Expanded(
            child: ReorderableListView.builder(
          // デフォルトの並べ替えアイコン
          buildDefaultDragHandles: false,
          // 並べ替えた時の処理
          onReorder: (oldIndex, newIndex) {
            // カテゴリーの状態を保持しているリストの並び替え
            ref
                .read(edittingBigCategoryListNotifierProvider.notifier)
                .reorder(oldIndex, newIndex);

            // 変更を加えたことを管理する状態管理する
            ref
                .read(isBigCategoryListEditedNotifierProvider.notifier)
                .updateState(true);
          },
          itemCount: itemList.length,
          itemBuilder: (BuildContext context, int index) {
            // 並べ替え可能なリストのアイテム
            return Column(
              key: Key('$index'),
              children: [
                // リスト本体
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // チェックボックス
                        Padding(
                          padding: const EdgeInsets.all(12.5),
                          child: GestureDetector(
                            onTap: () {
                              // チェックボックスのタップ処理
                              setState(() {
                                // チェックボックスの状態を更新する
                                ref
                                    .read(
                                        edittingBigCategoryListNotifierProvider
                                            .notifier)
                                    .toggleDisplay(index);
                                // 変更を加えたことを管理する状態管理する
                                ref
                                    .read(
                                        isBigCategoryListEditedNotifierProvider
                                            .notifier)
                                    .updateState(true);
                              });
                            },
                            child: CheckBox(
                                isChecked:
                                    itemList[index].etitedStateIsChecked),
                          ),
                        ),

                        // アイコン
                        Padding(
                          padding: const EdgeInsets.all(12.5),
                          child: SvgPicture.asset(
                            itemList[index].resourcePath,
                            colorFilter: ColorFilter.mode(
                                MyColors()
                                    .getColorFromHex(itemList[index].colorCode),
                                BlendMode.srcIn),
                            semanticsLabel: 'categoryIcon',
                            width: 25,
                            height: 25,
                          ),
                        ),

                        // カテゴリー名
                        SizedBox(
                          width: 72 + listSTextBoxOffset,
                          child: Text(
                            itemList[index].bigCategoryName,
                            style: GoogleFonts.notoSans(
                                fontSize: 18,
                                color: MyColors.label,
                                fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 小カテゴリー列挙
                        SizedBox(
                          width: 120 + listSTextBoxOffset,
                          child: Text(
                            itemList[index].expenseSmallCategoryNameText,
                            style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: MyColors.secondaryLabel,
                                fontWeight: FontWeight.w300),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 並べ替えアイコン
                        ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            alignment: Alignment.centerRight,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.drag_handle_rounded,
                              color: MyColors.systemGray2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //区切り線
                Divider(
                  thickness: 0.25,
                  height: 0.25,
                  indent: leftsidePadding + 50,
                  endIndent: leftsidePadding,
                  color: MyColors.separater,
                ),
              ],
            );
          },
        )),
      ],
    );
  }

  // 固定費カテゴリーの編集エリア
  Widget _buildFixedCostCategoryEditArea(
      double leftsidePadding, double listSTextBoxOffset) {
    final itemList = ref.watch(edittingFixedCostCategoryListNotifierProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      '表示',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 110 + listSTextBoxOffset,
                      child: Text(
                        'カテゴリー',
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: MyColors.secondaryLabel,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '並べ替え',
                style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: MyColors.secondaryLabel,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),

        //区切り線
        Divider(
          thickness: 0.25,
          height: 0.25,
          indent: leftsidePadding,
          endIndent: leftsidePadding,
          color: MyColors.separater,
        ),

        // リスト部分
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(edittingFixedCostCategoryListNotifierProvider.notifier)
                  .reorder(oldIndex, newIndex);

              ref
                  .read(isFixedCostCategoryListEditedNotifierProvider.notifier)
                  .updateState(true);
            },
            itemCount: itemList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                key: Key('$index'),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // チェックボックス
                          Padding(
                            padding: const EdgeInsets.all(12.5),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  ref
                                      .read(
                                          edittingFixedCostCategoryListNotifierProvider
                                              .notifier)
                                      .toggleDisplay(index);
                                  ref
                                      .read(
                                          isFixedCostCategoryListEditedNotifierProvider
                                              .notifier)
                                      .updateState(true);
                                });
                              },
                              child: CheckBox(
                                  isChecked:
                                      itemList[index].editedStateIsChecked),
                            ),
                          ),

                          // アイコン
                          Padding(
                            padding: const EdgeInsets.all(12.5),
                            child: SvgPicture.asset(
                              itemList[index].resourcePath,
                              colorFilter: ColorFilter.mode(
                                  MyColors()
                                      .getColorFromHex(itemList[index].colorCode),
                                  BlendMode.srcIn),
                              semanticsLabel: 'categoryIcon',
                              width: 25,
                              height: 25,
                            ),
                          ),

                          // カテゴリー名
                          Expanded(
                            child: Text(
                              itemList[index].name,
                              style: GoogleFonts.notoSans(
                                  fontSize: 18,
                                  color: MyColors.label,
                                  fontWeight: FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // 並べ替えアイコン
                          ReorderableDragStartListener(
                            index: index,
                            child: Container(
                              alignment: Alignment.centerRight,
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.drag_handle_rounded,
                                color: MyColors.systemGray2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //区切り線
                  Divider(
                    thickness: 0.25,
                    height: 0.25,
                    indent: leftsidePadding + 50,
                    endIndent: leftsidePadding,
                    color: MyColors.separater,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  double listSmallcategoryMemoOffsetGetter() {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return defaultWidth < 0 ? 0 : context.screenWidth - defaultWidth;
  }
}
