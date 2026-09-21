import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_selection_provider.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/none_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/normal_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/selected_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/category_reorder_page.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view_model/state/input_mode_controller.dart';
import 'package:kakeibo/view_model/state/register_page/select_category_controller/select_category_controller.dart';
import 'package:kakeibo/constant/icon.dart';

/// カテゴリー選択エリアウィジェット
///
/// 支出・収入登録画面でカテゴリーを選択するためのグリッド表示。
/// 1ページに15個（5列 x 3行）のカテゴリーを表示し、
/// カテゴリー数が15個以上の場合はページネーションで表示。
class CategoryArea extends ConsumerStatefulWidget {
  const CategoryArea({
    super.key,
    required this.originalCategoryId,
    required this.transactionMode,
    this.showRearrangeLink = true,
    this.showCategorySettingEntry = true,
  });

  /// 初期選択されるカテゴリーID
  final int originalCategoryId;

  /// トランザクションの種類（支出/収入）
  final TransactionMode transactionMode;

  /// アイコン並べ替えリンクを表示するか
  final bool showRearrangeLink;

  /// カテゴリー設定への入口（最終ページ末尾の「追加・編集」セルと下部のリンク）を表示するか（KP-027）
  final bool showCategorySettingEntry;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CategoryAreaState();
}

class _CategoryAreaState extends ConsumerState<CategoryArea> {
  final pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeSelectedCategory();
    pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  /// 初期選択カテゴリーを設定
  void _initializeSelectedCategory() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Providerを使用してTransactionModeに応じたカテゴリーを取得
      final categoryEntity = await ref.read(
        categoryByModeProvider(
          mode: widget.transactionMode,
          categoryId: widget.originalCategoryId,
        ).future,
      );

      // 取得完了時点で自分が既に破棄されている・アクティブなモードでない場合は反映しない。
      // 登録シートは初期フレームを支出タブで描画してから指定モードへ切り替えるため、
      // ガード無しだと旧タブ側の非同期初期化が後着で選択を上書きする
      // （例: 特別枠の「新しい収入を追加」でボーナス初期選択が給与に化ける）
      if (!mounted) return;
      if (ref.read(inputModeControllerProvider) != widget.transactionMode) {
        return;
      }

      ref
          .read(selectCategoryControllerNotifierProvider.notifier)
          .setData(categoryEntity);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 選択中のカテゴリーを監視
    final ICategoryEntity selectedCategory = ref.watch(
      selectCategoryControllerNotifierProvider,
    );

    // 画面サイズの倍率
    final screenHorizontalMagnification = context.screenHorizontalMagnification;
    final screenVerticalMagnification = context.screenVerticalMagnification;

