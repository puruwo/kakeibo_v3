// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/component/app_selection_sheet.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_icon_contoroller/big_category_icon_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_icon_controller/income_big_category_icon_controller.dart';

/// アイコンの分類セクション（案件 UIデザイン改修 §8）
class _IconSection {
  const _IconSection(this.title, this.assetNames);

  final String title;
  final List<String> assetNames;
}

/// カテゴリー用アセット27種（icon_*.svg。UI用のui_icon_editは除く）を
/// 意味で分類して全提示する（旧実装は10種のみだった）
const List<_IconSection> _iconSections = [
  _IconSection('食事・生活', [
    'icon_meal',
    'icon_commodity',
    'icon_clothes',
    'icon_favo',
    'icon_medical',
    'icon_pets',
    'icon_school',
    'icon_travel',
    'icon_transportation',
    'icon_star',
    'icon_others',
  ]),
  _IconSection('住まい・固定費', [
    'icon_home',
    'icon_apartment',
    'icon_domain',
    'icon_bolt',
    'icon_water_drop',
    'icon_energy_savings_leaf',
    'icon_router',
    'icon_cell_tower',
    'icon_smartphone',
    'icon_subscription',
    'icon_autorenew',
    'icon_credit_card',
  ]),
  _IconSection('収入・その他', [
    'icon_regular_income',
    'icon_extra_income',
    'icon_account_balance',
    'icon_workspace_premium',
  ]),
];

/// カテゴリーアイコン選択シートを表示する（選択即決定）
Future<void> showIconSelectSheet(
  BuildContext context, {
  CategoryType categoryType = CategoryType.expense,
}) {
  return AppSelectionSheet.show(
    context,
    title: 'カテゴリーアイコンを選択',
    child: IconSelectDialog(categoryType: categoryType),
  );
}

/// アイコン選択シートの中身（分類セクション＋5列グリッド）
class IconSelectDialog extends ConsumerWidget {
  const IconSelectDialog({
    super.key,
    this.categoryType = CategoryType.expense,
  });

  final CategoryType categoryType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 選択中アイコンのパスを取得
    final iconPath = categoryType == CategoryType.income
        ? ref.watch(incomeBigCategoryIconControllerNotifierProvider)
        : ref.watch(bigCategroyIconControllerNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final section in _iconSections) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
            child: Text(section.title, style: AppTextStyles.insetGroupHeader),
          ),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            // 正方形セルだと縦に間延びするため、セル高を約55ptに詰める
            childAspectRatio: 1.3,
            children: [
              for (final url in section.assetNames.map(_assetUrl))
                _IconCell(
                  url: url,
                  isSelected: url == iconPath,
                  onTap: () => _select(context, ref, url),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// アセット名→パスの組み立て（選択判定・タップ結果のずれ防止のため1箇所に集約）
  static String _assetUrl(String name) => 'assets/images/$name.svg';

  void _select(BuildContext context, WidgetRef ref, String url) {
    Navigator.of(context).pop();
    if (categoryType == CategoryType.income) {
      ref
          .read(incomeBigCategoryIconControllerNotifierProvider.notifier)
          .updateState(url);
    } else {
      ref
          .read(bigCategroyIconControllerNotifierProvider.notifier)
          .updateState(url);
    }
  }
}

/// グリッドの1セル。円44px・アイコン20px。
/// 選択中は primaryTint地 + 1.5px primary枠 + primaryアイコン。
class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.url,
    required this.isSelected,
    required this.onTap,
  });

  final String url;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isSelected ? context.colors.primary : context.colors.textSecondary;

    return Center(
      child: AppInkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? context.colors.primaryTint : null,
            border: isSelected
                ? Border.all(color: context.colors.primary, width: 1.5)
                : null,
          ),
          child: Center(
            child:
                CategoryHandler().iconWidget(url, iconColor, width: 20, height: 20),
          ),
        ),
      ),
    );
  }
}
