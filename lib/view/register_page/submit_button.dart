import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_conversion_usecase.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/application/income/income_usecase.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/color_getter.dart';
import 'package:kakeibo/view_model/state/input_mode_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';
import 'package:kakeibo/view_model/state/register_page/fixed_cost_input_controller/fixed_cost_input_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/payment_frequency_controller/payment_frequency_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_initialized_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';
import 'package:kakeibo/view_model/state/register_page/select_category_controller/select_category_controller.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class SubmitButton extends ConsumerWidget with PresentationMixin {
  const SubmitButton({
    super.key,
    required this.transactionMode,
    this.originalExpenseEntity,
    this.originalIncomeEntity,
    this.originalFixedCostEntity,
  });

  final TransactionMode transactionMode;
  final ExpenseEntity? originalExpenseEntity;
  final IncomeEntity? originalIncomeEntity;
  final FixedCostEntity? originalFixedCostEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // expenseEntityを扱うusecase
    final expenseUsecase = ref.read(expenseUsecaseProvider);
    // incomeEntityを扱うusecase
    final incomeUsecase = ref.read(incomeUsecaseProvider);
    // fixedCostEntityを扱うusecase
    final fixedCostUsecase = ref.read(fixedCostUsecaseProvider);
    // 既存の支出レコードを固定費化するusecase
    final fixedCostConversionUsecase =
        ref.read(fixedCostConversionUsecaseProvider);

    // 新規か編集か
    final screenMode = ref.watch(registerScreenModeNotifierProvider);

    return SizedBox(
      width: double.infinity,
      child: MainButton(
        buttonColor: getPillColor(context, ref.watch(inputModeControllerProvider)),
        buttonType: ButtonColorType.main,
        buttonText: screenMode == RegisterScreenMode.edit ? '更新' : '追加',
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

              // 拠出元を取得する
              final enteredIncomeSource =
                  ref.read(enteredIncomeSourceControllerNotifierProvider);

              // 入力されたメモを取得する
              final enteredMemo = ref.read(enteredMemoControllerProvider).text;

              // 入力された日付を取得する
              final inputDate = ref.read(inputDateControllerNotifierProvider);

              // 選択されたカテゴリーを取得する
              final selectedCategory =
                  ref.read(selectCategoryControllerNotifierProvider);

              switch (transactionMode) {
                case TransactionMode.expense:
                  // 固定費として登録するかどうか（仕様 §6.1・§6.6）
                  final isFixedCost = ref
                      .read(fixedCostRegisterToggleControllerNotifierProvider);

                  if (isFixedCost) {
                    await _submitFixedCost(
                      ref,
                      screenMode: screenMode,
                      enteredPrice: enteredPrice,
                      enteredMemo: enteredMemo,
                      enteredIncomeSource: enteredIncomeSource,
                      inputDate: inputDate,
                      selectedCategoryId: selectedCategory.id,
                      fixedCostUsecase: fixedCostUsecase,
                      expenseUsecase: expenseUsecase,
                      fixedCostConversionUsecase: fixedCostConversionUsecase,
                    );
                    break;
                  }

                  final entity = ExpenseEntity(
                    id: originalExpenseEntity!.id,
                    date: DateFormat('yyyyMMdd').format(inputDate),
                    price: enteredPrice,
                    paymentCategoryId: selectedCategory.id,
                    memo: enteredMemo,
                    incomeSourceBigCategory: enteredIncomeSource,
                  );
                  switch (screenMode) {
                    case RegisterScreenMode.add:
                      await expenseUsecase.add(expenseEntity: entity);
                      break;
                    case RegisterScreenMode.edit:
                      await expenseUsecase.edit(
                          originalEntity: originalExpenseEntity!,
                          editEntity: entity);
                      break;
                  }
                case TransactionMode.income:
                  final entity = IncomeEntity(
                    id: originalIncomeEntity!.id,
                    date: DateFormat('yyyyMMdd').format(inputDate),
                    price: enteredPrice,
                    categoryId: selectedCategory.id,
                    memo: enteredMemo,
                  );
                  switch (screenMode) {
                    case RegisterScreenMode.add:
                      await incomeUsecase.add(incomeEntity: entity);
                      break;
                    case RegisterScreenMode.edit:
                      await incomeUsecase.edit(
                          originalEntity: originalIncomeEntity!,
                          editEntity: entity);
                      break;
                  }
              }
            },

            // actionを実行しエラーがレスポンスされなかった場合の成功時の処理
            succesAction: () async {
              // DBの更新を通知
              ref.read(updateDBCountNotifierProvider.notifier).incrementState();

              // 入力状態をクリアして、次回画面表示時に値がリセットされるようにする
              ref.invalidate(enteredPriceControllerProvider);
              ref.invalidate(enteredMemoControllerProvider);
              ref.invalidate(inputDateControllerNotifierProvider);
              ref.invalidate(inputInitializedControllerProvider);
              ref.invalidate(enteredFixedCostNameControllerProvider);
              ref.invalidate(
                  fixedCostRegisterToggleControllerNotifierProvider);
              ref.invalidate(
                  fixedCostVariableSwitchControllerNotifierProvider);

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
        },
      ),
    );
  }

  /// 固定費トグルONのときの保存処理
  ///
  /// 追加は固定費マスタの新規作成（実績生成は既存の起動時バッチ経路に委ねる）、
  /// 編集は「既存支出の固定費化」。過去分の遡及生成は行わない（仕様 §6.2・§6.6）。
  Future<void> _submitFixedCost(
    WidgetRef ref, {
    required RegisterScreenMode screenMode,
    required int enteredPrice,
    required String enteredMemo,
    required int enteredIncomeSource,
    required DateTime inputDate,
    required int selectedCategoryId,
    required FixedCostUsecase fixedCostUsecase,
    required ExpenseUsecase expenseUsecase,
    required FixedCostConversionUsecase fixedCostConversionUsecase,
  }) async {
    // 変動費か固定費かを取得
    final variable =
        ref.read(fixedCostVariableSwitchControllerNotifierProvider) ? 1 : 0;
    // 支払い頻度を取得
    final frequencyValue =
        ref.read(paymentFrequencyControllerNotifierProvider);
    // 固定費の名称を取得
    final enteredName = ref.read(enteredFixedCostNameControllerProvider).text;

    switch (screenMode) {
      case RegisterScreenMode.add:
        // 固定費マスタを新規作成する。カテゴリーは支出小カテゴリーID（仕様 §3）
        final entity = FixedCostEntity(
          name: enteredName,
          price: variable == 0 ? enteredPrice : 0, // 変動費なら価格は0
          variable: variable,
          expenseSmallCategoryId: selectedCategoryId,
          intervalNumber: frequencyValue.intervalNumber,
          intervalUnit: frequencyValue.intervalUnit.inturvalUnitNumber,
          firstPaymentDate: DateFormat('yyyyMMdd').format(inputDate),
        );
        await fixedCostUsecase.add(fixedCostEntity: entity);
        break;

      case RegisterScreenMode.edit:
        // 既存支出の固定費化。初回支払日の変更は当該行の日付に同期する（仕様 §6.6）
        final original = originalExpenseEntity!;
        final editEntity = original.copyWith(
          date: DateFormat('yyyyMMdd').format(inputDate),
          price: enteredPrice,
          paymentCategoryId: selectedCategoryId,
          memo: enteredMemo,
          incomeSourceBigCategory: enteredIncomeSource,
        );
        // 支出側に変更が無いときは edit が「変更がありません」で弾くため、
        // 差分があるときだけ更新する
        if (editEntity != original) {
          await expenseUsecase.edit(
            originalEntity: original,
            editEntity: editEntity,
          );
        }
        await fixedCostConversionUsecase.convertToFixedCost(
          expenseEntity: editEntity,
          name: enteredName,
          variable: variable,
          intervalNumber: frequencyValue.intervalNumber,
          intervalUnit: frequencyValue.intervalUnit.inturvalUnitNumber,
        );
        break;
    }
  }
}
