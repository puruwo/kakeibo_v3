/// packegeImport
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/other_page/big_category_detail_edit_page.dart';

class BigCategoryListArea extends ConsumerStatefulWidget {
  const BigCategoryListArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryListAreaState();
}

class _BigCategoryListAreaState extends ConsumerState<BigCategoryListArea> {
  @override
  Widget build(BuildContext context) {

    // リスト内テキストボックスの拡大部を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    // 大カテゴリーと小カテゴリーで増幅分を2等分する
    final listSTextBoxOffset =
        listSmallcategoryMemoOffsetGetter(context.screenWidth) / 2;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

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
                        padding: const EdgeInsets.only(left: 48),
                        child: SizedBox(
                          width: 90 + listSTextBoxOffset,
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
                        '小カテゴリー',
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
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    // ヒット範囲を拡大
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: ((context) => BigCategoryDetailEditPage(
                              bigCategoryId: itemList[index].id)),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: leftsidePadding),
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

                                // 小カテゴリーの列挙
                                Expanded(
                                  child: Text(
                                    itemList.isEmpty
                                        ? ''
                                        : itemList[index].expenseSmallCategoryNameText,
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
