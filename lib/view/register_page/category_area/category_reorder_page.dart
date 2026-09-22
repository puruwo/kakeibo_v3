import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/application/category/displayed_category_provider.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/application/category/register_grid_category_rule.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/category_list_page/category_big_list_page.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view_model/state/category_reorder/reordering_category_list.dart';
import 'package:kakeibo/constant/icon.dart';

/// 記録画面のカテゴリー（旧「アイコンの並び替え」。KP-032）
///
/// 記録モーダルのグリッドに直接出すカテゴリーを決める画面。
/// - ドラッグ＆ドロップで表示順を変える（従来）
/// - セル右上の「−」で記録画面から外す（表示中が1件のときは外せない）
/// - 末尾の「＋ 追加」セル／下のリンク「記録画面に追加」で全カテゴリーの一覧から加える
/// - 保存で `default_displayed` と表示順をまとめて更新する
class CategoryReorderPage extends ConsumerStatefulWidget {
  const CategoryReorderPage({super.key, required this.transactionMode});

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

  /// 初期データ（記録画面に表示中のカテゴリー）を読み込む
  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final categories = await ref.read(
        displayedCategoriesByModeProvider(widget.transactionMode).future,
      );
      ref
          .read(reorderingCategoryListNotifierProvider.notifier)
          .setData(categories, widget.transactionMode);
    });
  }

  /// カテゴリー設定を並び替え中のモードのタブで開く（KP-027）
  ///
  /// 設定側で何も変更されなければ、未保存の並び順を保持したまま戻る。
  /// カテゴリーが追加・編集・削除されていたら、古い一覧のまま保存しないよう読み込み直す
  /// （このとき未保存の並び順は破棄される）。
  Future<void> _openCategorySetting() async {
    final dbCountBefore = ref.read(updateDBCountNotifierProvider);
    await showAppModalBottomSheet(
      context,
      child: CategorySettingPage(
        initialCategoryType: widget.transactionMode == TransactionMode.income
            ? CategoryType.income
            : CategoryType.expense,
      ),
    );
    if (!mounted) return;
    if (ref.read(updateDBCountNotifierProvider) != dbCountBefore) {
      await _initializeData();
    }
  }

  /// 全カテゴリーの一覧（追加モード）を開き、選ばれたカテゴリーを末尾に加える（KP-032）
  ///
  /// 表示中の項目は一覧側で「表示中」になりタップできない。保存するまで確定しない。
  Future<void> _openAddList() async {
    final notifier = ref.read(reorderingCategoryListNotifierProvider.notifier);
    final result = await showAppModalBottomSheet<ICategoryEntity>(
      context,
      child: CategoryBigListPage(
        transactionMode: widget.transactionMode,
        mode: CategoryListMode.add,
        displayedIds: notifier.displayedIds.toSet(),
      ),
    );
    if (!mounted || result == null) return;
    notifier.addCategory(result);
  }

  /// 記録画面から外す（保存するまで確定しない）
  void _remove(int id) {
    ref.read(reorderingCategoryListNotifierProvider.notifier).removeById(id);
  }

  /// セル数（表示中＋上限未満なら「＋ 追加」セル）からページ数を求める
  int get pageCount {
    final items = ref.watch(reorderingCategoryListNotifierProvider).items;
    final cellCount =
        items.length + (RegisterGridCategoryRule.isFull(items.length) ? 0 : 1);
    return RegisterGridCategoryRule.pageCountFor(cellCount);
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

  /// タイルの構築。ADR-020: 選択グリッドと同じ裸アイコンに統一し円は使わない。
  /// ドラッグ中のスケールフィードバックのみ残す。
  Widget buildTile({required Widget child, required bool isDragging}) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: isDragging ? 0.96 : 1.0,
      child: Center(child: child),
    );
  }

  /// アイコンウィジェットを構築（アニメーション付き）
  Widget animatedIcon(ReorderingCategoryItem item) {
    final color = ColorCode.toColor(item.colorCode);

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

  /// 表示中のカテゴリーと並び順を保存
  Future<void> _saveOrder() async {
    final state = ref.read(reorderingCategoryListNotifierProvider);
    if (!state.hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final displayedIds = ref
        .read(reorderingCategoryListNotifierProvider.notifier)
        .displayedIds;

    try {
      switch (widget.transactionMode) {
        case TransactionMode.expense:
          await ref
              .read(categoryUsecaseProvider)
              .updateRegisterGrid(displayedIds);
          ref.invalidate(allCategoriesProvider);
          break;
        case TransactionMode.income:
          await ref
              .read(incomeCategoryUsecaseProvider)
              .updateRegisterGrid(displayedIds);
          ref.invalidate(allIncomeCategoriesProvider);
          break;
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        FailureSnackBar.show(
          ScaffoldMessenger.of(context),
          message: '保存に失敗しました',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reorderingState = ref.watch(reorderingCategoryListNotifierProvider);
    final items = reorderingState.items;
    final isFull = RegisterGridCategoryRule.isFull(items.length);

    return Scaffold(
      backgroundColor: context.colors.surfaceElevated,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        title: Text('記録画面のカテゴリー', style: context.textStyles.pageHeaderText),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(AppIcons.close, color: context.colors.text),
        ),
      ),
      body: SafeArea(
        child: items.isEmpty && !reorderingState.hasChanges
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 保存ボタンを画面下部に固定するため、それ以外のコンテンツを
                  // Expandedで上詰めにし、余った縦スペースをここで吸収する。
                  // 縦の短い端末では見出し・リンクが収まらないためスクロールを許可する（KP-032）
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // 見出し＋件数（n／29）
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '記録画面に表示',
                                  style: context.textStyles.insetGroupHeader,
                                ),
                                Text(
                                  '${items.length}／${RegisterGridCategoryRule.maxDisplayedCount}',
                                  style: context
                                      .textStyles
                                      .insetGroupHeaderNumeric,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // 説明テキスト（上限到達時は注意文に差し替える）
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                isFull
                                    ? '表示できるのは ${RegisterGridCategoryRule.maxDisplayedCount} 件までです。外してから追加してください'
                                    : '長押しして並び替え',
                                style: isFull
                                    ? context
                                          .registerStyles
                                          .iconRearrangeDescription
                                          .copyWith(
                                            color: context.colors.danger,
                                          )
                                    : context
                                          .registerStyles
                                          .iconRearrangeDescription,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // グリッド部分
                          SizedBox(
                            height: 270 * context.screenVerticalMagnification,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: pageCount,
                              itemBuilder: (context, page) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: _buildCategoryGrid(page, items),
                                );
                              },
                            ),
                          ),

                          // ページインジケーター
                          if (pageCount > 1) ...[
                            const SizedBox(height: 16),
                            _buildPageIndicator(),
                          ],

                          const SizedBox(height: 8),

                          // 追加の導線（上限到達時は非活性）とカテゴリー設定への入口
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              _buildLink(
                                icon: AppIcons.add,
                                label: '記録画面に追加',
                                onTap: isFull ? null : _openAddList,
                              ),
                              // KP-027 の「カテゴリーの追加・編集」。記録モーダルのリンクと文言をそろえた（KP-032）
                              _buildLink(
                                icon: AppIcons.settings,
                                label: 'カテゴリーを設定',
                                onTap: _openCategorySetting,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: MainButton(
                        iconData: AppIcons.done,
                        onPressed: reorderingState.hasChanges
                            ? _saveOrder
                            : null,
                        buttonText: '保存',
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 本文内の補助リンク（`onTap` が null なら非活性）
  Widget _buildLink({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final color = onTap == null
        ? context.colors.textTertiary
        : context.colors.primary;
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textStyles.textButtonTextStyle.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return Semantics(button: true, enabled: false, child: content);
    }
    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: content,
    );
  }

  /// カテゴリーグリッドを構築
  Widget _buildCategoryGrid(int page, List<ReorderingCategoryItem> items) {
    final screenVerticalMagnification = context.screenVerticalMagnification;
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // アイコンサイズ
    // ADR-020: 選択グリッドと同じアイコンサイズに揃える（旧: 円背景込みで58）
    final iconBoxSize = 34 * screenVerticalMagnification;
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

              if (idx == null) {
                // 最後のカテゴリーの次のセルは「＋ 追加」（上限到達時は出さない。KP-032）
                if (page * slotsPerPage + slot == items.length &&
                    !RegisterGridCategoryRule.isFull(items.length)) {
                  return _buildAddCell(
                    iconBoxSize: iconBoxSize,
                    labelWidth: labelWidth,
                  );
                }
                // 空枠
                return SizedBox(width: iconBoxSize, height: iconBoxSize + 20);
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
                        canRemove: items.length > 1,
                      ),
                    ),
                    child: _buildCategoryItem(
                      item: item,
                      iconBoxSize: iconBoxSize,
                      labelWidth: labelWidth,
                      isDragging: isDragging,
                      canRemove: items.length > 1,
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

  /// 「＋ 追加」セル（KP-032）。寸法はカテゴリーのセルと揃える
  Widget _buildAddCell({
    required double iconBoxSize,
    required double labelWidth,
  }) {
    return Semantics(
      button: true,
      label: '記録画面に追加',
      child: AppInkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _openAddList,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: iconBoxSize,
              height: iconBoxSize,
              child: Icon(
                AppIcons.add,
                size: 25,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: labelWidth,
              child: Text(
                '追加',
                style: context.registerStyles.categoryLabel.copyWith(
                  color: context.colors.primary,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// カテゴリーアイテム（アイコン＋ラベル＋右上の「−」）を構築
  Widget _buildCategoryItem({
    required ReorderingCategoryItem item,
    required double iconBoxSize,
    required double labelWidth,
    required bool isDragging,
    required bool canRemove,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
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
                style: context.registerStyles.categoryLabel,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        // 記録画面から外す（表示中が1件のときは非活性。KP-032）
        Positioned(
          top: -6,
          right: 0,
          child: _RemoveBadge(onTap: canRemove ? () => _remove(item.id) : null),
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
}

/// セル右上の「−」（記録画面から外す。KP-032）
///
/// カテゴリー設定の行頭の削除（`CategoryDeleteRowButton`）と同じ絵柄・色で、
/// セルの角に収まる小ささにしたもの。[onTap] が null のときは非活性。
class _RemoveBadge extends StatelessWidget {
  const _RemoveBadge({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(
        AppIcons.deleteRow,
        size: 18,
        color: onTap == null
            ? context.colors.textTertiary
            : context.colors.danger,
      ),
    );
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '記録画面から外す',
      child: onTap == null
          ? icon
          : AppInkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: onTap,
              child: icon,
            ),
    );
  }
}
