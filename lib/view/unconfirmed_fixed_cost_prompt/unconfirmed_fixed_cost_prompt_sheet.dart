import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_provider.dart';
import 'package:kakeibo/application/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_usecase.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/register_page/expense_tab/open_fixed_cost_record_edit_sheet.dart';

/// 未確定固定費の一覧シートを開く（KP-028）
///
/// 起動時の促しと月間分析の注意バナーで共通の部品。並べる行だけが呼び出し元で変わる。
/// - [shownPeriod] が null: 起動時の促し（支払日が現在の月度より前の月度にある未確定行）
/// - [shownPeriod] を渡す: 注意バナー（その月度で、支払日から3日経過した未確定行）
Future<void> showUnconfirmedFixedCostPromptSheet(
  BuildContext context, {
  PeriodValue? shownPeriod,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true, // グローバルナビゲーション・記録モーダルにも被せる
    builder: (context) =>
        UnconfirmedFixedCostPromptSheet(shownPeriod: shownPeriod),
  );
}

/// 未確定固定費の一覧シート本体
class UnconfirmedFixedCostPromptSheet extends ConsumerStatefulWidget {
  const UnconfirmedFixedCostPromptSheet({super.key, this.shownPeriod});

  /// 注意バナーから開いたときの表示中の月度。null なら起動時の促し
  final PeriodValue? shownPeriod;

  @override
  ConsumerState<UnconfirmedFixedCostPromptSheet> createState() =>
      _UnconfirmedFixedCostPromptSheetState();
}

