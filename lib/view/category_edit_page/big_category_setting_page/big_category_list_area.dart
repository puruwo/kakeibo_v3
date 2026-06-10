/// packegeImport
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';

/// localImport
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/category_detail_edit_page.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/page_mode_controller/page_mode.dart';

class BigCategoryListArea extends ConsumerStatefulWidget {
  const BigCategoryListArea({super.key, required this.categoryType});

  final CategoryType categoryType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryListAreaState();
}

class _BigCategoryListAreaState extends ConsumerState<BigCategoryListArea> {
  @override
  Widget build(BuildContext context) {
    // リスト内テキストボックスの拡大部を計算
    final listSTextBoxOffset =
        listSmallcategoryMemoOffsetGetter(context.screenWidth) / 2;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    // カテゴリータイプに応じて表示を切り替え
    if (widget.categoryType == CategoryType.expense) {
      return _buildExpenseCategoryList(leftsidePadding, listSTextBoxOffset);
    } else if (widget.categoryType == CategoryType.income) {
      return _buildIncomeCategoryList(leftsidePadding, listSTextBoxOffset);
    } else {
      return _buildFixedCostCategoryList(leftsidePadding, listSTextBoxOffset);
    }
  }

  // 収入カテゴリーリスト
  Widget _buildIncomeCategoryList(
    double leftsidePadding,
    double listSTextBoxOffset,
  ) {
    return ref
        .watch(allIncomeBigCategoriesWithSmallListProvider)
        .when(
          data: (itemList) {
            return Column(
              children: [
                // ヘッダーまでの余白
                SizedBox(height: 8),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: SizedBox(
                              width: 37 + 90 + listSTextBoxOffset,
                              child: Text(
                                'カテゴリー',
                                style: AppTextStyles.listTileLegendTitle,
                              ),
                            ),
                          ),
                          Text('項目', style: AppTextStyles.listTileLegendTitle),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '詳細',
                          style: AppTextStyles.listTileLegendTitle,
                        ),
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
                  color: context.colors.separator,
                ),

                // リスト部分
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: itemList.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < itemList.length) {
                        return AppInkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => CategoryDetailEditPage(
                                  screenMode:
                                      BigCategoryDetailEditScreenMode.edit,
                                  categoryType: CategoryType.income,
                                  bigCategoryId: itemList[index].id,
                                )),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: leftsidePadding,
                                ),
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    key: Key('$index'),
                                    children: [
                                      // アイコン
                                      Padding(
                                        padding: const EdgeInsets.all(12.5),
                                        child: SvgPicture.asset(
                                          itemList[index].resourcePath,
                                          colorFilter: ColorFilter.mode(
                                            MyColors().getColorFromHex(
                                              itemList[index].colorCode,
                                            ),
                                            BlendMode.srcIn,
                                          ),
                                          semanticsLabel: 'categoryIcon',
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),

                                      // カテゴリー名
                                      SizedBox(
                                        width: 90 + listSTextBoxOffset,
                                        child: Text(
                                          itemList.isEmpty
                                              ? ''
                                              : itemList[index].bigCategoryName,
                                          style: AppTextStyles
                                              .listTilePrimaryTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // 項目の列挙
                                      Expanded(
                                        child: Text(
                                          itemList.isEmpty
                                              ? ''
                                              : itemList[index]
                                                    .incomeSmallCategoryNameText,
                                          style: AppTextStyles
                                              .listTileSecondaryTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // 進むアイコン
                                      const Padding(
                                        padding: EdgeInsets.all(12.5),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                          color: MyColors.white,
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
                                color: context.colors.separator,
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 末尾の追加Widget
                        return AppInkWell(
                          key: Key('$index'),
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailEditPage(
                                  screenMode: BigCategoryDetailEditScreenMode
                                      .newCategoryAdd,
                                  categoryType: CategoryType.income,
                                  categoryOrder: itemList.length,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        80,
                                        0,
                                        0,
                                        0,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          '+ 新しいカテゴリーを追加',
                                          style: AppTextStyles
                                              .listTileSecondaryTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Divider(
                                  thickness: 0.25,
                                  height: 0.25,
                                  indent: leftsidePadding + 50,
                                  endIndent: leftsidePadding,
                                  color: context.colors.separator,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
          error: (Object error, StackTrace stackTrace) {
            return const Text('エラーが発生しました');
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        );
  }

  // 一般カテゴリーリスト
  Widget _buildExpenseCategoryList(
    double leftsidePadding,
    double listSTextBoxOffset,
  ) {
    return ref
        .watch(allBigCategoriesWithSmallListProvider)
        .when(
          data: (itemList) {
            return Column(
              children: [
                // ヘッダーまでの余白
                SizedBox(height: 8),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: SizedBox(
                              width: 37 + 90 + listSTextBoxOffset,
                              child: Text(
                                'カテゴリー',
                                style: AppTextStyles.listTileLegendTitle,
                              ),
                            ),
                          ),
                          Text('項目', style: AppTextStyles.listTileLegendTitle),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '詳細',
                          style: AppTextStyles.listTileLegendTitle,
                        ),
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
                  color: context.colors.separator,
                ),

                // リスト部分
                Expanded(
                  child: ListView.builder(
                    // コンテンツが収まる場合はスクロールしない、はみ出る場合はバウンス付きスクロール
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: itemList.length + 1, // 末尾に追加ボタンを表示するために1つ多くする
                    itemBuilder: (BuildContext context, int index) {
                      if (index < itemList.length) {
                        return AppInkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => CategoryDetailEditPage(
                                  screenMode:
                                      BigCategoryDetailEditScreenMode.edit,
                                  categoryType: CategoryType.expense,
                                  bigCategoryId: itemList[index].id,
                                )),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: leftsidePadding,
                                ),
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    key: Key('$index'),
                                    children: [
                                      // アイコン
                                      Padding(
                                        padding: const EdgeInsets.all(12.5),
                                        child: SvgPicture.asset(
                                          itemList[index].resourcePath,
                                          colorFilter: ColorFilter.mode(
                                            MyColors().getColorFromHex(
                                              itemList[index].colorCode,
                                            ),
                                            BlendMode.srcIn,
                                          ),
                                          semanticsLabel: 'categoryIcon',
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),

                                      // カテゴリー名
                                      SizedBox(
                                        width: 90 + listSTextBoxOffset,
                                        child: Text(
                                          itemList.isEmpty
                                              ? ''
                                              : itemList[index].bigCategoryName,
                                          style: AppTextStyles
                                              .listTilePrimaryTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // 項目の列挙
                                      Expanded(
                                        child: Text(
                                          itemList.isEmpty
                                              ? ''
                                              : itemList[index]
                                                    .expenseSmallCategoryNameText,
                                          style: AppTextStyles
                                              .listTileSecondaryTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // 進むアイコン
                                      const Padding(
                                        padding: EdgeInsets.all(12.5),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                          color: MyColors.white,
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
                                color: context.colors.separator,
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 末尾の追加Widget
                        return AppInkWell(
                          key: Key('$index'),
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailEditPage(
                                  screenMode: BigCategoryDetailEditScreenMode
                                      .newCategoryAdd,
                                  categoryType: CategoryType.expense,
                                  categoryOrder: itemList.length - 1 + 1,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // カテゴリー名
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        80,
                                        0,
                                        0,
                                        0,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          '+ 新しいカテゴリーを追加',
                                          style: AppTextStyles
                                              .listTileSecondaryTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                //区切り線
                                Divider(
                                  thickness: 0.25,
                                  height: 0.25,
                                  indent: leftsidePadding + 50,
                                  endIndent: leftsidePadding,
                                  color: context.colors.separator,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
          error: (Object error, StackTrace stackTrace) {
            return const Text('エラーが発生しました');
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        );
  }

  // 固定費カテゴリーリスト
  Widget _buildFixedCostCategoryList(
    double leftsidePadding,
    double listSTextBoxOffset,
  ) {
    return ref
        .watch(allFixedCostCategoriesProvider)
        .when(
          data: (itemList) {
            return Column(
              children: [
                // ヘッダーまでの余白
                SizedBox(height: 8),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: SizedBox(
                          width: 37 + 90 + listSTextBoxOffset,
                          child: Text(
                            'カテゴリー',
                            style: AppTextStyles.listTileLegendTitle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '詳細',
                          style: AppTextStyles.listTileLegendTitle,
                        ),
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
                  color: context.colors.separator,
                ),

                // リスト部分
                Expanded(
                  child: ListView.builder(
                    // コンテンツが収まる場合はスクロールしない、はみ出る場合はバウンス付きスクロール
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: itemList.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < itemList.length) {
                        return AppInkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => CategoryDetailEditPage(
                                  screenMode:
                                      BigCategoryDetailEditScreenMode.edit,
                                  categoryType: CategoryType.fixedCost,
                                  bigCategoryId: itemList[index].id,
                                )),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: leftsidePadding,
                                ),
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    key: Key('$index'),
                                    children: [
                                      // アイコン
                                      Padding(
                                        padding: const EdgeInsets.all(12.5),
                                        child: SvgPicture.asset(
                                          itemList[index].resourcePath,
                                          colorFilter: ColorFilter.mode(
                                            MyColors().getColorFromHex(
                                              itemList[index].colorCode,
                                            ),
                                            BlendMode.srcIn,
                                          ),
                                          semanticsLabel: 'categoryIcon',
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),

                                      // カテゴリー名
                                      Expanded(
                                        child: Text(
                                          itemList.isEmpty
                                              ? ''
                                              : itemList[index].categoryName,
                                          style: AppTextStyles
                                              .listTilePrimaryTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // 進むアイコン
                                      const Padding(
                                        padding: EdgeInsets.all(12.5),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                          color: MyColors.white,
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
                                color: context.colors.separator,
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 末尾の追加Widget
                        return AppInkWell(
                          key: Key('$index'),
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailEditPage(
                                  screenMode: BigCategoryDetailEditScreenMode
                                      .newCategoryAdd,
                                  categoryType: CategoryType.fixedCost,
                                  categoryOrder: itemList.length,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        80,
                                        0,
                                        0,
                                        0,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          '+ 新しいカテゴリーを追加',
                                          style: AppTextStyles
                                              .listTileSecondaryTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                //区切り線
                                Divider(
                                  thickness: 0.25,
                                  height: 0.25,
                                  indent: leftsidePadding + 50,
                                  endIndent: leftsidePadding,
                                  color: context.colors.separator,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
          error: (Object error, StackTrace stackTrace) {
            return const Text('エラーが発生しました');
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        );
  }

  double listSmallcategoryMemoOffsetGetter(double screenWidthSize) {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return defaultWidth < 0 ? 0 : screenWidthSize - defaultWidth;
  }
}
