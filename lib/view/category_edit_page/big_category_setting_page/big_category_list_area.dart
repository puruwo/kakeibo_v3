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
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/fixed_cost_category_detail_edit_page/category_detail_edit_page.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/page_mode_controller/page_mode.dart';

class BigCategoryListArea extends ConsumerStatefulWidget {
  const BigCategoryListArea({
    super.key,
    required this.categoryType,
  });

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
    } else {
      return _buildFixedCostCategoryList(leftsidePadding, listSTextBoxOffset);
    }
  }

  // 一般カテゴリーリスト
  Widget _buildExpenseCategoryList(double leftsidePadding, double listSTextBoxOffset) {
    return ref.watch(allBigCategoriesWithSmallListProvider).when(
      data: (itemList) {
        return Column(
          children: [
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
                            style: GoogleFonts.notoSans(
                                fontSize: 16,
                                color: MyColors.secondaryLabel,
                                fontWeight: FontWeight.w400),
                          ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '詳細',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400),
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
              color: MyColors.separater,
            ),

            // リスト部分
            Expanded(
              child: ListView.builder(
                itemCount: itemList.length + 1, // 末尾に追加ボタンを表示するために1つ多くする
                itemBuilder: (BuildContext context, int index) {
                  if (index < itemList.length) {
                    return GestureDetector(
                      // ヒット範囲を拡大
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => CategoryDetailEditPage(
                                screenMode:
                                    BigCategoryDetailEditScreenMode.edit,
                                categoryType: CategoryType.expense,
                                bigCategoryId: itemList[index].id)),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: leftsidePadding),
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
                                              itemList[index].colorCode),
                                          BlendMode.srcIn),
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
                                      style: GoogleFonts.notoSans(
                                          fontSize: 16,
                                          color: MyColors.label,
                                          fontWeight: FontWeight.w400),
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
                                      style: GoogleFonts.notoSans(
                                          fontSize: 14,
                                          color: MyColors.secondaryLabel,
                                          fontWeight: FontWeight.w300),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // 進むアイコン
                                  const Padding(
                                    padding: EdgeInsets.all(12.5),
                                    child: Icon(Icons.arrow_forward_ios_rounded,
                                        size: 18, color: MyColors.white),
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
                      ),
                    );
                  } else {
                    // 末尾の追加Widget
                    return GestureDetector(
                      key: Key('$index'),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(80, 0, 0, 0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      '+ 新しいカテゴリーを追加',
                                      style: MyFonts.newCategoryAdd,
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
                              color: MyColors.separater,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CategoryDetailEditPage(
                                  screenMode: BigCategoryDetailEditScreenMode
                                      .newCategoryAdd,
                                  categoryType: CategoryType.expense,
                                  categoryOrder: itemList.length - 1 + 1,
                                )));
                      },
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
  Widget _buildFixedCostCategoryList(double leftsidePadding, double listSTextBoxOffset) {
    return ref.watch(allFixedCostCategoriesProvider).when(
      data: (itemList) {
        return Column(
          children: [
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
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '詳細',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: MyColors.secondaryLabel,
                        fontWeight: FontWeight.w400,
                      ),
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
              color: MyColors.separater,
            ),

            // リスト部分
            Expanded(
              child: ListView.builder(
                itemCount: itemList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < itemList.length) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => CategoryDetailEditPage(
                              screenMode: BigCategoryDetailEditScreenMode.edit,
                              categoryType: CategoryType.fixedCost,
                              bigCategoryId: itemList[index].id,
                            )),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                key: Key('$index'),
                                children: [
                                  // アイコン
                                  Padding(
                                    padding: const EdgeInsets.all(12.5),
                                    child: SvgPicture.asset(
                                      itemList[index].resourcePath,
                                      colorFilter: ColorFilter.mode(
                                        MyColors().getColorFromHex(itemList[index].colorCode),
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
                                      itemList.isEmpty ? '' : itemList[index].categoryName,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        color: MyColors.label,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // 進むアイコン
                                  const Padding(
                                    padding: EdgeInsets.all(12.5),
                                    child: Icon(Icons.arrow_forward_ios_rounded,
                                        size: 18, color: MyColors.white),
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
                      ),
                    );
                  } else {
                    // 末尾の追加Widget
                    return GestureDetector(
                      key: Key('$index'),
                      child: SizedBox(
                        height: 50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(80, 0, 0, 0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      '+ 新しいカテゴリーを追加',
                                      style: MyFonts.newCategoryAdd,
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
                              color: MyColors.separater,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CategoryDetailEditPage(
                              screenMode: BigCategoryDetailEditScreenMode.newCategoryAdd,
                              categoryType: CategoryType.fixedCost,
                              categoryOrder: itemList.length,
                            ),
                          ),
                        );
                      },
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
