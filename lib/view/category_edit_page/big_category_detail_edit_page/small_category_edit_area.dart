/// packegeImport
/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';

/// localImport
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/component/check_box.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/new_small_category_input_name_dialog.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_income_small_category_list/editting_income_small_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_small_category_list_edited/is_income_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';

class SmallCategoryEditArea extends ConsumerStatefulWidget {
  const SmallCategoryEditArea({
    required this.bigId,
    this.categoryType = CategoryType.expense,
    super.key,
  });

  final int bigId;
  final CategoryType categoryType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SmallCategoryEditArea();
}

class _SmallCategoryEditArea extends ConsumerState<SmallCategoryEditArea> {
  // アイテムリスト
  late List<dynamic> itemList;

  bool isInitial = true;

  // 各アイテムのテキスト編集コントローラー
  List<TextEditingController> _controllers = [];

  /// コントローラー数をアイテムリストに同期する（末尾の追加/削除のみ）
  void _syncControllers(List<dynamic> items) {
    while (_controllers.length < items.length) {
      _controllers.add(
        TextEditingController(text: items[_controllers.length].name),
      );
    }
    while (_controllers.length > items.length) {
      _controllers.removeLast().dispose();
    }
  }

  @override
  void initState() {
    super.initState();

    // 取得したデータをedittingSmallCategoryListNotifierProviderに格納し編集できる状態にする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.bigId == -1) {
        // 新規作成の時は初期化しない
        return;
      }

      // 一度だけ取得してセット
      Future(() async {
        // 一度だけ取得してセット
        if (widget.categoryType == CategoryType.income) {
          final initialList = await ref.watch(
            allIncomeSmallCategoriesListProvider(widget.bigId).future,
          );
          ref
              .read(edittingIncomeSmallCategoryListNotifierProvider.notifier)
              .setData(initialList);
          setState(() {
            _syncControllers(initialList);
          });
        } else {
          final initialList = await ref.watch(
            allSmallCategoriesListProvider(widget.bigId).future,
          );
          ref
              .read(edittingSmallCategoryListNotifierProvider.notifier)
              .setData(initialList);
          setState(() {
            _syncControllers(initialList);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // リスト内テキストボックスの拡大部を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    // 大カテゴリーと小カテゴリーで増幅分を2等分する
    final listSTextBoxOffset = listSmallcategoryMemoOffsetGetter() / 2;

    // 左のpaddingの大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    // アイテムリストを状態監視
    itemList = widget.categoryType == CategoryType.income
        ? ref.watch(edittingIncomeSmallCategoryListNotifierProvider)
        : ref.watch(edittingSmallCategoryListNotifierProvider);

    // アイテム数が変わったときにコントローラー数を同期（新規追加など）
    if (_controllers.length != itemList.length) {
      _syncControllers(itemList);
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
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
                      Text('表示', style: AppTextStyles.listTileLegendTitle),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 110 + listSTextBoxOffset,
                        child: Text(
                          '項目',
                          style: AppTextStyles.listTileLegendTitle,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('並べ替え', style: AppTextStyles.listTileLegendTitle),
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
                if (widget.categoryType == CategoryType.income) {
                  ref
                      .read(edittingIncomeSmallCategoryListNotifierProvider
                          .notifier)
                      .reorder(oldIndex, newIndex);
                  ref
                      .read(isIncomeSmallCategoryListEditedNotifierProvider
                          .notifier)
                      .updateState(true);
                } else {
                  // カテゴリーの状態を保持しているリストの並び替え
                  ref
                      .read(edittingSmallCategoryListNotifierProvider.notifier)
                      .reorder(oldIndex, newIndex);

                  // 変更を加えたことを管理する状態管理する
                  ref
                      .read(isSmallCategoryListEditedNotifierProvider.notifier)
                      .updateState(true);
                }

                // コントローラーも同じ順番に並べ替える
                setState(() {
                  int adjustedNewIndex = newIndex;
                  if (oldIndex < adjustedNewIndex) adjustedNewIndex -= 1;
                  final controller = _controllers.removeAt(oldIndex);
                  _controllers.insert(adjustedNewIndex, controller);
                });
              },
              itemCount: itemList.length + 1, // +1は追加ボタン用
              itemBuilder: (BuildContext context, int index) {
                if (index < itemList.length) {
                  // 並べ替え可能なリストのアイテム
                  return Column(
                    key: Key('$index'),
                    children: [
                      // リスト本体
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: leftsidePadding,
                        ),
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // チェックボックス
                              Padding(
                                padding: const EdgeInsets.all(12.5),
                                child: AppInkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    // チェックボックスのタップ処理
                                    setState(() {
                                      if (widget.categoryType ==
                                          CategoryType.income) {
                                        ref
                                            .read(
                                              edittingIncomeSmallCategoryListNotifierProvider
                                                  .notifier,
                                            )
                                            .toggleDisplay(index);
                                        ref
                                            .read(
                                              isIncomeSmallCategoryListEditedNotifierProvider
                                                  .notifier,
                                            )
                                            .updateState(true);
                                      } else {
                                        // チェックボックスの状態を更新する
                                        ref
                                            .read(
                                              edittingSmallCategoryListNotifierProvider
                                                  .notifier,
                                            )
                                            .toggleDisplay(index);
                                        // 変更を加えたことを管理する状態管理する
                                        ref
                                            .read(
                                              isSmallCategoryListEditedNotifierProvider
                                                  .notifier,
                                            )
                                            .updateState(true);
                                      }
                                    });
                                  },
                                  child: CheckBox(
                                    isChecked:
                                        itemList[index].etitedStateIsChecked,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // カテゴリー名（直接編集可能）
                              Expanded(
                                child: index < _controllers.length
                                    ? TextFormField(
                                        controller: _controllers[index],
                                        style: AppTextStyles.listTilePrimaryTitle,
                                        maxLines: 1,
                                        maxLength: 20,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          counterText: '',
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (value) {
                                          if (widget.categoryType ==
                                              CategoryType.income) {
                                            ref
                                                .read(
                                                  edittingIncomeSmallCategoryListNotifierProvider
                                                      .notifier,
                                                )
                                                .updateName(index, value);
                                            ref
                                                .read(
                                                  isIncomeSmallCategoryListEditedNotifierProvider
                                                      .notifier,
                                                )
                                                .updateState(true);
                                          } else {
                                            ref
                                                .read(
                                                  edittingSmallCategoryListNotifierProvider
                                                      .notifier,
                                                )
                                                .updateName(index, value);
                                            ref
                                                .read(
                                                  isSmallCategoryListEditedNotifierProvider
                                                      .notifier,
                                                )
                                                .updateState(true);
                                          }
                                        },
                                      )
                                    : Text(
                                        itemList[index].name,
                                        style: AppTextStyles.listTilePrimaryTitle,
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
                        color: context.colors.separator,
                      ),
                    ],
                  );
                } else {
                  // 末尾の追加Widget
                  return AppInkWell(
                    key: Key('$index'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return NewSmallCategoryInputNameDialog(
                            bigCategoryId: widget.bigId,
                            displayedOrderInBig: itemList.length + 1,
                            categoryType: widget.categoryType,
                          );
                        },
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
                                padding: const EdgeInsets.fromLTRB(80, 0, 0, 0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    '+ 新しい項目を追加',
                                    style: AppTextStyles.listTileSecondaryTitle,
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
      ),
    );
  }

  double listSmallcategoryMemoOffsetGetter() {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return defaultWidth < 0 ? 0 : context.screenWidth - defaultWidth;
  }
}
