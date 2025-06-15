/// packegeImport
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/check_box.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/new_small_category_input_name_dialog.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';

class SmallCategoryEditArea extends ConsumerStatefulWidget {
  const SmallCategoryEditArea({required this.bigId, super.key});

  final int bigId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SmallCategoryEditArea();
}

class _SmallCategoryEditArea extends ConsumerState<SmallCategoryEditArea> {
  // アイテムリスト
  late List<EditExpenseSmallCategoryValue> itemList;

  bool isInitial = true;

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
        final initialList = await ref
            .watch(allSmallCategoriesListProvider(widget.bigId).future);
        ref
            .read(edittingSmallCategoryListNotifierProvider.notifier)
            .setData(initialList);
      });
    });
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
    itemList = ref.watch(edittingSmallCategoryListNotifierProvider);
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
                      Text(
                        '表示',
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: MyColors.secondaryLabel,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        width: 20,
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
                    .read(edittingSmallCategoryListNotifierProvider.notifier)
                    .reorder(oldIndex, newIndex);

                // 変更を加えたことを管理する状態管理する
                ref
                    .read(isSmallCategoryListEditedNotifierProvider.notifier)
                    .updateState(true);
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
                        padding:
                            EdgeInsets.symmetric(horizontal: leftsidePadding),
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
                                              edittingSmallCategoryListNotifierProvider
                                                  .notifier)
                                          .toggleDisplay(index);
                                      // 変更を加えたことを管理する状態管理する
                                      ref
                                          .read(
                                              isSmallCategoryListEditedNotifierProvider
                                                  .notifier)
                                          .updateState(true);
                                    });
                                  },
                                  child: CheckBox(
                                      isChecked:
                                          itemList[index].etitedStateIsChecked),
                                ),
                              ),

                              const SizedBox(
                                width: 16,
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return NewSmallCategoryInputNameDialog(
                              bigCategoryId: widget.bigId,
                              displayedOrderInBig: itemList.length + 1);
                        },
                      );
                    },
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
