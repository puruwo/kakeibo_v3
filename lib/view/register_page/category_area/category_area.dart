import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_selection_provider.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/none_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/normal_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/selected_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/category_reorder_page.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view_model/state/register_page/select_category_controller/select_category_controller.dart';

/// カテゴリー選択エリアウィジェット
///
/// 支出・固定費・収入登録画面でカテゴリーを選択するためのグリッド表示。
/// 1ページに15個（5列 x 3行）のカテゴリーを表示し、
/// カテゴリー数が15個以上の場合はページネーションで表示。
class CategoryArea extends ConsumerStatefulWidget {
  const CategoryArea({
    super.key,
    required this.originalCategoryId,
    required this.transactionMode,
    this.showRearrangeLink = true,
  });

  /// 初期選択されるカテゴリーID
  final int originalCategoryId;

  /// トランザクションの種類（支出/固定費/収入）
  final TransactionMode transactionMode;

  /// アイコン並べ替えリンクを表示するか
  final bool showRearrangeLink;

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

      ref
          .read(selectCategoryControllerNotifierProvider.notifier)
          .setData(categoryEntity);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 選択中のカテゴリーを監視
    final ICategoryEntity selectedCategory =
        ref.watch(selectCategoryControllerNotifierProvider);

    // 画面サイズの倍率
    final screenHorizontalMagnification = context.screenHorizontalMagnification;
    final screenVerticalMagnification = context.screenVerticalMagnification;

    // TransactionModeに応じたカテゴリーリストを取得
    return ref.watch(categoriesByModeProvider(widget.transactionMode)).when(
          data: (categories) {
            // ページネーション情報を取得
            final pagination = ref.watch(
              categoryPaginationProvider(categories.length),
            );

            // ADR-020: 3行分を常に確保せず、実際のカテゴリー数から必要な行数だけ枠を取る
            // （空セルを非表示にしても外枠が固定250pxのままだと下の要素が詰まらないため）
            final rowsNeeded = _rowsNeededFor(categories.length);
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
                    children: [
                      const SizedBox(height: 20),
                      _buildPageIndicator(pagination.pageCount),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // アイコンを並べ替えるリンク
                if (widget.showRearrangeLink) ...[
                  _buildRearrangeLink(context),
                ],
              ],
            );
          },
          error: (error, stackTrace) => const Text('エラーが発生しました'),
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
          child: CategoryReorderPage(
            transactionMode: widget.transactionMode,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 16,
              color: context.colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'アイコンを並べ替える',
              style: RegisterPageStyles.rearrangeLink,
            ),
          ],
        ),
      ),
    );
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
            children: List.generate(
              columns,
              (columnIndex) {
                final buttonNumber =
                    pageIndex * itemsPerPage + rowIndex * columns + columnIndex;

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
              },
            ),
          ),
        ),
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
