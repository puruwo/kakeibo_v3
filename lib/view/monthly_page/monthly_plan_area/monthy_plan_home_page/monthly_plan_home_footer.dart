import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/budget/budget_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/big_category_setting_page.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view/register_page/income_tab/register_income_page.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_budget_provider.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/is_price_edited/is_price_edited.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/price_controller/price_controller.dart';
import 'package:kakeibo/view_model/state/monthly_plan_page/footer_state_controller/footer_state_controller.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class MonthlyPlanHomeFooter extends ConsumerWidget with PresentationMixin {
  const MonthlyPlanHomeFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(footerStateControllerNotifierProvider)) {
      case TabState.budgetNormal:
        return _budgetNormalButtons(context, ref);
      case TabState.budgetEdditing:
        return _budgetEdditingButton(context, ref);
      case TabState.income:
        return _incomeButton(context, ref);
      default:
        return const SizedBox.shrink(); // 他のタブでは何も表示しない
    }
  }

  // Tab=予算 の状態で予算編集じゃないときのボタン
  Widget _budgetNormalButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheetFunc(context, const BigCategorySettingPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.buttonSecondary,
            ),
            child: Text(
              'カテゴリー編集・追加',
              style: MyFonts.secondaryButtonText,
            ),
          ),
        ),

        const SizedBox(width: 8.0), // ボタン間のスペース

        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ref
                  .read(footerStateControllerNotifierProvider.notifier)
                  .updateState(TabState.budgetEdditing);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.buttonPrimary,
            ),
            child: Text(
              '予算を編集する',
              style: MyFonts.mainButtonText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _budgetEdditingButton(BuildContext context, WidgetRef ref) {
    // expenseEntityを扱うusecase
    final budgetUsecase = ref.read(budgetUsecaseProvider);

    // 編集前のbudgetListを取得する
    return ref.watch(resolvedBudgetEditValueProvider).when(
      data: (budgetEditList) {
        return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.buttonPrimary,
            ),
            child: Text(
              '編集を完了',
              style: MyFonts.mainButtonText,
            ),
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
        
                  // 呼び出し元画面でスナックバーを表示
                  SuccessSnackBar.show(
                    ScaffoldMessenger.of(context),
                    message: '登録が完了しました',
                  );
        
                  // フッターの状態を非編集状態に戻す
                  ref
                      .read(footerStateControllerNotifierProvider.notifier)
                      .updateState(TabState.budgetNormal);
        
                  ref.invalidate(isPriceEditedNotifierProvider);
                },
              );
            });
      },
      error: (error, stackTrace) {
        return Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.buttonPrimary,
            ),
            onPressed: null,
            child: Text(
              '編集を完了',
              style: MyFonts.mainButtonText,
            ), // エラー時はボタンを無効化
          ),
        );
      },
      loading: () {
        return Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.buttonPrimary,
            ),
            onPressed: null,
            child: Text(
              '編集を完了',
              style: MyFonts.mainButtonText,
            ), // エラー時はボタンを無効化
          ),
        );
      },
    );
  }

  Widget _incomeButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            //sccafoldの上に出すか
            useRootNavigator: true,
            isScrollControlled: true,
            useSafeArea: true,
            constraints: const BoxConstraints(
              maxWidth: 2000,
            ),
            context: context,
            // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
            builder: (context) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData.dark(),
                themeMode: ThemeMode.dark,
                darkTheme: ThemeData.dark(),
                home: MediaQuery.withClampedTextScaling(
                  child: const RegisterIncomePage(
                    isTabVisible: true, // タブを非表示にする
                  ),
                ),
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonPrimary,
        ),
        child: Text(
          '新しい収入を追加',
          style: MyFonts.mainButtonText,
        ),
      ),
    );
  }
}
