import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/view/component/app_component.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/register_fixed_cost_page.dart';
import 'package:kakeibo/view/register_page/income_tab/register_income_page.dart';
import 'package:kakeibo/view/register_page/expense_tab/register_expense_page.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class RegisaterPageBase extends ConsumerStatefulWidget {
  final bool shouldDisplayTab;
  final TransactionMode transactionMode;
  final RegisterScreenMode registerMode;

  final ExpenseEntity? expenseEntity;
  final IncomeEntity? incomeEntity;
  final FixedCostEntity? fixedCostEntity;

  const RegisaterPageBase(
      {required this.shouldDisplayTab,
      required this.transactionMode,
      this.registerMode = RegisterScreenMode.add,
      this.expenseEntity,
      this.incomeEntity,
      this.fixedCostEntity,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisaterPageBaseState();
}

class _RegisaterPageBaseState extends ConsumerState<RegisaterPageBase>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    final initialIndex = widget.transactionMode.modeNumber;

    // タブを2つに設定
    _tabController =
        TabController(initialIndex: initialIndex, length: 3, vsync: this);

    // 編集モードなのにoriginalEntityを受け取っていない
    if (widget.registerMode == RegisterScreenMode.edit) {
      if ((widget.transactionMode == TransactionMode.expense &&
              widget.expenseEntity == null) &&
          (widget.transactionMode == TransactionMode.fixedCost &&
              widget.fixedCostEntity == null) &&
          (widget.transactionMode == TransactionMode.income &&
              widget.incomeEntity == null)) {
        throw const AppException('編集モードで編集前データが入力されていません');
      }
    }

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
              widget.registerMode == RegisterScreenMode.add ? '記録' : '記録を編集する',
              style: MyFonts.regesterHeaderLabel,
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
          bottom: AppTab(tabController: _tabController, tabs: const [
            Tab(text: '支出'),
            Tab(text: '固定費'),
            Tab(text: '収入'),
          ]),
        ),

        //body
        body: TabBarView(controller: _tabController, children: [
          RegisterExpensePage(
            mode: RegisterScreenMode.add,
            expenseEntity: widget.expenseEntity,
            isTabVisible: false,
          ),
          RegisterFixedCostPage(
            mode: RegisterScreenMode.add,
            fixedCostEntity: widget.fixedCostEntity,
            isAppBarVisible: false,
          ),
          RegisterIncomePage(
            mode: RegisterScreenMode.add,
            incomeEntity: widget.incomeEntity,
            isTabVisible: false, // タブを非表示にする
          ),
        ]),
      ),
    );
  }
}
