/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';

/// localImport
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/category_delete_dialog.dart';
import 'package:kakeibo/view/category_edit_page/category_delete_row_button.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/page_mode_controller/page_mode.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/new_small_category_input_sheet.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_income_small_category_list/editting_income_small_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_small_category_list_edited/is_income_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';
import 'package:kakeibo/constant/icon.dart';

/// 小カテゴリーの編集エリア（案件 UIデザイン改修 §2）
///
/// 外観エリアと同じインセット枠に収める。行の機能は
/// 行頭の丸マイナスで削除（KP-024。旧・チェックで表示切替）／行内で名称編集／右端ハンドルで並び替え／末尾行で追加。
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

  /// 初期表示の取得が終わったか
  ///
  /// 終わる前に項目を追加できてしまうと、取得完了時の setData で消えてしまう
  bool _isInitialized = false;

  /// 各アイテムのテキスト編集コントローラー（キーは小カテゴリーのid）
  ///
  /// indexで持つと並び替えのたびに付け替えが必要になり、
  /// 編集中リストとコントローラーの対応がずれる余地が残る。
  /// まだDBに無い項目にも負の一意なidが振られている（→ 編集中リストのnotifier）。
  final Map<int, TextEditingController> _controllers = {};

  /// [item] の行のコントローラーを返す（無ければ作る）
  ///
  /// 破棄は [dispose] でまとめて行う。行の描画中に破棄すると、
  /// まだツリーに残っている入力欄が参照しているコントローラーを壊す。
  TextEditingController _controllerFor(dynamic item) {
    return _controllers.putIfAbsent(
      item.id as int,
      () => TextEditingController(text: item.name as String),
    );
  }

  /// コントローラーを作り直す（初期表示用）
  ///
  /// 取得完了を待つ間に別のカテゴリーを開くことはないが、
  /// setData で中身が入れ替わるため、取得前に作られたものは持ち越さない。
  void _rebuildControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  @override
  void initState() {
    super.initState();

    // 取得したデータを編集中リストへ格納し編集できる状態にする。
    // リストは大カテゴリーごとのfamilyで、ページを閉じると破棄されるため、
    // 前に開いたカテゴリーの状態を引き継ぐことはない
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.bigId == kNewCategoryBigId) {
        // 新規作成の時は取得しない（空のまま編集を始める）
        setState(() {
          _isInitialized = true;
        });
        return;
      }

      // 一度だけ取得してセット
      Future(() async {
        // Futureの実行はイベントキューに回るため、開始時点で既に破棄されていることがある。
        // 破棄後に ref を触るとStateErrorになるので先に抜ける
        if (!mounted) {
          return;
        }

        if (widget.categoryType == CategoryType.income) {
          // read だと購読者が居ないまま取得が走り、完了前に autoDispose の
          // providerが破棄されて StateError になることがあるので watch を使う
          final initialList = await ref.watch(
            allIncomeSmallCategoriesListProvider(widget.bigId).future,
          );
          // 取得中にページを離れていたら、次のページの状態を壊さないよう何もしない
          if (!mounted) {
            return;
          }
          ref
              .read(
                edittingIncomeSmallCategoryListNotifierProvider(
                  widget.bigId,
                ).notifier,
              )
              .setData(initialList);
          setState(() {
            _isInitialized = true;
            _rebuildControllers();
          });
        } else {
          final initialList = await ref.watch(
            allSmallCategoriesListProvider(widget.bigId).future,
          );
          if (!mounted) {
            return;
          }
          ref
              .read(
                edittingSmallCategoryListNotifierProvider(
                  widget.bigId,
                ).notifier,
              )
              .setData(initialList);
          setState(() {
            _isInitialized = true;
            _rebuildControllers();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// [item] の行を削除できるか（KP-024）
  ///
  /// 入力画面で選べるカテゴリーが無くならないよう最後の1件は残す。
  /// 収入の給与・ボーナスは収入追加の初期選択に使うため削除させない
  bool _canDelete(dynamic item) {
    if (itemList.length <= 1) {
      return false;
    }
    if (widget.categoryType == CategoryType.income &&
        IncomeCategoryUsecase.isDefaultSmallCategory(item.id as int)) {
      return false;
    }
    return true;
  }

  /// 行頭の削除ボタンのタップ処理（KP-024）
  ///
  /// 既存の小カテゴリーは確認してからリストを外し、保存時に論理削除する。
  /// まだDBに無い項目は確認せずに外す。固定費が使っている小カテゴリーは外さずに案内する
  Future<void> _onDeleteTap(dynamic item) async {
    final id = item.id as int;
    final name = _controllerFor(item).text;

    if (id >= 0) {
      if (widget.categoryType == CategoryType.expense) {
        final fixedCostNames = await ref
            .read(categoryUsecaseProvider)
            .fetchFixedCostNamesUsingSmallCategories([id]);
        if (!mounted) {
          return;
        }
        if (fixedCostNames.isNotEmpty) {
          await showCategoryInUseByFixedCostDialog(
            context,
            categoryName: name,
            fixedCostNames: fixedCostNames,
          );
          return;
        }
      }

      final recordLabel =
          widget.categoryType == CategoryType.income ? '収入' : '支出';
      final shouldDelete = await showCategoryDeleteConfirmationDialog(
        context,
        categoryName: name,
        message: '削除した小カテゴリーは元に戻せません。\n登録済みの$recordLabelはそのまま残ります。',
      );
      if (!shouldDelete || !mounted) {
        return;
      }
    }

    if (widget.categoryType == CategoryType.income) {
      ref
          .read(
            edittingIncomeSmallCategoryListNotifierProvider(
              widget.bigId,
            ).notifier,
          )
          .removeById(id);
      ref
          .read(
            isIncomeSmallCategoryListEditedNotifierProvider(
              widget.bigId,
            ).notifier,
          )
          .updateState(true);
    } else {
      ref
          .read(
            edittingSmallCategoryListNotifierProvider(widget.bigId).notifier,
          )
          .removeById(id);
      ref
          .read(
            isSmallCategoryListEditedNotifierProvider(widget.bigId).notifier,
          )
          .updateState(true);
    }
  }

  /// 名称の変更処理
  void _updateName(int index, String value) {
    if (widget.categoryType == CategoryType.income) {
      ref
          .read(
            edittingIncomeSmallCategoryListNotifierProvider(
              widget.bigId,
            ).notifier,
          )
          .updateName(index, value);
      ref
          .read(
            isIncomeSmallCategoryListEditedNotifierProvider(
              widget.bigId,
            ).notifier,
          )
          .updateState(true);
    } else {
      ref
          .read(
            edittingSmallCategoryListNotifierProvider(widget.bigId).notifier,
          )
          .updateName(index, value);
      ref
          .read(
            isSmallCategoryListEditedNotifierProvider(widget.bigId).notifier,
          )
          .updateState(true);
    }
  }

  /// 末尾の「小カテゴリーを追加」アクション行
  ///
  /// 並べ替えの対象ではないため、リストの要素ではなく footer として置く
  /// （要素にすると他の行のドロップ先になり、この行を挟んだ並びになってしまう）。
  /// 件数は引数で受け取る（[itemList] は build で代入される late なので、
  /// 区切り線の判定が別のタイミングの値を見ないようにする）。
  Widget _buildAddRow(BuildContext context, int itemCount) {
    return Column(
      children: [
        if (itemCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: kAppInsetRowIndent),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: context.colors.separator,
            ),
          ),
        AppInkWell(
          borderRadius: BorderRadius.zero,
          onTap: () {
            showNewSmallCategoryInputSheet(
              context,
              bigCategoryId: widget.bigId,
              categoryType: widget.categoryType,
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
                    AppIcons.add,
                    size: kAppInsetRowIconSize,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '小カテゴリーを追加',
                    style: context.textStyles.insetGroupLabel.copyWith(
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

  @override
  Widget build(BuildContext context) {
    // アイテムリストを状態監視（大カテゴリーごとの状態）
    itemList = widget.categoryType == CategoryType.income
        ? ref.watch(
            edittingIncomeSmallCategoryListNotifierProvider(widget.bigId),
          )
        : ref.watch(edittingSmallCategoryListNotifierProvider(widget.bigId));

    // 編集済みフラグは完了ボタンが読む。autoDisposeなので購読者がいないと
    // 書き込んだ直後に破棄されてしまうため、このエリアの表示中は購読して保持する
    if (widget.categoryType == CategoryType.income) {
      ref.watch(isIncomeSmallCategoryListEditedNotifierProvider(widget.bigId));
    } else {
      ref.watch(isSmallCategoryListEditedNotifierProvider(widget.bigId));
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
              child: Text('小カテゴリー', style: context.textStyles.insetGroupHeader),
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
                                edittingIncomeSmallCategoryListNotifierProvider(
                                  widget.bigId,
                                ).notifier,
                              )
                              .reorder(oldIndex, newIndex);
                          ref
                              .read(
                                isIncomeSmallCategoryListEditedNotifierProvider(
                                  widget.bigId,
                                ).notifier,
                              )
                              .updateState(true);
                        } else {
                          // カテゴリーの状態を保持しているリストの並び替え
                          ref
                              .read(
                                edittingSmallCategoryListNotifierProvider(
                                  widget.bigId,
                                ).notifier,
                              )
                              .reorder(oldIndex, newIndex);

                          // 変更を加えたことを管理する状態管理する
                          ref
                              .read(
                                isSmallCategoryListEditedNotifierProvider(
                                  widget.bigId,
                                ).notifier,
                              )
                              .updateState(true);
                        }

                        // コントローラーはidで引くため、並べ替えの追従は不要
                      },
                      // 「小カテゴリーを追加」はアクション行であって並べ替えの対象ではない。
                      // footerはリストの要素に含まれないため、他の行のドロップ先にもならない。
                      // 取得が終わってから出す（取得前に追加すると取得完了時の setData で消えてしまう）
                      footer: _isInitialized
                          ? _buildAddRow(context, itemList.length)
                          : null,
                      itemCount: itemList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = itemList[index];
                        final controller = _controllerFor(item);

                        // 並べ替え可能なリストのアイテム。
                        // キーは位置ではなくidにする（位置キーだと行の状態
                        // ―フォーカスやIME― が並べ替えで別の項目に付いてしまう）
                        return Column(
                          key: ValueKey<int>(item.id),
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
                                    // 削除ボタン（KP-024。旧・表示切替のチェックボックス）
                                    CategoryDeleteRowButton(
                                      onTap: _canDelete(item)
                                          ? () => _onDeleteTap(item)
                                          : null,
                                    ),

                                    const SizedBox(width: 10),

                                    // カテゴリー名（直接編集可能）
                                    Expanded(
                                      child: TextFormField(
                                        controller: controller,
                                        style: context.textStyles.insetGroupLabel,
                                        maxLines: 1,
                                        maxLength: 20,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          counterText: '',
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (value) =>
                                            _updateName(index, value),
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
                                          AppIcons.dragHandle,
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
