import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/icon_select_dialog.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/util/common_widget/checkable_popup_menu_item.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_account_type_controller/income_big_category_account_type_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_color_controller/income_big_category_color_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_icon_controller/income_big_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_name_controller/income_big_category_name_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_big_category_appearance_edited/is_income_big_category_appearance_edited.dart';

/// 収入カテゴリーの外観編集エリア（案件 UIデザイン改修 §2）
///
/// 支出側（CategoryAppearanceEditArea）と同じ「外観」インセットグループに、
/// 収入のみの「会計種別」行（生活収支／特別枠。ADR-025）を加えた構成。
class IncomeCategoryAppearanceEditArea extends ConsumerStatefulWidget {
  const IncomeCategoryAppearanceEditArea({required this.bigId, super.key});

  final int bigId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomeCategoryAppearanceEditAreaState();
}

class _IncomeCategoryAppearanceEditAreaState
    extends ConsumerState<IncomeCategoryAppearanceEditArea> {
  @override
  void initState() {
    super.initState();

    // 編集モード時のみ初期値をセット
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.bigId == -1) {
        return;
      }

      Future(() async {
        final initialItem = await ref.watch(
          anIncomeBigCategoryProvider(widget.bigId).future,
        );

        ref.read(incomeBigCategoryNameControllerProvider).text =
            initialItem.name;
        ref
            .read(incomeBigCategoryColorControllerNotifierProvider.notifier)
            .initState(ColorCode.toColor(initialItem.colorCode));
        ref
            .read(incomeBigCategoryIconControllerNotifierProvider.notifier)
            .initState(initialItem.iconPath);
        ref
            .read(
              incomeBigCategoryAccountTypeControllerNotifierProvider.notifier,
            )
            .initState(initialItem.accountType);
      });
    });
  }

  /// 既定カテゴリー（月次収入・ボーナス）は会計種別を変更不可にする
  ///
  /// 既定2カテゴリーの種別を入れ替えると既存の全集計スコープが入れ替わるため、
  /// 削除禁止と同じ基準でロックする（ADR-025）
  bool get _isAccountTypeLocked =>
      IncomeBigCategoryConstants.isDefaultCategory(widget.bigId);

  @override
  Widget build(BuildContext context) {
    final iconPath = ref.watch(incomeBigCategoryIconControllerNotifierProvider);
    final color = ref.watch(incomeBigCategoryColorControllerNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppInsetGroup(
        header: '外観',
        note: _isAccountTypeLocked
            ? '既定カテゴリー（月次収入・ボーナス）の会計種別は変更できません。'
            : null,
        children: [
          // 名称（先頭・インライン編集）
          // 文字数制限・autofocus・クリアボタンの扱いは支出側と同じ（§2）
          AppInsetRow.textField(
            icon: Icons.drive_file_rename_outline_rounded,
            label: '名称',
            controller: ref.watch(incomeBigCategoryNameControllerProvider),
            hintText: 'カテゴリー名を入力',
            onChanged: (_) {
              ref
                  .read(
                    isIncomeBigCategoryAppearanceEditedNotifierProvider
                        .notifier,
                  )
                  .updateState(true);
            },
          ),

          // アイコン
          AppInsetRow.navigation(
            icon: Icons.grid_view_rounded,
            label: 'アイコン',
            valueWidget: SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              semanticsLabel: 'categoryIcon',
              width: 20,
              height: 20,
            ),
            onTap: () {
              showIconSelectSheet(context, categoryType: CategoryType.income);
            },
          ),

          // カテゴリーカラー
          AppInsetRow.navigation(
            icon: Icons.palette_outlined,
            label: 'カテゴリーカラー',
            valueWidget: Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () async {
              await showColorSelectSheet(
                context,
                categoryType: CategoryType.income,
              );
            },
          ),

          // 会計種別（生活収支 / 特別枠。ADR-025）
          _buildAccountTypeRow(context),
        ],
      ),
    );
  }

  // 会計種別の行を構築する
  // 既定カテゴリー（月次収入・ボーナス）は表示のみで変更不可
  Widget _buildAccountTypeRow(BuildContext context) {
    final accountType = ref.watch(
      incomeBigCategoryAccountTypeControllerNotifierProvider,
    );

    final rowContent = _buildAccountTypeRowContent(
      context,
      accountType: accountType,
      locked: _isAccountTypeLocked,
    );

    if (_isAccountTypeLocked) {
      return rowContent;
    }

    return AppPopupMenu<int>(
      onSelected: (selected) {
        ref
            .read(
              incomeBigCategoryAccountTypeControllerNotifierProvider.notifier,
            )
            .updateState(selected);
      },
      itemBuilder: (context) => [
        buildCheckableMenuItem(
          value: AccountTypeConstants.living,
          label: AccountTypeConstants.livingLabel,
          isSelected: accountType == AccountTypeConstants.living,
          selectedColor: context.colors.primary,
        ),
        buildCheckableMenuItem(
          value: AccountTypeConstants.special,
          label: AccountTypeConstants.specialLabel,
          isSelected: accountType == AccountTypeConstants.special,
          selectedColor: context.colors.primary,
        ),
      ],
      child: rowContent,
    );
  }

  /// 会計種別行の見た目（ロック時は薄い値+鍵、非ロック時は値+下向き矢印）
  Widget _buildAccountTypeRowContent(
    BuildContext context, {
    required int accountType,
    required bool locked,
  }) {
    final valueStyle = locked
        ? AppTextStyles.insetGroupValue
            .copyWith(color: context.colors.textSecondary)
        : AppTextStyles.insetGroupValue;

    return AppInsetRow.display(
      icon: Icons.sell_outlined,
      label: '会計種別',
      valueWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AccountTypeConstants.label(accountType), style: valueStyle),
          const SizedBox(width: 4),
          Icon(
            locked
                ? Icons.lock_outline_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: locked ? 16 : 18,
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
