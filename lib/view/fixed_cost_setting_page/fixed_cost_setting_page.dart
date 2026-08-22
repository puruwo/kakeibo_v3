import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_detail_provider.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/unconfirmed_fixed_cost_chip_label.dart';
import 'package:kakeibo/view/fixed_cost_setting_page/expense_category_select_sheet.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/monthly_fixed_cost_page.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view/register_page/common_input_field/payment_frequency_picker.dart';
import 'package:kakeibo/view_model/state/register_page/payment_frequency_controller/payment_frequency_controller.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 固定費の設定画面（固定費マスタの編集）
///
/// 遷移元は固定費行の編集シートの「固定費」行・年ページの固定費一覧・月次固定費ビュー。
/// 削除導線はフッターの1つに限定する（AppBarにごみ箱は置かない。仕様 §6.7）。
class FixedCostSettingPage extends ConsumerStatefulWidget {
  const FixedCostSettingPage({super.key, required this.fixedCostEntity});

  final FixedCostEntity fixedCostEntity;

  @override
  ConsumerState<FixedCostSettingPage> createState() =>
      _FixedCostSettingPageState();
}

class _FixedCostSettingPageState extends ConsumerState<FixedCostSettingPage>
    with PresentationMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  /// 編集中の支出小カテゴリーID
  late int _smallCategoryId;

  /// 編集中の「支払い額が毎回変わる」
  late bool _isVariable;

  /// 編集中の次回支払日（yyyyMMdd）
  late String _nextPaymentDate;

  @override
  void initState() {
    super.initState();
    final entity = widget.fixedCostEntity;
    _nameController = TextEditingController(text: entity.name);
    _priceController = TextEditingController(
      text: NumberTextInputFormatter.formatInitialValue(entity.price),
    );
    _smallCategoryId = entity.expenseSmallCategoryId;
    _isVariable = entity.variable == 1;
    _nextPaymentDate = entity.nextPaymentDate ?? entity.firstPaymentDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 頻度ピッカーは共通のコントローラー経由で値を受け取る
      ref.read(paymentFrequencyControllerNotifierProvider.notifier).setData(
            PaymentFrequencyValue.fromDB(
              intervalNumber: entity.intervalNumber,
              intervalUnitNumber: entity.intervalUnit,
            ),
          );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fixedCostId = widget.fixedCostEntity.id;
    final paymentFrequency =
        ref.watch(paymentFrequencyControllerNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: const GlassAppBarBackground(),
        title: Text('固定費の設定', style: AppTextStyles.pageHeaderText),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.colors.text),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFixedCostGroup(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSettingGroup(paymentFrequency),
                    const SizedBox(height: AppSpacing.lg),
                    if (fixedCostId != null)
                      _buildPaymentHistoryGroup(fixedCostId),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // フッター（削除｜保存）。月次固定費ページのフッター2ボタンと同じ作法
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: MainButton(
                      buttonType: ButtonColorType.secondary,
                      textColor: context.colors.danger,
                      buttonText: 'この固定費を削除',
                      onPressed: () => _confirmDelete(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: MainButton(
                      buttonType: ButtonColorType.main,
                      buttonText: '保存',
                      onPressed: () => _save(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 「固定費」グループ（名称／カテゴリー）
  Widget _buildFixedCostGroup() {
    return AppInsetGroup(
      header: '固定費',
      children: [
        AppInsetRow.textField(
          icon: Icons.drive_file_rename_outline_rounded,
          label: '名称',
          controller: _nameController,
          hintText: '未入力',
          maxLength: 20,
        ),
        _buildCategoryRow(),
      ],
    );
  }

  /// カテゴリー行。値は「大 › 小」、タップで選択シートを開く（仕様 §6.7）
  Widget _buildCategoryRow() {
    return FutureBuilder(
      future: ref.read(categoryUsecaseProvider).fetchBySmallId(_smallCategoryId),
      builder: (context, snapshot) {
        final category = snapshot.data;
        return AppInsetRow.navigation(
          leading: category == null
              ? null
              : ExpenseCategoryIcon(
                  resourcePath: category.resourcePath,
                  colorCode: category.colorCode,
                ),
          label: 'カテゴリー',
          value: category == null
              ? '未選択'
              : '${category.bigCategoryName} › ${category.categoryName}',
          onTap: () async {
            final selected = await showExpenseCategorySelectSheet(
              context,
              selectedSmallCategoryId: _smallCategoryId,
            );
            if (selected != null) {
              setState(() => _smallCategoryId = selected.id);
            }
          },
        );
      },
    );
  }

  /// 「設定」グループ（金額／頻度／次回支払日／変動）
  Widget _buildSettingGroup(PaymentFrequencyValue paymentFrequency) {
    return AppInsetGroup(
      header: '設定',
      children: [
        // 変動型は実額を持たないため、推定額の表示に切り替える（仕様 §6.7）
        if (_isVariable)
          AppInsetRow.display(
            icon: Icons.payments_outlined,
            label: '予想額',
            value:
                '${yenmarkFormattedPriceGetter(widget.fixedCostEntity.estimatedPrice)}（自動）',
          )
        else
          AppInsetRow.textField(
            icon: Icons.payments_outlined,
            label: '金額',
            controller: _priceController,
            hintText: '未入力',
            keyboardType: TextInputType.number,
            inputFormatters: [NumberTextInputFormatter()],
            maxLength: 12,
          ),
        AppInsetRow.navigation(
          icon: Icons.repeat_rounded,
          label: '頻度',
          value: paymentFrequency.dateLabel,
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return PaymentFrequencyPicker(
                  originalPaymentFrequency: paymentFrequency,
                );
              },
            );
          },
        ),
        AppInsetRow.navigation(
          icon: Icons.calendar_today_outlined,
          label: '次回支払日',
          value: '${int.parse(_nextPaymentDate.substring(4, 6))}/'
              '${int.parse(_nextPaymentDate.substring(6, 8))}',
          onTap: _pickNextPaymentDate,
        ),
        AppInsetRow.switchRow(
          icon: Icons.trending_up_rounded,
          label: '支払い額が毎回変わる',
          switchValue: _isVariable,
          onSwitchChanged: (value) => setState(() => _isVariable = value),
        ),
      ],
    );
  }

  /// 「支払い履歴」グループ（直近5件＋すべての支払いを見る）
  Widget _buildPaymentHistoryGroup(int fixedCostId) {
    return ref.watch(fixedCostPaymentHistoryProvider(fixedCostId)).maybeWhen(
          data: (history) => AppInsetGroup(
            header: '支払い履歴',
            children: [
              if (history.isEmpty)
                AppInsetRow.display(label: 'まだ支払いの記録がありません')
              else
                ...history.map(_buildHistoryRow),
              AppInkWell(
                borderRadius: BorderRadius.zero,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MonthlyFixedCostPage(),
                    ),
                  );
                },
                child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      'すべての支払いを見る',
                      style: AppTextStyles.insetGroupLinkRow,
                    ),
                  ),
                ),
              ),
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        );
  }

  /// 支払い履歴の1行（日付／未確定チップ／金額）
  Widget _buildHistoryRow(ExpenseEntity expense) {
    final date = expense.date;
    final isUnconfirmed = expense.isConfirmed == 0;

    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kAppInsetRowIndent, 0, 12, 0),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Text(
                '${int.parse(date.substring(4, 6))}/'
                '${int.parse(date.substring(6, 8))}',
                style: AppTextStyles.insetGroupHistoryDate,
              ),
            ),
            if (isUnconfirmed) const UnconfirmedFixedCostChipLabel(),
            const Spacer(),
            Text(
              yenmarkFormattedPriceGetter(expense.effectivePrice),
              style: AppTextStyles.insetGroupHistoryPrice,
            ),
          ],
        ),
      ),
    );
  }

  /// 次回支払日を選ぶ
  Future<void> _pickNextPaymentDate() async {
    final current = DateTime.parse(
      '${_nextPaymentDate.substring(0, 4)}-${_nextPaymentDate.substring(4, 6)}-${_nextPaymentDate.substring(6, 8)}',
    );
    final picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        _nextPaymentDate = DateFormat('yyyyMMdd').format(picked);
      });
    }
  }

  /// 保存（カテゴリー変更は過去実績へ一括反映される。仕様 §6.4）
  void _save(BuildContext context) {
    execute(
      context,
      action: () async {
        final frequency = ref.read(paymentFrequencyControllerNotifierProvider);
        final enteredPrice = int.tryParse(
              _priceController.text.replaceAll(RegExp(r'\D'), ''),
            ) ??
            0;

        final editEntity = widget.fixedCostEntity.copyWith(
          name: _nameController.text,
          price: _isVariable ? 0 : enteredPrice,
          variable: _isVariable ? 1 : 0,
          expenseSmallCategoryId: _smallCategoryId,
          intervalNumber: frequency.intervalNumber,
          intervalUnit: frequency.intervalUnit.inturvalUnitNumber,
          nextPaymentDate: _nextPaymentDate,
        );

        await ref.read(fixedCostUsecaseProvider).edit(
              originalEntity: widget.fixedCostEntity,
              editEntity: editEntity,
            );
      },
      succesAction: () async {
        ref.read(updateDBCountNotifierProvider.notifier).incrementState();
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      successMessage: '保存しました',
    );
  }

  /// 削除（確認ダイアログ必須。未確定分と未到来の予定も連動削除される）
  Future<void> _confirmDelete(BuildContext context) async {
    final id = widget.fixedCostEntity.id;
    if (id == null) return;

    // 削除後の画面を閉じる操作でcontextを跨がないよう、先にNavigatorを取っておく
    final navigator = Navigator.of(context);

    await showFixedCostDeleteConfirmationDialog(
      context,
      onConfirm: () async {
        await ref.read(fixedCostUsecaseProvider).delete(id: id);
        navigator.pop();
      },
    );
  }
}
