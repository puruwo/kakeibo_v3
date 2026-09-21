import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/budget/budget_usecase.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';

/// 単一カテゴリーの予算入力シートを開く（KP-027）
///
/// カテゴリーのホーム画面（大カテゴリー支出履歴）から、表示中の月度・その大カテゴリーの
/// 予算だけを入力して保存する。全カテゴリーの一括編集は「毎月の予算」ページが担う。
///
/// [budgetEditValue] は表示中の月度のその大カテゴリーの予算（未設定なら notRegisterd）。
/// [periodLabel] は見出しの下に出す月度の表示。[isCurrentPeriod] が true なら参考値は
/// 「先月の支出」、false なら「その月の支出」（`BudgetUsecase.fetchAll` の分岐と揃える）。
/// [fixedCostForecast] はその大カテゴリーの固定費見込み（0なら表示しない）。
Future<void> showSingleCategoryBudgetSheet(
  BuildContext context, {
  required BudgetEditValue budgetEditValue,
  required String periodLabel,
  required bool isCurrentPeriod,
  required int fixedCostForecast,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => SingleCategoryBudgetSheet(
      budgetEditValue: budgetEditValue,
      periodLabel: periodLabel,
      isCurrentPeriod: isCurrentPeriod,
      fixedCostForecast: fixedCostForecast,
    ),
  );
}

/// 単一カテゴリーの予算入力シート本体
class SingleCategoryBudgetSheet extends ConsumerStatefulWidget {
  const SingleCategoryBudgetSheet({
    super.key,
    required this.budgetEditValue,
    required this.periodLabel,
    required this.isCurrentPeriod,
    required this.fixedCostForecast,
  });

  final BudgetEditValue budgetEditValue;
  final String periodLabel;
  final bool isCurrentPeriod;
  final int fixedCostForecast;

  @override
  ConsumerState<SingleCategoryBudgetSheet> createState() =>
      _SingleCategoryBudgetSheetState();
}

class _SingleCategoryBudgetSheetState
    extends ConsumerState<SingleCategoryBudgetSheet> {
  late final TextEditingController _priceController;

  /// 保存処理中は二重押下を防ぐためボタンを非活性にする
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 未設定（0円）のときは空欄から入力を始める
    final price = widget.budgetEditValue.price;
    _priceController = TextEditingController(
      text: price > 0 ? NumberTextInputFormatter.formatInitialValue(price) : '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  int get _enteredPrice =>
      int.tryParse(_priceController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  /// 入力額が開いた時点の予算と違うか（同じなら保存しても何も起きない）
  bool get _isChanged => _enteredPrice != widget.budgetEditValue.price;

  @override
  Widget build(BuildContext context) {
    final value = widget.budgetEditValue;

    // 予算が固定費見込みを下回るときは金額と固定費の文字を danger 色にする。入力はブロックしない
    final isUnderFixedCost =
        widget.fixedCostForecast > 0 && _enteredPrice < widget.fixedCostForecast;

    return Padding(
      // キーボードで金額入力欄が隠れないように押し上げる
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          border: Border(top: BorderSide(color: context.colors.surfaceBorder)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ハンドル
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.fillSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  ExpenseCategoryIcon(
                    resourcePath: value.resourcePath,
                    colorCode: value.colorCode,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      '${value.expenseBigCategoryName}の予算',
                      style: context.textStyles.sheetTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(widget.periodLabel, style: context.textStyles.insetGroupNote),
              const SizedBox(height: 14),
              _buildPriceField(context, isUnderFixedCost: isUnderFixedCost),
              const SizedBox(height: 14),
              _ReferenceRow(
                label: widget.isCurrentPeriod ? '先月の支出' : 'この月の支出',
                value: value.lastMonthBudgetPrice == 0
                    ? '---'
                    : yenmarkFormattedPriceGetter(value.lastMonthBudgetPrice),
              ),
              if (widget.fixedCostForecast > 0) ...[
                const SizedBox(height: 4),
                _ReferenceRow(
                  label: 'このカテゴリーの固定費',
                  value: yenmarkFormattedPriceGetter(widget.fixedCostForecast),
                  isDanger: isUnderFixedCost,
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: MainButton(
                  iconData: AppIcons.done,
                  buttonType: ButtonColorType.main,
                  buttonText: '保存',
                  onPressed: _isChanged && !_isSaving ? _onSave : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 金額の入力欄
  Widget _buildPriceField(
    BuildContext context, {
    required bool isUnderFixedCost,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('¥', style: context.textStyles.sheetPriceYenSymbol),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          // 入力欄を数字の幅に合わせ、「¥」が桁数によらず数字の直前に付くようにする
          child: IntrinsicWidth(
            child: TextField(
            key: const Key('singleCategoryBudgetSheetField'),
            controller: _priceController,
            autofocus: true,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            inputFormatters: [NumberTextInputFormatter()],
            maxLength: 12,
            style: isUnderFixedCost
                ? context.textStyles.sheetPriceInput.copyWith(
                    color: context.colors.danger,
                  )
                : context.textStyles.sheetPriceInput,
            cursorColor: context.colors.primary,
            cursorWidth: 2,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => null,
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: '0',
              hintStyle: context.textStyles.sheetPriceInput.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
            // 保存ボタンの活性・警告色を入力に追従させる
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
        ),
      ],
    );
  }

  /// 「保存」。既存の一括編集と同じユースケースで1カテゴリー分だけ保存する
  Future<void> _onSave() async {
    final navigator = Navigator.of(context);
    final rootMessenger = ScaffoldMessenger.of(
      Navigator.of(context, rootNavigator: true).context,
    );
    setState(() => _isSaving = true);
    try {
      await ref
          .read(budgetUsecaseProvider)
          .edit(
            originalValues: [widget.budgetEditValue],
            editPrice: [_enteredPrice],
          );
      navigator.pop();
      SuccessSnackBar.show(rootMessenger, message: '予算を保存しました');
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      FailureSnackBar.show(rootMessenger, message: '保存に失敗しました');
    }
  }
}

/// シート内の参考値の1行（左にラベル・右に金額）
class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({
    required this.label,
    required this.value,
    this.isDanger = false,
  });

  final String label;
  final String value;

  /// 予算が固定費見込みを下回るときの警告表示
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textStyles.supportingText;
    final valueStyle = context.textStyles.listTileSubPriceLabel;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isDanger
              ? labelStyle.copyWith(color: context.colors.danger)
              : labelStyle,
        ),
        Text(
          value,
          style: isDanger
              ? valueStyle.copyWith(color: context.colors.danger)
              : valueStyle,
        ),
      ],
    );
  }
}
