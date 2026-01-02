import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/common_input_field/budget_row.dart';
import 'package:kakeibo/view/register_page/common_input_field/date_memo_row.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/price_input_row.dart';
import 'package:kakeibo/view/register_page/submit_button.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

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
    initialExpenseData = widget.expenseEntity ??
        ExpenseEntity(
          date: DateFormat('yyyyMMdd')
              .format(ref.read(systemDatetimeNotifierProvider)),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(registerScreenModeNotifierProvider.notifier)
          .setData(widget.mode);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final leftsidePadding = 16.0 * context.screenHorizontalMagnification;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 上部：支出ピル + 大きな金額表示
                // 購入金額入力
                PriceInputRow(
                  mode: widget.mode,
                  originalPrice: widget.expenseEntity?.price ?? 0,
                ),

                const SizedBox(height: 32),

                // 予算行
                BudgetRow(
                  originalIncomeSourceBigCategory:
                      initialExpenseData.incomeSourceBigCategory,
                ),

                const SizedBox(height: 16),

                // 日付+メモ行
                DateMemoRow(
                  originalDate: initialExpenseData.date,
                  originalMemo: initialExpenseData.memo,
                ),

                const SizedBox(height: 24),

                // カテゴリー選択エリア（ページインジケーター付き）
                Center(
                  child: CategoryArea(
                    transactionMode: TransactionMode.expense,
                    originalCategoryId: initialExpenseData.paymentCategoryId,
                    showRearrangeLink: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 固定フッターの完了ボタン
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SubmitButton(
              transactionMode: TransactionMode.expense,
              originalExpenseEntity: initialExpenseData,
            ),
          ),
        ),
      ),
    );
  }
}
