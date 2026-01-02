import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_selection_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view_model/state/category_reorder/reordering_category_list.dart';

/// カテゴリー並び替えページ
///
/// ドラッグ＆ドロップでカテゴリーアイコンの表示順を変更できる
class CategoryReorderPage extends ConsumerStatefulWidget {
  const CategoryReorderPage({
    super.key,
    required this.transactionMode,
  });

  final TransactionMode transactionMode;

  @override
  ConsumerState<CategoryReorderPage> createState() =>
      _CategoryReorderPageState();
}

class _CategoryReorderPageState extends ConsumerState<CategoryReorderPage> {
  static const int columns = 5;
  static const int rows = 3;
  static const int slotsPerPage = columns * rows; // 15

  final PageController _pageController = PageController();
  int _currentPage = 0;

  int? _draggingId; // ドラッグ中のアイテムID
  int? _lastHoverId; // 直前にswapしたターゲットID（暴発防止）
  DateTime? _lastPageFlip; // 連続でページめくりしないためのガード

  @override
  void initState() {
    super.initState();
    _initializeData();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  /// 初期データを読み込む
  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final categories = await ref
          .read(categoriesByModeProvider(widget.transactionMode).future);
      ref
          .read(reorderingCategoryListNotifierProvider.notifier)
          .setData(categories, widget.transactionMode);
    });
  }

  int get pageCount {
    final items = ref.watch(reorderingCategoryListNotifierProvider).items;
    return items.isEmpty
        ? 1
        : (items.length + slotsPerPage - 1) ~/ slotsPerPage;
  }

  /// ページ(page)のスロット(slot:0..14) -> items の index を返す（なければ null）
  int? listIndexFromSlot(int page, int slot) {
    final items = ref.read(reorderingCategoryListNotifierProvider).items;
    final idx = page * slotsPerPage + slot;
    return (idx < items.length) ? idx : null;
  }

  /// ドラッグ中に左右端へ寄ったら自動でページをめくる
  void maybeFlipPage(Offset globalPos) {
    final now = DateTime.now();

    // onDragUpdateは高頻度なので、連続めくりを防ぐ（350msクールダウン）
    if (_lastPageFlip != null &&
        now.difference(_lastPageFlip!).inMilliseconds < 350) {
      return;
    }

    final width = MediaQuery.of(context).size.width;
    const edge = 24.0; // 左右端の判定幅（px）

    final currentPageNum = (_pageController.page ?? 0).round();

    // 左端 → 前のページ
    if (globalPos.dx < edge && currentPageNum > 0) {
      _lastPageFlip = now;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    // 右端 → 次のページ
    else if (globalPos.dx > width - edge && currentPageNum < pageCount - 1) {
      _lastPageFlip = now;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  /// タイルのデコレーションを構築
  Widget buildTile({
    required Widget child,
    required bool isDragging,
  }) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: isDragging ? 0.96 : 1.0,
      child: Container(
        decoration: const BoxDecoration(
          color: MyColors.secondarySystemfill,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  /// アイコンウィジェットを構築（アニメーション付き）
  Widget animatedIcon(ReorderingCategoryItem item) {
    final color = MyColors().getColorFromHex(item.colorCode);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        );
      },
      child: SvgPicture.asset(
        item.resourcePath,
        key: ValueKey(item.id),
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        width: 25,
        height: 25,
      ),
    );
  }

  /// 並び替え結果を保存
  Future<void> _saveOrder() async {
    final state = ref.read(reorderingCategoryListNotifierProvider);
    if (!state.hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final newOrders = ref
        .read(reorderingCategoryListNotifierProvider.notifier)
        .getNewDisplayOrders();

    try {
      switch (widget.transactionMode) {
        case TransactionMode.expense:
          await ref
              .read(categoryUsecaseProvider)
              .updateDisplayOrders(newOrders);
          ref.invalidate(allCategoriesProvider);
          break;
        case TransactionMode.fixedCost:
          await ref
              .read(fixedCostCategoryUsecaseProvider)
              .updateDisplayOrders(newOrders);
          ref.invalidate(allFixedCostCategoriesProvider);
          break;
        case TransactionMode.income:
          await ref
              .read(incomeCategoryUsecaseProvider)
              .updateDisplayOrders(newOrders);
          ref.invalidate(allIncomeCategoriesProvider);
          break;
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reorderingState = ref.watch(reorderingCategoryListNotifierProvider);
    final items = reorderingState.items;

    return Scaffold(
      backgroundColor: MyColors.secondarySystemBackground,
      appBar: AppBar(
        backgroundColor: MyColors.secondarySystemBackground,
        title: Text(
          'アイコンの並び替え',
          style: AppTextStyles.pageHeaderText,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: MyColors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveOrder,
            child: Text(
              '保存',
              style: TextStyle(
                color: reorderingState.hasChanges
                    ? MyColors.white
                    : MyColors.secondaryLabel,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 16),

                  // 説明テキスト
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'アイコンを長押しして並び替えができます',
                      style: TextStyle(
                        color: MyColors.secondaryLabel,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // グリッド部分
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pageCount,
                      itemBuilder: (context, page) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildCategoryGrid(page, items),
                        );
                      },
                    ),
                  ),

                  // ページインジケーター
                  if (pageCount > 1) ...[
                    const SizedBox(height: 16),
                    _buildPageIndicator(),
                    const SizedBox(height: 32),
                  ] else ...[
                    const SizedBox(height: 32),
                  ],
                ],
              ),
      ),
    );
  }

  /// カテゴリーグリッドを構築
  Widget _buildCategoryGrid(int page, List<ReorderingCategoryItem> items) {
    final screenVerticalMagnification = context.screenVerticalMagnification;
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // アイコンサイズ
    final iconBoxSize = 58 * screenVerticalMagnification;
    final labelWidth = 62.2 * ((screenHorizontalMagnification - 1) / 5 + 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 12 : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(columns, (columnIndex) {
              final slot = rowIndex * columns + columnIndex;
              final idx = listIndexFromSlot(page, slot);

              // 空枠
              if (idx == null) {
                return SizedBox(
                  width: iconBoxSize,
                  height: iconBoxSize + 20,
                );
              }

              final item = items[idx];
              final isDragging = (_draggingId == item.id);

              return DragTarget<int>(
                onWillAcceptWithDetails: (details) {
                  final fromId = details.data;
                  if (fromId == item.id) return false;
                  return true;
                },
                onMove: (_) {
                  final fromId = _draggingId;
                  if (fromId == null) return;

                  // hoverした瞬間にswap（リアルタイム入れ替え）
                  if (_lastHoverId != item.id) {
                    _lastHoverId = item.id;
                    ref
                        .read(reorderingCategoryListNotifierProvider.notifier)
                        .insertById(fromId, item.id);
                  }
                },
                onLeave: (_) => _lastHoverId = null,
                builder: (context, candidate, rejected) {
                  return LongPressDraggable<int>(
                    data: item.id,
                    onDragStarted: () {
                      setState(() {
                        _draggingId = item.id;
                        _lastHoverId = null;
                      });
                    },
                    onDragUpdate: (d) => maybeFlipPage(d.globalPosition),
                    onDragEnd: (_) {
                      setState(() {
                        _draggingId = null;
                        _lastHoverId = null;
                      });
                    },
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        child: buildTile(
                          isDragging: true,
                          child: animatedIcon(item),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildCategoryItem(
                        item: item,
                        iconBoxSize: iconBoxSize,
                        labelWidth: labelWidth,
                        isDragging: true,
                      ),
                    ),
                    child: _buildCategoryItem(
                      item: item,
                      iconBoxSize: iconBoxSize,
                      labelWidth: labelWidth,
                      isDragging: isDragging,
                    ),
                  );
                },
              );
            }),
          ),
        );
      }),
    );
  }

  /// カテゴリーアイテム（アイコン＋ラベル）を構築
  Widget _buildCategoryItem({
    required ReorderingCategoryItem item,
    required double iconBoxSize,
    required double labelWidth,
    required bool isDragging,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconBoxSize,
          height: iconBoxSize,
          child: buildTile(
            isDragging: isDragging,
            child: animatedIcon(item),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: labelWidth,
          child: Text(
            item.categoryName,
            style: RegisterPageStyles.categoryLabel,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// ページインジケーターを構築
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? MyColors.tirtiarySystemfill
                : MyColors.separater,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
