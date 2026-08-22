import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/large_price_display.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/price_input_row.dart';
import 'package:kakeibo/view/register_page/expense_tab/expense_basic_group.dart';
import 'package:kakeibo/view/register_page/expense_tab/fixed_cost_register_group.dart';
import 'package:kakeibo/view/register_page/submit_button.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/fixed_cost_input_controller/fixed_cost_input_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_initialized_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

/// 支出の登録・編集シート
///
/// 構成（仕様 §8.5 修正案B）: 種別ピル＋金額行／基本グループ／固定費グループ／カテゴリーグリッド。
/// セクション見出しは置かない。固定費トグルONで固定費として登録する（仕様 §6.1）。
class RegisterExpensePage extends ConsumerStatefulWidget {
  final RegisterScreenMode mode;
  final ExpenseEntity? expenseEntity;

  /// 固定費トグルの初期状態（年ページ・月次固定費ビューの追加導線からはON）
  final bool initialFixedCostToggle;

  const RegisterExpensePage({
    this.mode = RegisterScreenMode.add,
    this.expenseEntity,
    this.initialFixedCostToggle = false,
    super.key,
  });

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
      _initializeInputs();
    });

    super.initState();
  }

  /// 入力状態の初期値をまとめてセットする
  ///
  /// 行を個別のWidgetで初期化すると、固定費トグルで行が消えた時点で
  /// 入力値の持ち主がいなくなるため、ページ側で1回だけ流し込む。
  void _initializeInputs() {
    // 追加モードで既に初期化済みの場合は、ピル切り替え時に入力値を保持するためスキップ
    final isInitialized = ref.read(inputInitializedControllerProvider);
    if (widget.mode == RegisterScreenMode.add && isInitialized) {
      return;
    }

    ref.read(enteredMemoControllerProvider).text = initialExpenseData.memo;
    ref.read(inputDateControllerNotifierProvider.notifier).setData(
          DateTime.parse(
            '${initialExpenseData.date.substring(0, 4)}-${initialExpenseData.date.substring(4, 6)}-${initialExpenseData.date.substring(6, 8)}',
          ),
        );
    ref
        .read(enteredIncomeSourceControllerNotifierProvider.notifier)
        .setData(initialExpenseData.incomeSourceBigCategory);

    // 固定費グループ。名称はメモを引き継ぐ（仕様 §6.1）
    ref
        .read(fixedCostRegisterToggleControllerNotifierProvider.notifier)
        .setData(widget.initialFixedCostToggle);
    ref
        .read(fixedCostVariableSwitchControllerNotifierProvider.notifier)
        .setData(false);
    ref.read(enteredFixedCostNameControllerProvider).text =
        initialExpenseData.memo;
  }

  @override
  Widget build(BuildContext context) {
    final leftsidePadding = 16.0 * context.screenHorizontalMagnification;

    // 固定費トグルON時は基本グループを拠出元のみに縮める（仕様 §6.1）
    final isFixedCost =
        ref.watch(fixedCostRegisterToggleControllerNotifierProvider);
    // 変動型は金額を入力させず「---」表示にする
    final isVariable =
        ref.watch(fixedCostVariableSwitchControllerNotifierProvider);
    final priceInputFieldStatus = isFixedCost && isVariable
        ? PriceInputFieldStatus.unconfirmed
        : PriceInputFieldStatus.normal;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // 上部：支出ピル + 大きな金額表示
                PriceInputRow(
                  mode: widget.mode,
                  originalPrice: widget.expenseEntity?.price ?? 0,
                  status: priceInputFieldStatus,
                ),

                const SizedBox(height: AppSpacing.xl),

                // 基本グループ（拠出元／日付／メモ）
                ExpenseBasicGroup(
                  showDate: !isFixedCost,
                  showMemo: !isFixedCost,
                ),

                const SizedBox(height: AppSpacing.md),

                // 固定費グループ（トグル＋ON時の4行）
                FixedCostRegisterGroup(
                  note: widget.mode == RegisterScreenMode.edit
                      ? 'ONにすると、この支出を初回の支払いとして固定費を作成します（頻度・名称を続けて入力）'
                      : null,
                ),

                const SizedBox(height: AppSpacing.lg),

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
