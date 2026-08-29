// packegeImport
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/application/aggregation_settings/aggregation_settings_usecase.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/aggregation_period_rule/aggregation_period_rule.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/component/app_icon_circle_container.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';

/// 集計期間（月の開始日・年度の開始月）の設定ページ（KP-005）
///
/// 設定画面の「集計期間を設定する」から push で表示される。
/// ステッパーで値を選び、その設定で今日を含む集計期間がどうなるかをプレビューする。
/// 保存時は確認ダイアログで、過去の記録も新しい区切りで再計算されることを告知する。
class AggregationSettingPage extends ConsumerStatefulWidget {
  const AggregationSettingPage({
    super.key,
    required this.originalStartDay,
    required this.originalStartMonth,
  });

  /// 表示時点の集計開始日
  final int originalStartDay;

  /// 表示時点の集計開始月
  final int originalStartMonth;

  @override
  ConsumerState<AggregationSettingPage> createState() =>
      _AggregationSettingPageState();
}

class _AggregationSettingPageState
    extends ConsumerState<AggregationSettingPage> {
  late int _selectedStartDay;
  late int _selectedStartMonth;

  @override
  void initState() {
    super.initState();
    _selectedStartDay = widget.originalStartDay;
    _selectedStartMonth = widget.originalStartMonth;
  }

  /// 保存値から変更があるか（無ければ保存ボタンを非活性にする）
  bool get _hasChanges =>
      _selectedStartDay != widget.originalStartDay ||
      _selectedStartMonth != widget.originalStartMonth;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(systemDatetimeNotifierProvider);
    final monthPeriod = AggregationPeriodRule.monthPeriod(
      today: today,
      startDay: _selectedStartDay,
    );
    final yearPeriod = AggregationPeriodRule.yearPeriod(
      today: today,
      startDay: _selectedStartDay,
      startMonth: _selectedStartMonth,
    );

    return Scaffold(
      backgroundColor: context.colors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: const GlassAppBarBackground(),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('集計期間', style: AppTextStyles.pageHeaderText),
            Text('家計の区切りを決めます', style: AppTextStyles.pageHeaderSubText),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.colors.text,
          ),
        ),
      ),
      // 余白タップで入力欄のフォーカスを外す（キーボードを閉じ、入力途中の値を確定させる）
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
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
                      _buildSection(
                        title: '月の開始日',
                        description: '毎月この日から翌月の前日までを「1ヶ月」として集計します（1〜28日）',
                        stepper: _Stepper(
                          keyPrefix: 'aggregation_day',
                          value: _selectedStartDay,
                          unit: '日',
                          min: kAggregationStartDayMin,
                          max: kAggregationStartDayMax,
                          onChanged: (value) =>
                              setState(() => _selectedStartDay = value),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSection(
                        title: '年度の開始月',
                        description: 'この月の開始日から1年間を「年度」として集計します',
                        stepper: _Stepper(
                          keyPrefix: 'aggregation_month',
                          value: _selectedStartMonth,
                          unit: '月',
                          min: kAggregationStartMonthMin,
                          max: kAggregationStartMonthMax,
                          onChanged: (value) =>
                              setState(() => _selectedStartMonth = value),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _PreviewCard(
                        monthPeriod: monthPeriod,
                        yearPeriod: yearPeriod,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _RecalculationNotice(),
                    ],
                  ),
                ),
              ),
            ),
            // フッター（保存）。タブシェル内でpushされるページのためグロナビ分の余白を確保する
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                context.bottomNavClearance + AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                child: MainButton(
                  buttonType: ButtonColorType.main,
                  buttonText: '保存する',
                  onPressed: _hasChanges
                      ? () => _confirmAndSave(context)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 見出し＋ステッパー＋説明文のセクション
  Widget _buildSection({
    required String title,
    required String description,
    required Widget stepper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.appCardSectionTitle),
        const SizedBox(height: AppSpacing.sm),
        stepper,
        const SizedBox(height: AppSpacing.sm),
        Text(
          description,
          style: AppTextStyles.supportingText.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 確認ダイアログで承認されたら保存する
  Future<void> _confirmAndSave(BuildContext context) async {
    // 変更時は過去も新しい区切りで再計算されるため、保存前に必ず告知する
    final isApproved = await showConfirmationDialog(
      context,
      title: '集計期間の変更',
      message: '過去の記録もすべて新しい区切りで再計算されます。\n変更しますか？',
    );

    if (!isApproved) return;
    if (!context.mounted) return;

    // スナックバー表示用にpop前へ取得しておく
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(aggregationSettingsUsecaseProvider)
          .save(startDay: _selectedStartDay, startMonth: _selectedStartMonth);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
      SuccessSnackBar.show(scaffoldMessenger, message: '集計期間の設定を変更しました');
    } catch (e) {
      FailureSnackBar.show(scaffoldMessenger, message: '設定の変更に失敗しました: $e');
    }
  }
}

/// − / 値 / ＋ のステッパー。値は直接入力もできる（数字キーボード）
///
/// 端では該当ボタンを非活性にする（循環しない）。直接入力は範囲外なら
/// 上限・下限に丸め、空のままフォーカスが外れたら元の値に戻す。
class _Stepper extends StatefulWidget {
  const _Stepper({
    required this.keyPrefix,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  /// テストから各要素を特定するためのキー接頭辞
  final String keyPrefix;
  final int value;
  final String unit;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  State<_Stepper> createState() => _StepperState();
}

class _StepperState extends State<_Stepper> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _Stepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ボタン操作等で値が変わったら入力欄へ反映する（入力中の文字は上書きしない）
    if (oldWidget.value != widget.value &&
        _controller.text != '${widget.value}') {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// フォーカスが外れたとき、空・範囲外の入力を確定値に揃える
  void _onFocusChanged() {
    if (_focusNode.hasFocus) return;
    _commitText(_controller.text);
  }

  /// 入力文字列を範囲内の値に丸めて通知する。数値でなければ元の値に戻す
  void _commitText(String text) {
    final parsed = int.tryParse(text);
    final value = parsed == null
        ? widget.value
        : parsed.clamp(widget.min, widget.max);
    _controller.text = '$value';
    if (value != widget.value) widget.onChanged(value);
  }

  /// 入力のたびに範囲内なら即反映する（上限超過はその場で上限に丸める）
  void _onTextChanged(String text) {
    final parsed = int.tryParse(text);
    if (parsed == null) return;
    if (parsed > widget.max) {
      _controller.text = '${widget.max}';
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      widget.onChanged(widget.max);
      return;
    }
    // 下限未満（0）は入力途中の可能性があるためフォーカスが外れるまで保留する
    if (parsed >= widget.min) widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = widget.value > widget.min;
    final canIncrement = widget.value < widget.max;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.fillQuaternary,
        border: Border.all(color: context.colors.surfaceBorder, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepButton(
            key: ValueKey('${widget.keyPrefix}_decrement'),
            icon: Icons.remove_rounded,
            enabled: canDecrement,
            onTap: () => widget.onChanged(widget.value - 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              IntrinsicWidth(
                child: TextField(
                  key: ValueKey('${widget.keyPrefix}_value'),
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  style: AppTextStyles.stepperValueLabel.copyWith(
                    color: context.colors.text,
                  ),
                  cursorColor: context.colors.primary,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onChanged: _onTextChanged,
                  onSubmitted: _commitText,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.unit,
                style: AppTextStyles.listTilePrimaryTitle.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          _StepButton(
            key: ValueKey('${widget.keyPrefix}_increment'),
            icon: Icons.add_rounded,
            enabled: canIncrement,
            onTap: () => widget.onChanged(widget.value + 1),
          ),
        ],
      ),
    );
  }
}

/// ステッパーの増減ボタン（枠なしの円）。非活性時はタップを受け付けず色を沈める
///
/// 共通の [IconOnlyButton] は ADR-017 の境界線付きだが、ステッパーは
/// 入力欄の両脇に置く内側の操作なので枠を持たせない（KP-005 レビュー）。
class _StepButton extends StatelessWidget {
  const _StepButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const double size = 46;
    return IgnorePointer(
      ignoring: !enabled,
      child: AppInkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: AppIconCircleContainer(
          size: size,
          color: enabled
              ? context.colors.primaryTint
              : context.colors.fillQuaternary,
          child: Icon(
            icon,
            size: size * 0.5,
            color: enabled
                ? context.colors.primary
                : context.colors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// 選択中の設定で「今日」を含む今月・今年度の集計期間を示すカード
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.monthPeriod, required this.yearPeriod});

  final PeriodValue monthPeriod;
  final PeriodValue yearPeriod;

  /// 月の期間は年を省いた `M/d 〜 M/d`
  static String formatMonthPeriod(PeriodValue period) {
    final s = period.startDatetime;
    final e = period.endDatetime;
    return '${s.month}/${s.day} 〜 ${e.month}/${e.day}';
  }

  /// 年度の期間は `yyyy/M/d 〜 yyyy/M/d`
  static String formatYearPeriod(PeriodValue period) {
    final s = period.startDatetime;
    final e = period.endDatetime;
    return '${s.year}/${s.month}/${s.day} 〜 ${e.year}/${e.month}/${e.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.primaryTint,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'この設定での集計期間（例）',
            style: AppTextStyles.supportingText.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PreviewRow(
            label: '今月',
            value: formatMonthPeriod(monthPeriod),
            valueKey: const ValueKey('aggregation_preview_month'),
          ),
          const SizedBox(height: AppSpacing.xs),
          _PreviewRow(
            label: '今年度',
            value: formatYearPeriod(yearPeriod),
            valueKey: const ValueKey('aggregation_preview_year'),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: AppTextStyles.listTilePrimaryTitle.copyWith(
            color: context.colors.text,
          ),
        ),
        Text(
          value,
          key: valueKey,
          style: AppTextStyles.listTilePriceLabel.copyWith(
            color: context.colors.text,
          ),
        ),
      ],
    );
  }
}

/// 変更で過去の記録も再計算されることの事前告知
class _RecalculationNotice extends StatelessWidget {
  const _RecalculationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.danger.withValues(alpha: 0.12),
        border: Border.all(color: context.colors.danger.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: context.colors.danger,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '変更すると過去の記録もすべて新しい区切りで再計算されます',
              style: AppTextStyles.supportingText.copyWith(
                color: context.colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
