import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/icon_select_dialog.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/util/common_widget/checkable_popup_menu_item.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/category_setting_row.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_account_type_controller/income_big_category_account_type_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_color_controller/income_big_category_color_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_icon_controller/income_big_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_name_controller/income_big_category_name_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_big_category_appearance_edited/is_income_big_category_appearance_edited.dart';

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

    return Column(
      children: [
        // 大カテゴリーの設定ボックス
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: CardContainer(
            alignment: Alignment.topCenter,
            height: 135,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // アイコン部分
                GestureDetector(
                  onTap: () {
                    showIconSelectSheet(
                      context,
                      categoryType: CategoryType.income,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 18),
                        child: SvgPicture.asset(
                          iconPath,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                          semanticsLabel: 'categoryIcon',
                          width: 45,
                          height: 45,
                        ),
                      ),
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: SvgPicture.asset(
                          'assets/images/edit.svg',
                          clipBehavior: Clip.none,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8.0),

                // カテゴリー名入力部分
                SizedBox(
                  width: 313,
                  height: 48,
                  child: TextFormField(
                    controller: ref.watch(
                      incomeBigCategoryNameControllerProvider,
                    ),
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    cursorWidth: 2,
                    style: AppTextStyles.listTilePrimaryTitle,
                    minLines: 1,
                    maxLines: 1,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: context.colors.fillSecondary,
                      hintText: "カテゴリー名を入力",
                      hintStyle: AppTextStyles.listTileTextFieldHint,
                      contentPadding: const EdgeInsets.only(
                        top: 16,
                        bottom: 0,
                        left: 40,
                        right: 16,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: context.colors.fill,
                                shape: BoxShape.circle,
                              ),
                            ),
                            IconButton(
                              onPressed: () => {
                                ref
                                    .read(
                                      incomeBigCategoryNameControllerProvider,
                                    )
                                    .clear(),
                                ref
                                    .read(
                                      isIncomeBigCategoryAppearanceEditedNotifierProvider
                                          .notifier,
                                    )
                                    .updateState(true),
                              },
                              icon: Icon(
                                Icons.clear,
                                size: 14,
                                color: context.colors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    keyboardAppearance: Brightness.dark,
                    onChanged: (event) {
                      ref
                          .read(
                            isIncomeBigCategoryAppearanceEditedNotifierProvider
                                .notifier,
                          )
                          .updateState(true);
                    },
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8.0),

        // カラー選択
        GestureDetector(
          onTap: () async {
            await showColorSelectSheet(
              context,
              categoryType: CategoryType.income,
            );
          },
          child: CategorySettingRow(
            label: 'カテゴリーカラー',
            trailing: Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: ref.watch(
                  incomeBigCategoryColorControllerNotifierProvider,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8.0),

        // 会計種別選択（生活収支 / 特別枠。ADR-025）
        _buildAccountTypeRow(context),
      ],
    );
  }

  // 会計種別の選択行を構築する
  // 既定カテゴリー（月次収入・ボーナス）は表示のみで変更不可
  Widget _buildAccountTypeRow(BuildContext context) {
    final accountType = ref.watch(
      incomeBigCategoryAccountTypeControllerNotifierProvider,
    );

    final rowContent = CategorySettingRow(
      label: '会計種別',
      locked: _isAccountTypeLocked,
      trailing: Text(
        AccountTypeConstants.label(accountType),
        style: AppTextStyles.listTileSecondaryTitle,
      ),
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
}
