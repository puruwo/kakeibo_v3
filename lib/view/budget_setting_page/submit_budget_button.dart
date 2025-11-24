import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/budget/budget_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_budget_provider.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/is_price_edited/is_price_edited.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/price_controller/price_controller.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class SubmitBudgetButton extends ConsumerWidget with PresentationMixin {
  const SubmitBudgetButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // expenseEntityを扱うusecase
    final budgetUsecase = ref.read(budgetUsecaseProvider);

    // 編集前のbudgetListを取得する
    return ref.watch(resolvedBudgetEditValueProvider).when(
      data: (budgetEditList) {
        return Expanded(
          child: MainButton(
              buttonType: ButtonType.main,
              buttonText: '編集を完了',
              onPressed: () async {
                // 実行
                execute(
                  context,
                  action: () async {
                    // 予算が編集されているか確認する
                    final isChanged = ref.watch(isPriceEditedNotifierProvider);
                    if (!isChanged) throw const AppException('予算が編集されていません');

                    // 各カテゴリーのControllerに格納された値を代入するList
                    final editPriceLists = <int>[];

                    // 取得したbudgetListの分だけ繰り返しして、実行する
                    for (BudgetEditValue budgetEditValue in budgetEditList) {
                      // 入力金額を取得する
                      // 正規表現による空文字の置き換えで、文字列から数字以外の文字を削除
                      final enteredPriceText = ref
                          .read(enteredBudgetPriceControllerProvider(
                              budgetEditValue))
                          .text
                          .replaceAll(RegExp(r'\D'), '');

                      final enteredPrice = int.tryParse(enteredPriceText) ?? 0;

                      editPriceLists.add(enteredPrice);
                    }

                    await budgetUsecase.edit(
                        originalValues: budgetEditList,
                        editPrice: editPriceLists);
                  },

                  // actionを実行しエラーがレスポンスされなかった場合の成功時の処理
                  succesAction: () async {
                    // DBの更新を通知
                    ref
                        .read(updateDBCountNotifierProvider.notifier)
                        .incrementState();

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

                    ref.invalidate(isPriceEditedNotifierProvider);
                  },
                );
              }),
        );
      },
      error: (error, stackTrace) {
        return const Icon(
          //完了チェックマーク
          Icons.done_rounded,
          color: MyColors.white,
        );
      },
      loading: () {
        return const Icon(
          //完了チェックマーク
          Icons.done_rounded,
          color: MyColors.white,
        );
      },
    );
  }
}
