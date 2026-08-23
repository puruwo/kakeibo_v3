import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
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

/// 支出カテゴリーを大→小の2段で選ばせるシート（仕様 §6.8）
///
/// 最初に大カテゴリー一覧を出し、タップで同じシート内を小カテゴリー一覧に切り替える。
class ExpenseCategorySelectSheet extends ConsumerStatefulWidget {
  const ExpenseCategorySelectSheet({
    super.key,
    required this.selectedSmallCategoryId,
  });

  /// 現在選択中の小カテゴリーID
  final int selectedSmallCategoryId;

  @override
  ConsumerState<ExpenseCategorySelectSheet> createState() =>
      _ExpenseCategorySelectSheetState();
}

class _ExpenseCategorySelectSheetState
    extends ConsumerState<ExpenseCategorySelectSheet> {
  /// 表示中の大カテゴリーのキー（null＝大カテゴリー一覧を表示中）
  int? _openedBigCategoryKey;

  @override
  Widget build(BuildContext context) {
    final isSmallList = _openedBigCategoryKey != null;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: const GlassAppBarBackground(),
          title: Text('カテゴリーを選ぶ', style: AppTextStyles.pageHeaderText),
          leading: IconButton(
            // 小カテゴリー一覧では大カテゴリー一覧へ戻る導線にする
            onPressed: () {
              if (isSmallList) {
                setState(() => _openedBigCategoryKey = null);
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(
              isSmallList
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.close_rounded,
              color: context.colors.text,
            ),
          ),
        ),
        body: ref.watch(allCategoriesProvider).when(
              data: (categories) {
                final groups = _groupByBigCategory(categories);
                final opened = groups
                    .where((group) => group.key == _openedBigCategoryKey)
                    .toList();

                // 表示中の大カテゴリーが無い場合は大カテゴリー一覧を出す
                if (opened.isEmpty) {
                  return _buildBigCategoryList(context, groups);
                }
                return _buildSmallCategoryList(context, opened.first);
              },
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
                    (category) => category.id == widget.selectedSmallCategoryId,
                  )
                      ? '選択中'
                      : null,
                  onTap: () => setState(
                    () => _openedBigCategoryKey = group.key,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// 2段目: 小カテゴリー一覧（色丸＋名称）。上部にどの大カテゴリーかを出す
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
                  value: category.id == widget.selectedSmallCategoryId
                      ? '選択中'
                      : null,
                  onTap: () => Navigator.of(context).pop(category),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// 小カテゴリー一覧の上部に置く大カテゴリーの見出し（タップで1段目へ戻る）
  Widget _buildBigCategoryHeader(
    BuildContext context,
    _BigCategoryGroup group,
  ) {
    return AppInkWell(
      borderRadius: appInsetGroupRadius,
      onTap: () => setState(() => _openedBigCategoryKey = null),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: context.colors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            ExpenseCategoryIcon(
              resourcePath: group.resourcePath,
              colorCode: group.colorCode,
            ),
            const SizedBox(width: 10),
            Text(group.name, style: AppTextStyles.insetGroupLabel),
          ],
        ),
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
