/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';

/// localImport
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/category_list_tile.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/category_detail_edit_page.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/page_mode_controller/page_mode.dart';
import 'package:kakeibo/constant/icon.dart';

/// カテゴリー設定の一覧（大カテゴリー行＋末尾の追加行）
///
/// 行は共通部品 [CategoryListTile]（KP-032 で切り出し。見た目は従来どおり）。
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
    // カテゴリータイプに応じて表示を切り替え
    if (widget.categoryType == CategoryType.expense) {
      return _buildExpenseCategoryList();
    } else {
      return _buildIncomeCategoryList();
    }
  }

  // 収入カテゴリーリスト
  Widget _buildIncomeCategoryList() {
    return ref
        .watch(allIncomeBigCategoriesWithSmallListProvider)
        .when(
          data: (itemList) {
            return Column(
              children: [
                const CategoryListLegend(
                  leading: 'カテゴリー',
                  middle: '項目',
                  trailing: '詳細',
                ),

                // リスト部分
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: itemList.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < itemList.length) {
                        final item = itemList[index];
                        return CategoryListTile(
                          resourcePath: item.resourcePath,
                          colorCode: item.colorCode,
                          title: item.bigCategoryName,
                          subtitle: item.incomeSmallCategoryNameText,
                          trailing: Icon(
                            AppIcons.next,
                            size: 18,
                            color: context.colors.text,
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => CategoryDetailEditPage(
                                  screenMode:
                                      BigCategoryDetailEditScreenMode.edit,
                                  categoryType: CategoryType.income,
                                  bigCategoryId: item.id,
                                )),
                              ),
                            );
                          },
                        );
                      } else {
                        // 末尾の追加Widget
                        return _buildAddRow(
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
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
          error: (Object error, StackTrace stackTrace) {
            return const AppErrorState();
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        );
  }

  // 一般カテゴリーリスト
  Widget _buildExpenseCategoryList() {
    return ref
        .watch(allBigCategoriesWithSmallListProvider)
        .when(
          data: (itemList) {
            return Column(
              children: [
                const CategoryListLegend(
                  leading: 'カテゴリー',
                  middle: '項目',
                  trailing: '詳細',
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
                        final item = itemList[index];
                        return CategoryListTile(
                          resourcePath: item.resourcePath,
                          colorCode: item.colorCode,
                          title: item.bigCategoryName,
                          subtitle: item.expenseSmallCategoryNameText,
                          trailing: Icon(
                            AppIcons.next,
                            size: 18,
                            color: context.colors.text,
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => CategoryDetailEditPage(
                                  screenMode:
                                      BigCategoryDetailEditScreenMode.edit,
                                  categoryType: CategoryType.expense,
                                  bigCategoryId: item.id,
                                )),
                              ),
                            );
                          },
                        );
                      } else {
                        // 末尾の追加Widget
                        return _buildAddRow(
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
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
          error: (Object error, StackTrace stackTrace) {
            return const AppErrorState();
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        );
  }

  /// 末尾の「＋ 新しいカテゴリーを追加」行
  Widget _buildAddRow({required VoidCallback onTap}) {
    final leftsidePadding = CategoryListTile.sidePadding(context);
    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
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
                      style: context.textStyles.listTileSecondaryTitle,
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
}
