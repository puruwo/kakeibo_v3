import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/category_list_page/category_small_list_page.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/category_list_tile.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';

/// 全カテゴリーの一覧の用途（KP-032）
enum CategoryListMode {
  /// 記録モーダルの「すべて」から開き、記録するカテゴリーを選ぶ
  select,

  /// 記録画面のカテゴリー（並び替え画面）から開き、グリッドに加えるカテゴリーを選ぶ
  add,
}

/// 全カテゴリーの一覧・画面1（大カテゴリー一覧。KP-032）
///
/// カテゴリー設定の一覧と同じ行で、記録のモード（支出／収入）の大カテゴリーを並べる。
/// 行をタップすると [CategorySmallListPage] へ進み、そこで選んだ小カテゴリーを
/// 結果（[ICategoryEntity]）として返して閉じる。
class CategoryBigListPage extends ConsumerWidget {
  const CategoryBigListPage({
    super.key,
    required this.transactionMode,
    required this.mode,
    this.selectedCategoryId,
    this.displayedIds = const {},
  });

  final TransactionMode transactionMode;
  final CategoryListMode mode;

  /// 記録モーダルで選択中の小カテゴリーID（[CategoryListMode.select] でチェックを付ける）
  final int? selectedCategoryId;

  /// 記録画面に表示中の小カテゴリーID（[CategoryListMode.add] で「表示中」にする）
  final Set<int> displayedIds;

  String get _title => mode == CategoryListMode.add ? '記録画面に追加' : 'すべてのカテゴリー';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: const GlassAppBarBackground(),
          title: Text(_title, style: context.textStyles.pageHeaderText),
          leading: IconButton(
            // モーダルは root の Navigator に積まれている
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: Icon(AppIcons.close, color: context.colors.text),
          ),
        ),
        body: Column(
          children: [
            const CategoryListLegend(
              leading: 'カテゴリー',
              middle: '項目',
              trailing: '詳細',
            ),
            Expanded(child: _buildList(context, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref) {
    return switch (transactionMode) {
      TransactionMode.expense =>
        ref
            .watch(allBigCategoriesWithSmallListProvider)
            .when(
              data: (items) => _list(
                context,
                items
                    .map(
                      (e) => _BigRow(
                        id: e.id,
                        name: e.bigCategoryName,
                        colorCode: e.colorCode,
                        resourcePath: e.resourcePath,
                        smallNames: e.expenseSmallCategoryNameText,
                      ),
                    )
                    .toList(),
              ),
              error: (_, _) => const AppErrorState(),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
      TransactionMode.income =>
        ref
            .watch(allIncomeBigCategoriesWithSmallListProvider)
            .when(
              data: (items) => _list(
                context,
                items
                    .map(
                      (e) => _BigRow(
                        id: e.id,
                        name: e.bigCategoryName,
                        colorCode: e.colorCode,
                        resourcePath: e.resourcePath,
                        smallNames: e.incomeSmallCategoryNameText,
                      ),
                    )
                    .toList(),
              ),
              error: (_, _) => const AppErrorState(),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
    };
  }

  Widget _list(BuildContext context, List<_BigRow> rows) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return CategoryListTile(
          resourcePath: row.resourcePath,
          colorCode: row.colorCode,
          title: row.name,
          subtitle: row.smallNames,
          trailing: Icon(AppIcons.next, size: 18, color: context.colors.text),
          onTap: () => _openSmallList(context, row),
        );
      },
    );
  }

  /// 画面2（小カテゴリー一覧）へ進み、選ばれた小カテゴリーをこの画面の結果として返す
  Future<void> _openSmallList(BuildContext context, _BigRow row) async {
    final result = await Navigator.of(context).push<ICategoryEntity>(
      MaterialPageRoute(
        builder: (_) => CategorySmallListPage(
          transactionMode: transactionMode,
          mode: mode,
          bigCategoryId: row.id,
          bigCategoryName: row.name,
          selectedCategoryId: selectedCategoryId,
          displayedIds: displayedIds,
        ),
      ),
    );
    if (result == null || !context.mounted) return;
    Navigator.of(context).pop(result);
  }
}

/// 大カテゴリー行の表示に必要な値（支出・収入の値クラスを揃える）
class _BigRow {
  const _BigRow({
    required this.id,
    required this.name,
    required this.colorCode,
    required this.resourcePath,
    required this.smallNames,
  });

  final int id;
  final String name;
  final String colorCode;
  final String resourcePath;
  final String smallNames;
}
