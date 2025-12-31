import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/register_fixed_cost_page.dart';
import 'package:kakeibo/view/register_page/income_tab/register_income_page.dart';
import 'package:kakeibo/view/register_page/expense_tab/register_expense_page.dart';
import 'package:kakeibo/view_model/state/input_mode_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class RegisaterPageBase extends ConsumerStatefulWidget {
  final TransactionMode transactionMode;
  final RegisterScreenMode registerMode;

  final ExpenseEntity? expenseEntity;
  final IncomeEntity? incomeEntity;
  final FixedCostEntity? fixedCostEntity;

  /// 支出追加
  const RegisaterPageBase.addExpense({
    this.transactionMode = TransactionMode.expense,
    this.registerMode = RegisterScreenMode.add,
    this.expenseEntity,
    this.incomeEntity,
    this.fixedCostEntity,
    super.key,
  });

  /// 支出編集
  const RegisaterPageBase.editExpense({
    this.transactionMode = TransactionMode.expense,
    this.registerMode = RegisterScreenMode.edit,
    required this.expenseEntity,
    this.incomeEntity,
    this.fixedCostEntity,
    super.key,
  });

  /// 収入追加
  const RegisaterPageBase.addIncome({
    this.transactionMode = TransactionMode.income,
    this.registerMode = RegisterScreenMode.add,
    this.expenseEntity,
    this.incomeEntity,
    this.fixedCostEntity,
    super.key,
  });

  /// 収入編集
  const RegisaterPageBase.editIncome({
    this.transactionMode = TransactionMode.income,
    this.registerMode = RegisterScreenMode.edit,
    this.expenseEntity,
    required this.incomeEntity,
    this.fixedCostEntity,
    super.key,
  });

  /// 固定費追加
  const RegisaterPageBase.addFixedCost({
    this.transactionMode = TransactionMode.fixedCost,
    this.registerMode = RegisterScreenMode.add,
    this.expenseEntity,
    this.incomeEntity,
    this.fixedCostEntity,
    super.key,
  });

  /// 固定費編集
  const RegisaterPageBase.editFixedCost({
    this.transactionMode = TransactionMode.fixedCost,
    this.registerMode = RegisterScreenMode.edit,
    this.expenseEntity,
    this.incomeEntity,
    required this.fixedCostEntity,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisaterPageBaseState();
}

class _RegisaterPageBaseState extends ConsumerState<RegisaterPageBase>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(inputModeControllerProvider.notifier)
          .initialize(widget.transactionMode);
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //レイアウト------------------------------------------------------------------------------------

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,

        appBar: AppBar(
          // ヘッダーの色
          backgroundColor: MyColors.secondarySystemBackground,

          // ヘッダーの形
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          title: SizedBox(
            child: Text(
              widget.registerMode == RegisterScreenMode.add ? '記録' : '編集',
              style: RegisterPageStyles.regesterHeaderLabel,
            ),
          ),

          //ヘッダーの左ボタン
          leading: IconButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            icon: const Icon(
              //バッテン
              Icons.close_rounded,
              color: MyColors.white,
            ),
          ),
        ),

        //body
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _buildPageByMode(ref.watch(inputModeControllerProvider)),
        ),
      ),
    );
  }

  /// モードに応じたページを返す
  /// AnimatedSwitcherが正しく動作するようにKeyを設定
  Widget _buildPageByMode(TransactionMode mode) {
    return switch (mode) {
      TransactionMode.expense => RegisterExpensePage(
          key: const ValueKey('expense'),
          mode: widget.registerMode,
          expenseEntity: widget.expenseEntity,
        ),
      TransactionMode.fixedCost => RegisterFixedCostPage(
          key: const ValueKey('fixedCost'),
          mode: widget.registerMode,
          fixedCostEntity: widget.fixedCostEntity,
          isAppBarVisible: false,
        ),
      TransactionMode.income => RegisterIncomePage(
          key: const ValueKey('income'),
          mode: widget.registerMode,
          incomeEntity: widget.incomeEntity,
          isTabVisible: false,
        ),
    };
  }
}
