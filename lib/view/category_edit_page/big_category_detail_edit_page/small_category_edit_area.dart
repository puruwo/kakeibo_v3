/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';

/// localImport
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/component/check_box.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/new_small_category_input_name_dialog.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_income_small_category_list/editting_income_small_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_small_category_list_edited/is_income_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';

/// 小カテゴリーの編集エリア（案件 UIデザイン改修 §2）
///
/// 外観エリアと同じインセット枠に収める。行の機能は従来どおり
/// （チェックで表示切替／行内で名称編集／右端ハンドルで並び替え／末尾行で追加）。
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
  final List<TextEditingController> _controllers = [];

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

  /// チェックボックス（表示切替）のタップ処理
  void _toggleDisplay(int index) {
    setState(() {
      if (widget.categoryType == CategoryType.income) {
        ref
            .read(edittingIncomeSmallCategoryListNotifierProvider.notifier)
            .toggleDisplay(index);
        ref
            .read(isIncomeSmallCategoryListEditedNotifierProvider.notifier)
            .updateState(true);
      } else {
        ref
            .read(edittingSmallCategoryListNotifierProvider.notifier)
            .toggleDisplay(index);
        ref
            .read(isSmallCategoryListEditedNotifierProvider.notifier)
            .updateState(true);
      }
    });
  }

  /// 名称の変更処理
  void _updateName(int index, String value) {
    if (widget.categoryType == CategoryType.income) {
      ref
          .read(edittingIncomeSmallCategoryListNotifierProvider.notifier)
          .updateName(index, value);
      ref
          .read(isIncomeSmallCategoryListEditedNotifierProvider.notifier)
          .updateState(true);
    } else {
      ref
          .read(edittingSmallCategoryListNotifierProvider.notifier)
          .updateName(index, value);
      ref
          .read(isSmallCategoryListEditedNotifierProvider.notifier)
          .updateState(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // アイテムリストを状態監視
    itemList = widget.categoryType == CategoryType.income
        ? ref.watch(edittingIncomeSmallCategoryListNotifierProvider)
        : ref.watch(edittingSmallCategoryListNotifierProvider);

    // アイテム数が変わったときにコントローラー数を同期（新規追加など）
    if (_controllers.length != itemList.length) {
      _syncControllers(itemList);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // グループ見出し（インセットグループのヘッダーと同じ書式）
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
              child: Row(
                children: [
                  Text('小カテゴリー', style: AppTextStyles.insetGroupHeader),
                  const Spacer(),
                  Text(
                    'チェックで表示 / 右端で並び替え',
                    style: AppTextStyles.insetGroupNote,
                  ),
                ],
              ),
            ),

            // リスト部分（インセット枠に収める）。
            // 枠は内容にフィットさせ（shrinkWrap）、行数が多いときだけ枠内でスクロールする
            Flexible(
              child: Align(
                alignment: Alignment.topCenter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.fillQuaternary,
                    border: Border.all(color: context.colors.surfaceBorder),
                    borderRadius: appInsetGroupRadius,
                  ),
                  child: ClipRRect(
                    borderRadius: appInsetGroupRadius,
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      // ドラッグ中の行にインセット枠と同じ地を与える
                      // （枠外のオーバーレイに移っても透けないように）
                      proxyDecorator: (child, index, animation) => Material(
                        color: context.colors.fillOpaque,
                        borderRadius: BorderRadius.circular(8),
                        child: child,
                      ),
                      // デフォルトの並べ替えアイコン
                      buildDefaultDragHandles: false,
                      // 並べ替えた時の処理
                      onReorder: (oldIndex, newIndex) {
                        if (widget.categoryType == CategoryType.income) {
                          ref
                              .read(
                                edittingIncomeSmallCategoryListNotifierProvider
                                    .notifier,
                              )
                              .reorder(oldIndex, newIndex);
                          ref
                              .read(
                                isIncomeSmallCategoryListEditedNotifierProvider
                                    .notifier,
                              )
                              .updateState(true);
                        } else {
                          // カテゴリーの状態を保持しているリストの並び替え
                          ref
                              .read(
                                edittingSmallCategoryListNotifierProvider
                                    .notifier,
                              )
                              .reorder(oldIndex, newIndex);

                          // 変更を加えたことを管理する状態管理する
                          ref
                              .read(
                                isSmallCategoryListEditedNotifierProvider
                                    .notifier,
                              )
                              .updateState(true);
                        }

                        // コントローラーも同じ順番に並べ替える
                        setState(() {
                          int adjustedNewIndex = newIndex;
                          if (oldIndex < adjustedNewIndex)
                            adjustedNewIndex -= 1;
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
                              if (index != 0)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: kAppInsetRowIndent,
                                  ),
                                  child: Divider(
                                    height: 0.5,
                                    thickness: 0.5,
                                    color: context.colors.separator,
                                  ),
                                ),
                              SizedBox(
                                height: kAppInsetRowHeight,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    kAppInsetRowIndent,
                                    0,
                                    4,
                                    0,
                                  ),
                                  child: Row(
                                    children: [
                                      // チェックボックス（表示切替）
                                      AppInkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () => _toggleDisplay(index),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: CheckBox(
                                            isChecked: itemList[index]
                                                .etitedStateIsChecked,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // カテゴリー名（直接編集可能）
                                      Expanded(
                                        child: index < _controllers.length
                                            ? TextFormField(
                                                controller: _controllers[index],
                                                style: AppTextStyles
                                                    .insetGroupLabel,
                                                maxLines: 1,
                                                maxLength: 20,
                                                decoration:
                                                    const InputDecoration(
                                                      border: InputBorder.none,
                                                      counterText: '',
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                                onChanged: (value) =>
                                                    _updateName(index, value),
                                              )
                                            : Text(
                                                itemList[index].name,
                                                style: AppTextStyles
                                                    .insetGroupLabel,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),

                                      // 並べ替えハンドル
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 44,
                                          height: kAppInsetRowHeight,
                                          child: Icon(
                                            Icons.drag_handle_rounded,
                                            size: 20,
                                            color: context.colors.icon,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // 末尾の追加行
                          return Column(
                            key: Key('$index'),
                            children: [
                              if (itemList.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: kAppInsetRowIndent,
                                  ),
                                  child: Divider(
                                    height: 0.5,
                                    thickness: 0.5,
                                    color: context.colors.separator,
                                  ),
                                ),
                              AppInkWell(
                                borderRadius: BorderRadius.zero,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return NewSmallCategoryInputNameDialog(
                                        bigCategoryId: widget.bigId,
                                        displayedOrderInBig:
                                            itemList.length + 1,
                                        categoryType: widget.categoryType,
                                      );
                                    },
                                  );
                                },
                                child: SizedBox(
                                  height: kAppInsetRowHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: kAppInsetRowIndent,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.add_rounded,
                                          size: kAppInsetRowIconSize,
                                          color: context.colors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '小カテゴリーを追加',
                                          style: AppTextStyles.insetGroupLabel
                                              .copyWith(
                                                color: context.colors.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
