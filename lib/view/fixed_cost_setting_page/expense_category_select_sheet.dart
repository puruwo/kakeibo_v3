import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/modal.dart';

/// 支出カテゴリー（大→小）を選ぶシートを開く
///
/// 固定費の設定画面のカテゴリー行から呼ぶ（仕様 §6.7）。
/// 選択された小カテゴリーを返す。閉じた場合は null。
Future<ExpenseCategoryEntity?> showExpenseCategorySelectSheet(
  BuildContext context, {
  required int selectedSmallCategoryId,
}) {
  return showAppModalBottomSheet<ExpenseCategoryEntity>(
    context,
    child: ExpenseCategorySelectSheet(
      selectedSmallCategoryId: selectedSmallCategoryId,
    ),
  );
}

/// 支出カテゴリーを大→小の2段で選ばせるシート（仕様 §6.8・§6.9）
///
/// 最初に大カテゴリー一覧を出し、タップで小カテゴリー一覧を push する
/// （他画面と同じ右からのスライド遷移。戻る導線はヘッダーの戻るボタンのみ）。
class ExpenseCategorySelectSheet extends ConsumerWidget {
  const ExpenseCategorySelectSheet({
    super.key,
    required this.selectedSmallCategoryId,
  });

  /// 現在選択中の小カテゴリーID
  final int selectedSmallCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: const GlassAppBarBackground(),
          title: Text('カテゴリーを選ぶ', style: AppTextStyles.pageHeaderText),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: context.colors.text),
          ),
        ),
        body: ref.watch(allCategoriesProvider).when(
              data: (categories) => _buildBigCategoryList(
                context,
                _groupByBigCategory(categories),
              ),
              error: (error, stackTrace) => const AppErrorState(),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
      ),
    );
  }

  /// 小カテゴリーの一覧を大カテゴリーごとにまとめる（並びは取得順＝表示順のまま）
  List<_BigCategoryGroup> _groupByBigCategory(
    List<ExpenseCategoryEntity> categories,
  ) {
    final groups = <int, _BigCategoryGroup>{};
    for (final category in categories) {
      final group = groups.putIfAbsent(
        category.bigCategoryKey,
        () => _BigCategoryGroup(
          key: category.bigCategoryKey,
          name: category.bigCategoryName,
          colorCode: category.colorCode,
          resourcePath: category.resourcePath,
          smallCategories: [],
        ),
      );
      group.smallCategories.add(category);
    }
    return groups.values.toList();
  }

  /// 1段目: 大カテゴリー一覧（アイコン＋名称＋右矢印）
  Widget _buildBigCategoryList(
    BuildContext context,
    List<_BigCategoryGroup> groups,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        AppInsetGroup(
          children: groups
              .map(
                (group) => AppInsetRow.navigation(
                  leading: ExpenseCategoryIcon(
                    resourcePath: group.resourcePath,
                    colorCode: group.colorCode,
                  ),
                  label: group.name,
                  // 選択中の小カテゴリーを含む大カテゴリーが分かるようにする
                  value: group.smallCategories.any(
                    (category) => category.id == selectedSmallCategoryId,
                  )
                      ? '選択中'
                      : null,
                  onTap: () => _openSmallCategoryPage(context, group),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// 小カテゴリー一覧を push で開き、選択されたら大カテゴリー一覧ごと閉じて返す
  Future<void> _openSmallCategoryPage(
    BuildContext context,
    _BigCategoryGroup group,
  ) async {
    final navigator = Navigator.of(context);
    final selected = await navigator.push<ExpenseCategoryEntity>(
      MaterialPageRoute(
        builder: (context) => _SmallCategorySelectPage(
          group: group,
          selectedSmallCategoryId: selectedSmallCategoryId,
        ),
      ),
    );
    if (selected == null) return;

    // 小カテゴリー一覧は選択時に自身をpop済みなので、ここで大カテゴリー一覧を閉じる
    navigator.pop(selected);
  }
}

/// 小カテゴリー選択ページのヘッダーの戻るボタン
///
/// 遷移元の一覧もWidgetツリーに残るため、テストから一意に特定できるようキーを付ける。
const Key kSmallCategoryBackButtonKey = Key('smallCategoryBackButton');

/// 小カテゴリーの選択ページ（[ExpenseCategorySelectSheet] から push する）
///
/// 戻る導線はヘッダーの戻るボタンのみ（仕様 §6.9）。
class _SmallCategorySelectPage extends StatelessWidget {
  const _SmallCategorySelectPage({
    required this.group,
    required this.selectedSmallCategoryId,
  });

  final _BigCategoryGroup group;
  final int selectedSmallCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceElevated,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        title: Text('カテゴリーを選ぶ', style: AppTextStyles.pageHeaderText),
        leading: IconButton(
          key: kSmallCategoryBackButtonKey,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.colors.text,
          ),
        ),
      ),
      body: _buildSmallCategoryList(context, group),
    );
  }

  /// 小カテゴリー一覧（色丸＋名称）。上部にどの大カテゴリーかを出す
  Widget _buildSmallCategoryList(
    BuildContext context,
    _BigCategoryGroup group,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        _buildBigCategoryHeader(context, group),
        const SizedBox(height: AppSpacing.sm),
        AppInsetGroup(
          children: group.smallCategories
              .map(
                (category) => AppInsetRow.navigation(
                  icon: Icons.circle,
                  iconColor: ColorCode.toColor(category.colorCode),
                  label: category.categoryName,
                  value: category.id == selectedSmallCategoryId
                      ? '選択中'
                      : null,
                  // 選択して閉じる行なので右矢印は出さない
                  showChevron: false,
                  onTap: () => Navigator.of(context).pop(category),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// 小カテゴリー一覧の上部に置く大カテゴリーの見出し
  ///
  /// 戻る導線はヘッダーの戻るボタンに一本化したため、見出しは表示のみ（仕様 §6.9）。
  Widget _buildBigCategoryHeader(
    BuildContext context,
    _BigCategoryGroup group,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          ExpenseCategoryIcon(
            resourcePath: group.resourcePath,
            colorCode: group.colorCode,
          ),
          const SizedBox(width: 10),
          Text(group.name, style: AppTextStyles.insetGroupLabel),
        ],
      ),
    );
  }
}

/// 大カテゴリーと、その配下の小カテゴリーの組
class _BigCategoryGroup {
  _BigCategoryGroup({
    required this.key,
    required this.name,
    required this.colorCode,
    required this.resourcePath,
    required this.smallCategories,
  });

  final int key;
  final String name;
  final String colorCode;
  final String resourcePath;
  final List<ExpenseCategoryEntity> smallCategories;
}
