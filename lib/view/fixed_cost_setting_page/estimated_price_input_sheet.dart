import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_segmented_control.dart';
import 'package:kakeibo/view/component/button_util.dart';

/// 予想額の入力シートの結果（仕様 §6.9）
class EstimatedPriceInputResult {
  const EstimatedPriceInputResult({
    required this.isManual,
    required this.estimatedPrice,
  });

  /// 手動設定なら true（＝ `estimated_price_is_manual` が1）
  final bool isManual;

  /// 決定した予想額
  final int estimatedPrice;
}

/// 予想額の入力シートを開く（仕様 §6.9）
///
/// 「自動で算出」を選ぶと [autoAveragePrice]（過去の確定額の平均）を表示し、
/// 入力はできない。「自分で設定」を選ぶと金額を入力できる。
/// 「決定」で [EstimatedPriceInputResult] を返す。閉じた場合は null。
Future<EstimatedPriceInputResult?> showEstimatedPriceInputSheet(
  BuildContext context, {
  required bool isManual,
  required int estimatedPrice,
  required int? autoAveragePrice,
}) {
  return showModalBottomSheet<EstimatedPriceInputResult>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => EstimatedPriceInputSheet(
      isManual: isManual,
      estimatedPrice: estimatedPrice,
      autoAveragePrice: autoAveragePrice,
    ),
  );
}

/// 予想額の入力シート本体
class EstimatedPriceInputSheet extends StatefulWidget {
  const EstimatedPriceInputSheet({
    super.key,
    required this.isManual,
    required this.estimatedPrice,
    required this.autoAveragePrice,
  });

  /// 開いた時点で手動設定か
  final bool isManual;

  /// 開いた時点の予想額
  final int estimatedPrice;

  /// 過去の確定額の平均（確定行が0件のときは null）
  final int? autoAveragePrice;

  @override
  State<EstimatedPriceInputSheet> createState() =>
      _EstimatedPriceInputSheetState();
}

class _EstimatedPriceInputSheetState extends State<EstimatedPriceInputSheet> {
  late final TextEditingController _priceController;

  /// 編集中の「自分で設定」かどうか
  late bool _isManual;

  @override
  void initState() {
    super.initState();
    _isManual = widget.isManual;
    _priceController = TextEditingController(
      text: NumberTextInputFormatter.formatInitialValue(widget.estimatedPrice),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  /// 自動算出時に表示する金額
  ///
  /// 確定行が0件で平均が無い場合は、現在の予想額をそのまま出す（仕様 §6.5 のフォールバック）。
  int get _autoPrice => widget.autoAveragePrice ?? widget.estimatedPrice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // キーボードで金額入力欄が隠れないように押し上げる
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          border: Border(
            top: BorderSide(color: context.colors.surfaceBorder),
          ),
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
              Text('予想額', style: AppTextStyles.sheetTitle),
              const SizedBox(height: 14),
              AppSegmentedControl(
                labels: const ['自動で算出', '自分で設定'],
                selectedIndex: _isManual ? 1 : 0,
                onChanged: _onSegmentChanged,
              ),
              const SizedBox(height: 14),
              _buildPriceField(context),
              const SizedBox(height: 14),
              Text(
                '自動で算出 ＝ 過去の確定額の平均'
                '（現在 ${yenmarkFormattedPriceGetter(_autoPrice)}）。'
                '自分で設定した額は、支払いを確定しても上書きされません',
                style: AppTextStyles.insetGroupNote,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: MainButton(
                  buttonType: ButtonColorType.main,
                  buttonText: '決定',
                  onPressed: _onDecided,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// セグメント切り替え
  ///
  /// 自動へ戻したときは平均を表示に反映し、手動へ戻したときの初期値にもする。
  void _onSegmentChanged(int index) {
    final isManual = index == 1;
    setState(() {
      _isManual = isManual;
      if (!isManual) {
        FocusScope.of(context).unfocus();
        _priceController.text =
            NumberTextInputFormatter.formatInitialValue(_autoPrice);
      }
    });
  }

  /// 金額の表示・入力欄（自動選択時は入力不可）
  Widget _buildPriceField(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Spacer(),
        Text('¥', style: AppTextStyles.sheetPriceYenSymbol),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: _isManual
              ? TextField(
                  key: const Key('estimatedPriceSheetField'),
                  controller: _priceController,
                  autofocus: true,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NumberTextInputFormatter()],
                  maxLength: 12,
                  style: AppTextStyles.sheetPriceInput,
                  cursorColor: context.colors.primary,
                  cursorWidth: 2,
                  keyboardAppearance: Brightness.dark,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) =>
                      null,
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                )
              : Text(
                  NumberTextInputFormatter.formatInitialValue(_autoPrice),
                  key: const Key('estimatedPriceSheetAutoValue'),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.sheetPriceInput,
                ),
        ),
      ],
    );
  }

  /// 「決定」。画面側の状態に反映させるだけで、永続化は画面の「保存」で行う
  void _onDecided() {
    final entered =
        int.tryParse(_priceController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

    Navigator.of(context).pop(
      EstimatedPriceInputResult(
        isManual: _isManual,
        estimatedPrice: _isManual ? entered : _autoPrice,
      ),
    );
  }
}
