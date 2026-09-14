/// packegeImport
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';

/// localImport
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/edit_expense_big_category_value.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/category_edit_page/category_delete_dialog.dart';
import 'package:kakeibo/view/category_edit_page/category_delete_row_button.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/editting_big_category_list/editting_big_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/is_big_category_list_edited/is_big_category_list_edited.dart';
import 'package:kakeibo/constant/icon.dart';

/// 並び替え編集モードの1行の高さ
const double kBigCategoryEditRowHeight = 50;

class BigCategoryEditArea extends ConsumerStatefulWidget {
  const BigCategoryEditArea({super.key, required this.categoryType});

  final CategoryType categoryType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryEditAreaState();
}

class _BigCategoryEditAreaState extends ConsumerState<BigCategoryEditArea>
    with PresentationMixin {
  /// 行頭の削除ボタンのタップ処理（KP-024）
  ///
  /// 大カテゴリーは確認後すぐに配下の小カテゴリーごと論理削除する（並び替えの保存は待たない）。
  /// 固定費が配下の小カテゴリーを使っているときは削除せずに案内する
  Future<void> _onDeleteTap(EditExpenseBigCategoryValue item) async {
    final usecase = ref.read(categoryUsecaseProvider);
    final smallIds = item.expenseSmallCategoryList.map((e) => e.id).toList();

    final fixedCostNames =
        await usecase.fetchFixedCostNamesUsingSmallCategories(smallIds);
    if (!mounted) {
      return;
    }
    if (fixedCostNames.isNotEmpty) {
      await showCategoryInUseByFixedCostDialog(
        context,
        categoryName: item.bigCategoryName,
        fixedCostNames: fixedCostNames,
      );
      return;
    }

    // 1行が画面幅で折り返して行頭が「す。」だけにならないよう、文の区切りで改行する
    final message = smallIds.isEmpty
        ? '元に戻せません。\n登録済みの支出はそのまま残ります。'
        : '小カテゴリー${smallIds.length}件もあわせて削除します。\n元に戻せません。\n登録済みの支出はそのまま残ります。';
    final shouldDelete = await showCategoryDeleteConfirmationDialog(
      context,
      categoryName: item.bigCategoryName,
      message: message,
    );
    if (!shouldDelete || !mounted) {
      return;
    }

    await execute(
      context,
      action: () => usecase.deleteBig(item.id),
      succesAction: () async {
        // 並び替えの編集中状態は残したまま、削除した行だけを外す
        ref
            .read(edittingBigCategoryListNotifierProvider.notifier)
            .removeById(item.id);
        // 削除だけして「編集を完了」を押しても「編集がされていません」にしない
        ref.read(isBigCategoryListEditedNotifierProvider.notifier).updateState(true);
        // 保存時に比べる編集前のリストからも外すため取り直す
        ref.invalidate(allBigCategoriesWithSmallListProvider);
      },
      successMessage: '削除が完了しました',
    );
  }

  @override
  void initState() {
    super.initState();

    // 取得したデータを編集用プロバイダーに格納
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future(() async {
        if (widget.categoryType == CategoryType.income) {
          // 収入カテゴリーは編集モードを持たないため何もしない
          return;
        }
        final initialList = await ref.read(
          allBigCategoriesWithSmallListProvider.future,
        );
        ref
            .read(edittingBigCategoryListNotifierProvider.notifier)
            .setData(initialList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // リスト内テキストボックスの拡大部を計算
    final listSTextBoxOffset = listSmallcategoryMemoOffsetGetter() / 2;

    // 左のpaddingの大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    if (widget.categoryType == CategoryType.income) {
      // 収入カテゴリーは編集モードを持たない
      return const SizedBox.shrink();
    }
    return _buildExpenseCategoryEditArea(leftsidePadding, listSTextBoxOffset);
  }

  // 一般カテゴリーの編集エリア
  Widget _buildExpenseCategoryEditArea(
    double leftsidePadding,
    double listSTextBoxOffset,
  ) {
    final itemList = ref.watch(edittingBigCategoryListNotifierProvider);

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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text('削除', style: context.textStyles.listTileLegendTitle),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 110 + listSTextBoxOffset,
                      child: Text(
                        'カテゴリー',
                        style: context.textStyles.listTileLegendTitle,
                      ),
                    ),
                    Text('項目', style: context.textStyles.listTileLegendTitle),
                  ],
                ),
              ),
              Text('並べ替え', style: context.textStyles.listTileLegendTitle),
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
                      height: kBigCategoryEditRowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 削除ボタン（KP-024。旧・表示切替のチェックボックス）
                          // 入力画面で選べるカテゴリーが無くならないよう、最後の1件は削除させない
                          Padding(
                            padding: const EdgeInsets.all(8.5),
                            child: CategoryDeleteRowButton(
                              onTap: itemList.length > 1
                                  ? () => _onDeleteTap(itemList[index])
                                  : null,
                            ),
                          ),

                          // アイコン
                          Padding(
                            padding: const EdgeInsets.all(12.5),
                            child: SvgPicture.asset(
                              itemList[index].resourcePath,
                              colorFilter: ColorFilter.mode(
                                ColorCode.toColor(
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
                            width: 72 + listSTextBoxOffset,
                            child: Text(
                              itemList[index].bigCategoryName,
                              style: context.textStyles.listTilePrimaryTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // 小カテゴリー列挙
                          SizedBox(
                            width: 120 + listSTextBoxOffset,
                            child: Text(
                              itemList[index].expenseSmallCategoryNameText,
                              style: context.textStyles.listTileSecondaryTitle,
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
                              child: Icon(
                                AppIcons.dragHandle,
                                color: context.colors.icon,
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
                    color: context.colors.separator,
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
