import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_selection_provider.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/none_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/normal_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/selected_icon_button.dart';
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
  });

  /// 初期選択されるカテゴリーID
  final int originalCategoryId;

  /// トランザクションの種類（支出/固定費/収入）
  final TransactionMode transactionMode;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CategoryAreaState();
}

class _CategoryAreaState extends ConsumerState<CategoryArea> {
  final pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _initializeSelectedCategory();
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

            return SizedBox(
              height: 200 * screenVerticalMagnification,
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
                  );
                },
              ),
            );
          },
          error: (error, stackTrace) => const Text('エラーが発生しました'),
          loading: () => const CircularProgressIndicator(),
        );
  }

  /// カテゴリーグリッドを構築（5列 x 3行）
  Widget _buildCategoryGrid({
    required int pageIndex,
    required List<ICategoryEntity> categories,
    required ICategoryEntity selectedCategory,
    required int itemsPerPage,
  }) {
    const rows = 3;
    const columns = 5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        rows,
        (rowIndex) => Row(
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
    );
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