    // TransactionModeに応じたカテゴリーリストを取得
    return ref
        .watch(categoriesByModeProvider(widget.transactionMode))
        .when(
          // DB更新での再読み込み中は前の一覧を出したままにする（一瞬スピナーに替わるのを防ぐ。KP-027）
          skipLoadingOnReload: true,
          data: (categories) {
            // 「追加・編集」セルは最後のカテゴリーの次に1つだけ置く（KP-027）。
            // ページ数・行数はこのセルを含めた個数で数える
            // （カテゴリー数が15の倍数なら、セルだけの最終ページができる）
            final cellCount =
                categories.length + (widget.showCategorySettingEntry ? 1 : 0);

            // ページネーション情報を取得
            final pagination = ref.watch(categoryPaginationProvider(cellCount));

            // ADR-020: 3行分を常に確保せず、実際のカテゴリー数から必要な行数だけ枠を取る
            // （空セルを非表示にしても外枠が固定250pxのままだと下の要素が詰まらないため）
            final rowsNeeded = _rowsNeededFor(cellCount);
            final gridHeight = _gridHeightFor(
              rowsNeeded,
              screenVerticalMagnification,
            );

            return Column(
              children: [
                // カテゴリーグリッド
                SizedBox(
                  height: gridHeight,
                  width: 343 * screenHorizontalMagnification,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: pagination.pageCount,
                    itemBuilder: (context, pageIndex) {
                      return _buildCategoryGrid(
                        pageIndex: pageIndex,
                        categories: categories,
                        selectedCategory: selectedCategory,
                        itemsPerPage: pagination.itemsPerPage,
                        rows: rowsNeeded,
                      );
                    },
                  ),
                ),

                // ページインジケーター（2ページ以上の場合のみ表示）
                Visibility(
                  visible: pagination.pageCount > 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // 前後の余白を詰め、固定費トグルONでも並べ替えリンクが画面内に残るようにする（KP-020）
                    // 下側はリンク自身の上パディング（8）と合わせて見た目の間隔を取る
                    children: [
                      const SizedBox(height: 8),
                      _buildPageIndicator(pagination.pageCount),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

                // 「アイコンを並べ替える」「カテゴリーを設定」のリンク
                // 狭い端末で横に収まらないときは折り返す
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    if (widget.showRearrangeLink) _buildRearrangeLink(context),
                    if (widget.showCategorySettingEntry)
                      _buildCategorySettingLink(context),
                  ],
                ),
              ],
            );
          },
          error: (error, stackTrace) => const AppErrorState(),
          loading: () => const CircularProgressIndicator(),
        );
  }

  /// ページインジケーターを構築
  Widget _buildPageIndicator(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? context.colors.fillTertiary
                : context.colors.separator,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// 「アイコンを並べ替える」リンクを構築
  Widget _buildRearrangeLink(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        showAppModalBottomSheet(
          context,
          child: CategoryReorderPage(transactionMode: widget.transactionMode),
        );
      },
      child: Padding(
        // 「カテゴリーを設定」と横に並べて収めるため左右を詰める（KP-027）
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 歯車は「カテゴリーを設定」に譲り、並べ替えはアイコンの並びを表す絵にする（KP-027）
            Icon(
              AppIcons.iconGrid,
              size: 16,
              color: context.colors.textSecondary,
            ),
            const SizedBox(width: 6),
            // 「カテゴリーを設定」と1行に収めるため文言を短くした（KP-027。旧「アイコンを並べ替える」）
            Text('並べ替え', style: context.registerStyles.rearrangeLink),
          ],
        ),
      ),
    );
  }

  /// 「カテゴリーを設定」リンクを構築（KP-027）
  Widget _buildCategorySettingLink(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _openCategorySetting,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.settings,
              size: 16,
              color: context.colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text('カテゴリーを設定', style: context.registerStyles.rearrangeLink),
          ],
        ),
      ),
    );
  }

  /// カテゴリー設定を記録のモードのタブで開く（KP-027）
  ///
  /// 閉じたら記録モーダルへ戻る。入力途中の値は保持し、選択中のカテゴリーが
  /// 削除されていた場合だけ未選択に戻す。
  Future<void> _openCategorySetting() async {
    await showAppModalBottomSheet(
      context,
      child: CategorySettingPage(
        initialCategoryType: widget.transactionMode == TransactionMode.income
            ? CategoryType.income
            : CategoryType.expense,
      ),
    );
    if (!mounted) return;

    final categories = await ref.read(
      categoriesByModeProvider(widget.transactionMode).future,
    );
    if (!mounted) return;

    final selected = ref.read(selectCategoryControllerNotifierProvider);
    if (!categories.any((c) => c.id == selected.id)) {
      ref.invalidate(selectCategoryControllerNotifierProvider);
    }
  }

  /// カテゴリー数から必要な行数を算出（5列・最大3行）
  int _rowsNeededFor(int categoryCount) {
    const columns = 5;
    const maxRows = 3;
    if (categoryCount <= 0) return 1;
    return (((categoryCount - 1) ~/ columns) + 1).clamp(1, maxRows);
  }

  /// 行数からグリッド外枠の高さを算出。NoneIconBoxの1セル分の高さ・行間パディング(6px)と揃える
  ///
  /// 実機で実測ベースに微調整済み（テキストの実際の行高は端末フォントで変動するため、
  /// 溢れを避ける安全マージンを含めた値にしている）。
  double _gridHeightFor(int rows, double screenVerticalMagnification) {
    const rowContentHeight = 34 + 30; // アイコン34px + ラベル/下線ドット分＋安全マージン
    final rowHeight = rowContentHeight * screenVerticalMagnification;
    const interRowGap = 6.0;
    return rows * rowHeight + (rows - 1) * interRowGap;
  }

  /// カテゴリーグリッドを構築（5列 x rows行）
  Widget _buildCategoryGrid({
    required int pageIndex,
    required List<ICategoryEntity> categories,
    required ICategoryEntity selectedCategory,
    required int itemsPerPage,
    required int rows,
  }) {
    const columns = 5;

    return Column(
      // ADR-020: 空セルを見せないため均等配置(spaceBetween)ではなく上詰め(start)にする
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        rows,
        (rowIndex) => Padding(
          padding: _getPaddingForRow(rowIndex, isLast: rowIndex == rows - 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(columns, (columnIndex) {
              final buttonNumber =
                  pageIndex * itemsPerPage + rowIndex * columns + columnIndex;

              // 最後のカテゴリーの次のセルは「追加・編集」（最終ページにだけ現れる。KP-027）
              if (widget.showCategorySettingEntry &&
                  buttonNumber == categories.length) {
                return Padding(
                  padding: _getPaddingForColumn(columnIndex),
                  child: _buildCategorySettingCell(context),
                );
              }

              // ボタン状態を判定
              final buttonStatus = getButtonStatus(
                buttonNumber: buttonNumber,
                categoryCount: categories.length,
                selectedCategoryId: selectedCategory.id,
                categories: categories,
              );

              return Padding(
                padding: _getPaddingForColumn(columnIndex),
                child: _buildCategoryButton(
                  buttonStatus: buttonStatus,
                  buttonNumber: buttonNumber,
                  categories: categories,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// 「追加・編集」セルを構築（KP-027）
  ///
  /// 寸法は [NormalIconButton] と揃える（アイコン枠34・ラベル幅・下線ドット分の透明スロット）。
  Widget _buildCategorySettingCell(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: _openCategorySetting,
      child: Column(
        children: [
          SizedBox(
            height: 34 * context.screenVerticalMagnification,
            width: 34 * context.screenVerticalMagnification,
            child: Icon(AppIcons.add, size: 25, color: context.colors.primary),
          ),
          SizedBox(
            width: 62.2 * ((context.screenHorizontalMagnification - 1) / 5 + 1),
            child: Center(
              // 5文字はラベル幅にわずかに収まらず「追加・…」と省略されるため、幅に合わせて縮める
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '追加・編集',
                  style: context.registerStyles.categoryLabelUnselected
                      .copyWith(color: context.colors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          const SizedBox(width: 14, height: 2.5),
        ],
      ),
    );
  }

  /// 行位置に応じたパディングを取得
  EdgeInsets _getPaddingForRow(int rowIndex, {required bool isLast}) {
    if (isLast) {
      return const EdgeInsets.only(bottom: 0);
    }
    return const EdgeInsets.only(bottom: 6);
  }

  /// 列位置に応じたパディングを取得
  EdgeInsets _getPaddingForColumn(int columnIndex) {
    if (columnIndex == 0) {
      return const EdgeInsets.only(right: 4);
    } else if (columnIndex == 4) {
      return const EdgeInsets.only(left: 4);
    }
    return const EdgeInsets.symmetric(horizontal: 4);
  }

  /// ボタン状態に応じたウィジェットを構築
  Widget _buildCategoryButton({
    required ButtonStatus buttonStatus,
    required int buttonNumber,
    required List<ICategoryEntity> categories,
  }) {
    return switch (buttonStatus) {
      ButtonStatus.selected => SelectedIconButton(
        categoryEntity: categories[buttonNumber],
      ),
      ButtonStatus.normal => NormalIconButton(
        categoryEntity: categories[buttonNumber],
      ),
      ButtonStatus.none => const NoneIconBox(),
    };
  }
}
