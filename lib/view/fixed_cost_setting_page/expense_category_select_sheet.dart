import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
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

/// 支出カテゴリーを大カテゴリーごとにグループ化して選ばせるシート
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
              data: (categories) => _buildList(context, categories),
              error: (error, stackTrace) => const AppErrorState(),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<ExpenseCategoryEntity> categories,
  ) {
    // 大カテゴリーごとにまとめる（並びは取得順＝表示順のまま）
    final grouped = <String, List<ExpenseCategoryEntity>>{};
    for (final category in categories) {
      grouped.putIfAbsent(category.bigCategoryName, () => []).add(category);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: grouped.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppInsetGroup(
                header: entry.key,
                children: entry.value
                    .map(
                      (category) => AppInsetRow.navigation(
                        icon: Icons.circle,
                        iconColor: ColorCode.toColor(category.colorCode),
                        label: category.categoryName,
                        value: category.id == selectedSmallCategoryId
                            ? '選択中'
                            : null,
                        onTap: () => Navigator.of(context).pop(category),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// カテゴリーアイコン（SVG）を色付きで表示する
///
/// 固定費の設定画面のカテゴリー行で使う。
class ExpenseCategoryIcon extends StatelessWidget {
  const ExpenseCategoryIcon({
    super.key,
    required this.resourcePath,
    required this.colorCode,
    this.size = kAppInsetRowIconSize,
  });

  final String resourcePath;
  final String colorCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (resourcePath.isEmpty) {
      return SizedBox(width: size, height: size);
    }
    return SvgPicture.asset(
      resourcePath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        ColorCode.toColor(colorCode),
        BlendMode.srcIn,
      ),
    );
  }
}
