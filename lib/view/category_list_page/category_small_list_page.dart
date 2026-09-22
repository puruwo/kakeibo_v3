import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_selection_provider.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/category_list_page/category_big_list_page.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/category_list_tile.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';

/// 全カテゴリーの一覧・画面2（小カテゴリー一覧。KP-032）
///
/// 大カテゴリー1つの小カテゴリーを、大のアイコン・色を継承した行で並べる。
/// タップした小カテゴリーを結果（[ICategoryEntity]）として返して閉じる。
///
/// - [CategoryListMode.select]: 選択中の行に右端のチェックと淡い地
/// - [CategoryListMode.add]: 記録画面に表示中の行は薄く「表示中」でタップ不可
class CategorySmallListPage extends ConsumerWidget {
  const CategorySmallListPage({
    super.key,
    required this.transactionMode,
    required this.mode,
    required this.bigCategoryId,
    required this.bigCategoryName,
    this.selectedCategoryId,
    this.displayedIds = const {},
  });

  final TransactionMode transactionMode;
  final CategoryListMode mode;
  final int bigCategoryId;
  final String bigCategoryName;
  final int? selectedCategoryId;
  final Set<int> displayedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.surfaceElevated,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        title: Text(bigCategoryName, style: context.textStyles.pageHeaderText),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(AppIcons.back, color: context.colors.text),
        ),
      ),
      body: Column(
        children: [
          CategoryListLegend(
            leading: '項目',
            trailing: mode == CategoryListMode.add ? '表示' : '選択',
          ),
          Expanded(
            child: ref
                .watch(categoriesByModeProvider(transactionMode))
                .when(
                  data: (all) {
                    final smalls =
                        all
                            .where((c) => c.bigCategoryKey == bigCategoryId)
                            .toList()
                          ..sort(
                            (a, b) => a.displaydOrderInBig.compareTo(
                              b.displaydOrderInBig,
                            ),
                          );
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: smalls.length,
                      itemBuilder: (context, index) =>
                          _buildRow(context, smalls[index]),
                    );
                  },
                  error: (_, _) => const AppErrorState(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, ICategoryEntity category) {
    final isSelected =
        mode == CategoryListMode.select && category.id == selectedCategoryId;
    final isDisplayed =
        mode == CategoryListMode.add && displayedIds.contains(category.id);

    Widget? trailing;
    if (isSelected) {
      trailing = Icon(AppIcons.done, size: 18, color: context.colors.primary);
    } else if (isDisplayed) {
      trailing = Text(
        '表示中',
        style: context.textStyles.listTileSecondaryTitle.copyWith(
          color: context.colors.textTertiary,
        ),
      );
    }

    return CategoryListTile(
      resourcePath: category.resourcePath,
      colorCode: category.colorCode,
      title: category.categoryName,
      titleFlexible: true,
      trailing: trailing,
      selected: isSelected,
      enabled: !isDisplayed,
      onTap: () => Navigator.of(context).pop(category),
    );
  }
}
