import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/expense_tab/price_input_area/expense_input_area.dart';
import 'package:kakeibo/view/register_page/common_input_field/memo_input_field.dart';
import 'package:kakeibo/view/register_page/submit_button.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';
import 'package:kakeibo/view/register_page/common_input_field/date_input_field.dart';

class RegisterExpensePage extends ConsumerStatefulWidget {
  final RegisterScreenMode mode;

  final ExpenseEntity? expenseEntity;

  const RegisterExpensePage(
      {this.mode = RegisterScreenMode.add, this.expenseEntity, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisterExpensePageState();
}

class _RegisterExpensePageState extends ConsumerState<RegisterExpensePage> {
  late ExpenseEntity initialExpenseData;

  @override
  void initState() {
    // entityを受け取っていなければ初期データで宣言、受け取っていればそれを宣言
    initialExpenseData = widget.expenseEntity ??
        ExpenseEntity(
          date: DateFormat('yyyyMMdd').format(DateTime.now()),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 編集モードか？
      ref
          .read(registerScreenModeNotifierProvider.notifier)
          .setData(widget.mode);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    //レイアウト------------------------------------------------------------------------------------

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
          backgroundColor: MyColors.secondarySystemBackground,

          //body
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(leftsidePadding),
                child: Column(
                  children: [
                    SizedBox(height: 5),

                    SizedBox(height: 8),

                    ExpenseInputArea(
                      originalPrice: initialExpenseData.price,
                      originalIncomeSourceBigCategory:
                          initialExpenseData.incomeSourceBigCategory,
                    ),

                    SizedBox(height: 8),

                    MemoInputField(originalMemo: initialExpenseData.memo),

                    SizedBox(height: 8),

                    DateInputField(originalDate: initialExpenseData.date),

                    SizedBox(height: 16),

                    // カテゴリー選択エリア
                    CategoryArea(
                        transactionMode: TransactionMode.expense,
                        originalCategoryId:
                            initialExpenseData.paymentCategoryId),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SubmitButton(
                transactionMode: TransactionMode.expense,
                originalExpenseEntity: initialExpenseData),
          )),
    );
  }
}
