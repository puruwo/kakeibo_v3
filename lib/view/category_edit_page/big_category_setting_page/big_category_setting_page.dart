/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/big_category_edit_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/big_category_list_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/submit_big_category_button.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/editting_big_category_list/editting_big_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/is_big_category_list_edited/is_big_category_list_edited.dart';
import 'package:kakeibo/view_model/state/category_edit_page/edit_mode.dart';

class BigCategorySettingPage extends ConsumerStatefulWidget {
  const BigCategorySettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategorySettingPageState();
}

class _BigCategorySettingPageState
    extends ConsumerState<BigCategorySettingPage> {
  @override
  Widget build(BuildContext context) {
    final editmodeProvider = ref.watch(editModeNotifierProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
          backgroundColor: MyColors.secondarySystemBackground,
          // ヘッダー
          appBar: AppBar(
            backgroundColor: MyColors.secondarySystemBackground,
            title: Text(
              'カテゴリーの設定',
              style: MyFonts.pageHeaderText,
            ),

            //ヘッダー左のアイコンボタン
            leading: IconButton(
                // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
                onPressed: () {
                  final isEditMode = ref.read(editModeNotifierProvider);
                  if (isEditMode) {
                    // 編集モードなら、providerを破棄して状態を非編集モードに変更
                    ref.invalidate(isBigCategoryListEditedNotifierProvider);
                    ref.invalidate(edittingBigCategoryListNotifierProvider);
                    ref.read(editModeNotifierProvider.notifier).updateState();
                  } else {
                    // 編集モードに変更
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                },
                icon: const Icon(Icons.close, color: MyColors.white)),

            //ヘッダー右のアイコンボタン
            actions: [
              editmodeProvider
                  ? const SubmitBigCategoryButton()
                  : IconButton(
                      icon: const Text(
                        '編集',
                        style: TextStyle(color: MyColors.white),
                      ),
                      onPressed: () {
                        // 編集モードの状態を更新
                        final notifier =
                            ref.read(editModeNotifierProvider.notifier);
                        notifier.updateState();
                      },
                    )
            ],
          ),

          // 本体
          body: editmodeProvider == false

              // 非編集時
              ? const BigCategoryListArea()

              // 編集時
              : const BigCategoryEditArea()),
    );
  }
}
