import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/color_getter.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/input_mode_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_initialized_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

/// 金額入力フィールドの状態
enum PriceInputFieldStatus {
  normal, // 通常
  unconfirmed, // 未確定
}

/// 大きな金額表示・入力フィールド
class LargePriceDisplay extends ConsumerStatefulWidget {
  const LargePriceDisplay({
    super.key,
    required this.originalPrice,
    this.status = PriceInputFieldStatus.normal,
  });

  final int originalPrice;
  final PriceInputFieldStatus? status;

  @override
  ConsumerState<LargePriceDisplay> createState() => _LargePriceDisplayState();
}

class _LargePriceDisplayState extends ConsumerState<LargePriceDisplay> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 追加モードで既に初期化済みの場合は、入力値を保持するためスキップ
      final isInitialized = ref.read(inputInitializedControllerProvider);
      final mode = ref.read(registerScreenModeNotifierProvider);
      if (mode == RegisterScreenMode.add && isInitialized) {
        return;
      }
      _controller.text =
          NumberTextInputFormatter.formatInitialValue(widget.originalPrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    _controller = ref.watch(enteredPriceControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 円マーク
        Text(
          '¥',
          style: RegisterPageStyles.yenSymbol(
            getPillColor(ref.watch(inputModeControllerProvider)),
          ).copyWith(
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        // 金額入力フィールド or 未確定表示
        widget.status == PriceInputFieldStatus.normal
            ? _buildInputField()
            : _buildUnconfirmedDisplay(),
      ],
    );
  }

  Widget _buildInputField() {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomRight,
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 50),
            child: TextFormField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.right,
              style: RegisterPageStyles.priceInput,
              cursorColor: MyColors.themeColor,
              cursorWidth: 3,
              cursorHeight: 42,
              maxLines: 1,
              maxLength: 12,
              buildCounter: (context,
                  {required currentLength,
                  required isFocused,
                  required maxLength}) {
                return null;
              },
              inputFormatters: [NumberTextInputFormatter()],
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.dark,
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value == '') {
                  _controller.text = '0';
                }
              },
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnconfirmedDisplay() {
    return const Text(
      '---',
      style: RegisterPageStyles.priceUnconfirmed,
    );
  }
}
