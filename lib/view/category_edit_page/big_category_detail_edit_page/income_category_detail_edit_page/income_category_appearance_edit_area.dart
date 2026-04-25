import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/icon_select_dialog.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_color_controller/income_big_category_color_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_icon_controller/income_big_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_name_controller/income_big_category_name_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_big_category_appearance_edited/is_income_big_category_appearance_edited.dart';

class IncomeCategoryAppearanceEditArea extends ConsumerStatefulWidget {
  const IncomeCategoryAppearanceEditArea({
    required this.bigId,
    super.key,
  });

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
            .initState(MyColors().getColorFromHex(initialItem.colorCode));
        ref
            .read(incomeBigCategoryIconControllerNotifierProvider.notifier)
            .initState(initialItem.iconPath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconPath =
        ref.watch(incomeBigCategoryIconControllerNotifierProvider);
    final color = ref.watch(incomeBigCategoryColorControllerNotifierProvider);

    return Column(
      children: [
        // 大カテゴリーの設定ボックス
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: MyColors.quarternarySystemfill,
              borderRadius: BorderRadius.circular(18),
            ),
            height: 135,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // アイコン部分
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const IconSelectDialog(
                          categoryType: CategoryType.income,
                        );
                      },
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
                          colorFilter:
                              ColorFilter.mode(color, BlendMode.srcIn),
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
                    controller:
                        ref.watch(incomeBigCategoryNameControllerProvider),
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
                      fillColor: MyColors.secondarySystemfill,
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
                              decoration: const BoxDecoration(
                                color: MyColors.systemfill,
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
                              icon: const Icon(
                                Icons.clear,
                                size: 14,
                                color: MyColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MyColors.jet.withOpacity(0.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MyColors.jet.withOpacity(0.0),
                        ),
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
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ColorSelectDialog(
                  categoryType: CategoryType.income,
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: MyColors.quarternarySystemfill,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8),
                    child: Container(
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
                  Text('カテゴリーカラー',
                      style: AppTextStyles.listTileSecondaryTitle),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