class _UnconfirmedFixedCostPromptSheetState
    extends ConsumerState<UnconfirmedFixedCostPromptSheet> {
  /// 「予想額で確定」の処理中は二重押下を防ぐ
  bool _isConfirming = false;

  bool get _isLaunchPrompt => widget.shownPeriod == null;

  /// 並べる行のプロバイダー（呼び出し元で対象が変わる）
  ProviderListenable<AsyncValue<List<MonthlyUnconfirmedFixedCostTileValue>>>
  get _targetsProvider => _isLaunchPrompt
      ? launchUnconfirmedFixedCostTargetsProvider
      : overdueUnconfirmedFixedCostTargetsProvider(widget.shownPeriod!);

  Future<List<MonthlyUnconfirmedFixedCostTileValue>> _readTargets() =>
      _isLaunchPrompt
      ? ref.read(launchUnconfirmedFixedCostTargetsProvider.future)
      : ref.read(
          overdueUnconfirmedFixedCostTargetsProvider(
            widget.shownPeriod!,
          ).future,
        );

  @override
  Widget build(BuildContext context) {
    // 確定で行が減る途中も前の一覧を出したままにする（一瞬の空表示を挟まない）
    final targets = ref.watch(_targetsProvider).valueOrNull ?? const [];
    final today = ref.watch(systemDatetimeNotifierProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        border: Border(top: BorderSide(color: context.colors.surfaceBorder)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
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
              Text('金額が未入力の固定費があります', style: context.textStyles.sheetTitle),
              const SizedBox(height: 4),
              Text(
                _isLaunchPrompt
                    ? '過去の月の固定費が${targets.length}件、未入力のままです'
                    : '支払日を過ぎた固定費が${targets.length}件、未入力のままです',
                style: context.textStyles.insetGroupNote,
              ),
              const SizedBox(height: 14),
              // 件数が多いときは一覧だけをスクロールさせる
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: SingleChildScrollView(
                  child: AppInsetGroup(
                    children: [
                      for (final target in targets)
                        _PromptRow(
                          key: ValueKey('unconfirmedPromptRow_${target.id}'),
                          value: target,
                          today: today,
                          onTap: () => _onTapRow(target),
                          onConfirmWithEstimatedPrice:
                              target.estimatedPrice > 0 && !_isConfirming
                              ? () => _onConfirmWithEstimatedPrice(target)
                              : null,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: MainButton(
                  buttonType: ButtonColorType.secondary,
                  buttonText: _isLaunchPrompt ? 'あとで' : '閉じる',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 行タップ。既存の固定費行の編集シートで実額を入力する
  Future<void> _onTapRow(MonthlyUnconfirmedFixedCostTileValue target) async {
    await openFixedCostRecordEditSheet(context, ref, expenseId: target.id);
    await _closeIfEmpty();
  }

  /// 「予想額で確定」。確認ダイアログを挟んでから確定する
  Future<void> _onConfirmWithEstimatedPrice(
    MonthlyUnconfirmedFixedCostTileValue target,
  ) async {
    final rootMessenger = ScaffoldMessenger.of(
      Navigator.of(context, rootNavigator: true).context,
    );
    final confirmed = await showConfirmationDialog(
      context,
      title: '予想額で確定しますか？',
      message:
          '${target.name}（${_paymentDateLabel(target.date, ref.read(systemDatetimeNotifierProvider))}）を'
          '${yenmarkFormattedPriceGetter(target.estimatedPrice)}で確定します。\n'
          '金額はあとから変更できます。',
      confirmLabel: '確定する',
      barrierDismissible: true,
    );
    if (!confirmed || !mounted) return;

    // 成功時は行が一覧から消えることが結果の表示になる（スナックバーはシートの裏に隠れて見えない）。
    // 失敗時だけ、シートを閉じてからスナックバーで知らせる
    setState(() => _isConfirming = true);
    String? failureMessage;
    try {
      await ref
          .read(unconfirmedFixedCostPromptUsecaseProvider)
          .confirmWithEstimatedPrice(
            expenseId: target.id,
            estimatedPrice: target.estimatedPrice,
          );
    } on AppException catch (e) {
      failureMessage = e.message;
    } catch (e) {
      failureMessage = '確定に失敗しました';
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }

    if (failureMessage != null) {
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        Navigator.of(context).pop();
      }
      FailureSnackBar.show(rootMessenger, message: failureMessage);
      return;
    }
    await _closeIfEmpty();
  }

  /// 対象が0件になったらシートを自動的に閉じる
  ///
  /// 編集シート・確認ダイアログが閉じた後に呼ぶ（上に別の画面が残っている間は閉じない）。
  Future<void> _closeIfEmpty() async {
    if (!mounted) return;
    final targets = await _readTargets();
    if (!mounted || targets.isNotEmpty) return;
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Navigator.of(context).pop();
    }
  }
}

/// 支払日の表示。今年（運用日付 [today] の年）は M/d、今年以外は yyyy/M/d
String _paymentDateLabel(DateTime date, DateTime today) {
  final isThisYear = date.year == today.year;
  return isThisYear
      ? '${date.month}/${date.day}'
      : '${date.year}/${date.month}/${date.day}';
}

/// 一覧の1行（カテゴリーアイコン／固定費名／支払日と予想額／「予想額で確定」／シェブロン）
class _PromptRow extends StatelessWidget {
  const _PromptRow({
    super.key,
    required this.value,
    required this.today,
    required this.onTap,
    required this.onConfirmWithEstimatedPrice,
  });

  final MonthlyUnconfirmedFixedCostTileValue value;

  /// 運用日付（支払日の年の表示を省くかどうかの基準）
  final DateTime today;
  final VoidCallback onTap;

  /// null のときは「予想額で確定」を出さない（予想額が0円）か、押せない（処理中）
  final VoidCallback? onConfirmWithEstimatedPrice;

  @override
  Widget build(BuildContext context) {
    final hasEstimatedPrice = value.estimatedPrice > 0;

    // グループ側で角丸をクリップ済みなので、行のリップルは角丸なしにする
    return AppInkWell(
      borderRadius: BorderRadius.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kAppInsetRowIndent, 10, 12, 10),
        child: Row(
          children: [
            ExpenseCategoryIcon(
              resourcePath: value.resourcePath,
              colorCode: value.colorCode,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.name,
                    style: context.textStyles.listTilePrimaryTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasEstimatedPrice
                        ? '${_paymentDateLabel(value.date, today)}・予想 ${yenmarkFormattedPriceGetter(value.estimatedPrice)}'
                        : _paymentDateLabel(value.date, today),
                    style: context.textStyles.listCardSecondaryNumeric,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasEstimatedPrice)
              // 本文内の補助リンク（ボタンルール §4）。行タップ（編集シート）とは別の操作
              Semantics(
                button: true,
                enabled: onConfirmWithEstimatedPrice != null,
                child: AppInkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onConfirmWithEstimatedPrice,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Text(
                      '予想額で確定',
                      style: onConfirmWithEstimatedPrice == null
                          ? context.textStyles.textButtonTextStyle.copyWith(
                              color: context.colors.textTertiary,
                            )
                          : context.textStyles.textButtonTextStyle,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 2),
            Icon(AppIcons.next, size: 14, color: context.colors.textTertiary),
          ],
        ),
      ),
    );
  }
}
