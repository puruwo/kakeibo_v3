import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';
import 'package:kakeibo/view_model/state/register_page/original_expense_entity/original_expense_entity.dart';
import 'package:kakeibo/view_model/state/register_page/select_category_controller/select_category_controller.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class SubmitExpenseButton extends ConsumerWidget with PresentationMixin {
  const SubmitExpenseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // expenseEntityを扱うusecase
    final expenseUsecase = ref.read(expenseUsecaseProvider);

    // originalExpenseEntityを取得
    final original = ref.watch(originalExpenseEntityNotifierProvider);

    // 新規か編集か
    final screenMode = ref.watch(registerScreenModeNotifierProvider);

    return IconButton(
        icon: const Icon(
          //完了チェックマーク
          Icons.done_rounded,
          color: MyColors.white,
        ),
        onPressed: () async {
          execute(
            context,
            action: () async {
              // 入力金額を取得する
              // 正規表現による空文字の置き換えで、文字列から数字以外の文字を削除
              final enteredPriceText = ref
                  .read(enteredPriceControllerProvider)
                  .text
                  .replaceAll(RegExp(r'\D'), '');

              final enteredPrice = int.tryParse(enteredPriceText) ?? 0;

              // 入力されたメモを取得する
              final enteredMemo = ref.read(enteredMemoControllerProvider).text;

              // 入力された日付を取得する
              final inputDate = ref.read(inputDateControllerNotifierProvider);

              // 選択されたカテゴリーを取得する
              final selectedCategory =
                  ref.read(selectCategoryControllerNotifierProvider);

              final entity = ExpenseEntity(
                  id: original.id,
                  date: DateFormat('yyyyMMdd').format(inputDate),
                  price: enteredPrice,
                  paymentCategoryId: selectedCategory.id,
                  memo: enteredMemo);

              switch (screenMode) {
                case RegisterScreenMode.add:
                  await expenseUsecase.add(expenseEntity: entity);
                  break;
                case RegisterScreenMode.edit:
                  await expenseUsecase.edit(
                      originalEntity: original, editEntity: entity);
                  break;
              }
            },

            // actionを実行しエラーがレスポンスされなかった場合の成功時の処理
            succesAction: () async {
              // DBの更新を通知
              ref.read(updateDBCountNotifierProvider.notifier).incrementState();

              // 画面を閉じる
              Navigator.of(context, rootNavigator: true).pop();

              // 呼び出し元画面のcontextを取得
              final rootContext =
                  Navigator.of(context, rootNavigator: true).context;
              // 呼び出し元画面でスナックバーを表示
              SuccessSnackBar.show(
                ScaffoldMessenger.of(rootContext),
                message: '登録が完了しました',
              );
            },
          );
        });
  }
}
