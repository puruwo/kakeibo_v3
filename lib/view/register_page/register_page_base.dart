import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/application/fixed_cost_record/fixed_cost_record_usecase.dart';
import 'package:kakeibo/application/income/income_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/register_page/expense_tab/edit_fixed_cost_record_page.dart';
import 'package:kakeibo/view/register_page/income_tab/register_income_page.dart';
import 'package:kakeibo/view/register_page/expense_tab/register_expense_page.dart';
import 'package:kakeibo/view_model/state/input_mode_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';
import 'package:kakeibo/view_model/state/register_page/fixed_cost_input_controller/fixed_cost_input_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_initialized_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class RegisaterPageBase extends ConsumerStatefulWidget {
  final TransactionMode transactionMode;
  final RegisterScreenMode registerMode;

  final ExpenseEntity? expenseEntity;
  final IncomeEntity? incomeEntity;

  /// 固定費トグルをONにした状態で開くか（固定費の直接登録導線。仕様 §6.3）
  final bool initialFixedCostToggle;

  /// 固定費の実績行（expenseのうち fixed_cost_id を持つ行）の編集シートか（仕様 §6.6）
  final bool isFixedCostRecordEdit;

  /// 支出追加
  const RegisaterPageBase.addExpense({
    this.transactionMode = TransactionMode.expense,
    this.registerMode = RegisterScreenMode.add,
    this.expenseEntity,
    this.incomeEntity,
    this.initialFixedCostToggle = false,
    this.isFixedCostRecordEdit = false,
    super.key,
  });

  /// 支出編集
  const RegisaterPageBase.editExpense({
    this.transactionMode = TransactionMode.expense,
    this.registerMode = RegisterScreenMode.edit,
    required this.expenseEntity,
    this.incomeEntity,
    this.initialFixedCostToggle = false,
    this.isFixedCostRecordEdit = false,
    super.key,
  });

  /// 収入追加
  const RegisaterPageBase.addIncome({
    this.transactionMode = TransactionMode.income,
    this.registerMode = RegisterScreenMode.add,
    this.expenseEntity,
    this.incomeEntity,
    this.initialFixedCostToggle = false,
    this.isFixedCostRecordEdit = false,
    super.key,
  });

  /// 収入編集
  const RegisaterPageBase.editIncome({
    this.transactionMode = TransactionMode.income,
    this.registerMode = RegisterScreenMode.edit,
    this.expenseEntity,
    required this.incomeEntity,
    this.initialFixedCostToggle = false,
    this.isFixedCostRecordEdit = false,
    super.key,
  });

  /// 固定費追加（支出タブの固定費トグルをONにした状態で開く。仕様 §6.3）
  const RegisaterPageBase.addFixedCost({
    this.transactionMode = TransactionMode.expense,
    this.registerMode = RegisterScreenMode.add,
    this.expenseEntity,
    this.incomeEntity,
    this.initialFixedCostToggle = true,
    this.isFixedCostRecordEdit = false,
    super.key,
  });

  /// 固定費の実績行の編集（編集できるのは金額・拠出元・メモのみ。仕様 §6.6）
  const RegisaterPageBase.editFixedCostRecord({
    this.transactionMode = TransactionMode.expense,
    this.registerMode = RegisterScreenMode.edit,
    required this.expenseEntity,
    this.incomeEntity,
    this.initialFixedCostToggle = false,
    this.isFixedCostRecordEdit = true,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisaterPageBaseState();
}

class _RegisaterPageBaseState extends ConsumerState<RegisaterPageBase> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(inputModeControllerProvider.notifier)
          .initialize(widget.transactionMode);
      // 最初のフレームで各入力フィールドが初期化された後、フラグを立てる
      // これにより、pill切り替え時は入力値が保持される
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(inputInitializedControllerProvider.notifier).state = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 入力プロバイダーをここで監視することで、pill切り替え時に破棄されないようにする
    // autoDisposeプロバイダーは監視しているウィジェットがなくなると破棄されるため、
    // 親ウィジェットで監視を維持する必要がある
    ref.watch(enteredPriceControllerProvider);
    ref.watch(enteredMemoControllerProvider);
    ref.watch(inputDateControllerNotifierProvider);
    // 固定費の名称も行の表示/非表示で破棄されないよう親で監視する
    ref.watch(enteredFixedCostNameControllerProvider);
    // 初期化フラグも監視して維持する（autoDisposeのため）
    ref.watch(inputInitializedControllerProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: SizedBox(
            child: Text(
              widget.registerMode == RegisterScreenMode.add ? '記録' : '編集',
              style: AppTextStyles.pageHeaderText,
            ),
          ),

          //ヘッダーの左ボタン
          leading: IconButton(
            onPressed: () {
              _clearInputState();
              Navigator.of(context, rootNavigator: true).pop();
            },
            icon: Icon(
              //バッテン
              Icons.close_rounded,
              color: context.colors.text,
            ),
          ),

          // 編集モードの場合のみ削除ボタンを表示
          actions: widget.registerMode == RegisterScreenMode.edit
              ? [
                  IconButton(
                    onPressed: () => _showDeleteConfirmDialog(context),
                    icon: Icon(
                      Icons.delete_outline,
                      color: context.colors.danger,
                    ),
                  ),
                ]
              : null,
        ),

        //body
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildPageByMode(ref.watch(inputModeControllerProvider)),
        ),
      ),
    );
  }

  /// モードに応じたページを返す
  /// AnimatedSwitcherが正しく動作するようにKeyを設定
  Widget _buildPageByMode(TransactionMode mode) {
    // 固定費の実績行の編集は種別の切り替えを持たない専用シート
    if (widget.isFixedCostRecordEdit) {
      return EditFixedCostRecordPage(
        key: const ValueKey('fixedCostRecord'),
        expenseEntity: widget.expenseEntity!,
      );
    }

    return switch (mode) {
      TransactionMode.expense => RegisterExpensePage(
        key: const ValueKey('expense'),
        mode: widget.registerMode,
        expenseEntity: widget.expenseEntity,
        initialFixedCostToggle: widget.initialFixedCostToggle,
      ),
      TransactionMode.income => RegisterIncomePage(
        key: const ValueKey('income'),
        mode: widget.registerMode,
        incomeEntity: widget.incomeEntity,
        isTabVisible: false,
      ),
    };
  }

  /// 削除確認ダイアログを表示
  void _showDeleteConfirmDialog(BuildContext context) async {
    await showDeleteConfirmationDialog(
      context,
      onConfirm: () {
        _executeDelete();
      },
    );
  }

  /// 削除処理を実行
  Future<void> _executeDelete() async {
    try {
      // 固定費の実績行の削除はこの1行のみ（マスタは消さない。仕様 §6.6）
      if (widget.isFixedCostRecordEdit) {
        await ref
            .read(fixedCostRecordUsecaseProvider)
            .delete(id: widget.expenseEntity!.id);
      } else {
        switch (widget.transactionMode) {
          case TransactionMode.expense:
            if (widget.expenseEntity != null) {
              await ref
                  .read(expenseUsecaseProvider)
                  .delete(id: widget.expenseEntity!.id);
            }
            break;
          case TransactionMode.income:
            if (widget.incomeEntity != null) {
              await ref
                  .read(incomeUsecaseProvider)
                  .delete(id: widget.incomeEntity!.id);
            }
            break;
        }
      }
      // 削除成功後、入力状態をクリアして画面を閉じる
      if (mounted) {
        _clearInputState();
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      // エラー時はスナックバーで表示
      if (mounted) {
        FailureSnackBar.show(
          ScaffoldMessenger.of(context),
          message: '削除に失敗しました: $e',
        );
      }
    }
  }

  /// 入力状態をクリアする
  /// 画面を閉じる際や登録完了後に呼び出して、次回表示時に値がリセットされるようにする
  void _clearInputState() {
    ref.invalidate(enteredPriceControllerProvider);
    ref.invalidate(enteredMemoControllerProvider);
    ref.invalidate(inputDateControllerNotifierProvider);
    ref.invalidate(inputInitializedControllerProvider);
    ref.invalidate(enteredFixedCostNameControllerProvider);
    ref.invalidate(fixedCostRegisterToggleControllerNotifierProvider);
    ref.invalidate(fixedCostVariableSwitchControllerNotifierProvider);
  }
}
