// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';

// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';

class IncomeSourcePicker extends ConsumerStatefulWidget {
  const IncomeSourcePicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomeSourcePickerState();
}

class _IncomeSourcePickerState extends ConsumerState<IncomeSourcePicker> {
  @override
  Widget build(BuildContext context) {
    final incomeSourceBigCategory =
        ref.watch(enteredIncomeSourceControllerNotifierProvider);

    return ref.watch(incomeCategoryProvider).when(
          data: (data) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // タイトル
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      '拠出元を選択',
                      style: MyFonts.dialogTitle,
                      textAlign: TextAlign.center,
                    ),
                ),

                // カテゴリーリスト
                Padding(
                  padding: const EdgeInsets.only(bottom:16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(data.length, (i) {
                      // 選択されたカテゴリーNoと一致したら選択状態のフラグを立てる
                      bool isSelected = false;
                      if (incomeSourceBigCategory == data[i].id)isSelected = true;
                              
                      return GestureDetector(
                        onTap: () {
                          // タップしたカテゴリーを選択状態にする
                          ref.read(enteredIncomeSourceControllerNotifierProvider.notifier).setData(data[i].id);
                          // ダイアログを閉じる
                          Navigator.of(context).pop();
                        },
                        // 選択状態に応じてウィジェットを変更
                        child: isSelected
                            ? selectedListTile(data[i])
                            : normalListTile(data[i]),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          error: (e, _) {
            return const Text('エラーが発生しました');
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}

Widget selectedListTile(
  IncomeBigCategoryEntity entity,
) {
  return Container(
    height: 35,
    width: 100,
    decoration: BoxDecoration(
      color: MyColors.systemGray3,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          entity.name,
          textAlign: TextAlign.center,
          style: MyFonts.dialogList)],
    ),
  );
}

Widget normalListTile(IncomeBigCategoryEntity entity) {
  return Container(
    height: 35,
    width: 100,
    decoration: BoxDecoration(
      color: MyColors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          entity.name,
          textAlign: TextAlign.center,
          style: MyFonts.dialogList,)],
    ),
  );
}
