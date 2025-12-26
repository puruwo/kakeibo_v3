import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';

/// 大きな金額表示・入力フィールド
///
/// 画像デザインの「¥ 34,420」部分
class LargePriceDisplay extends ConsumerStatefulWidget {
  const LargePriceDisplay({
    super.key,
    required this.originalPrice,
  });

  final int originalPrice;

  @override
  ConsumerState<LargePriceDisplay> createState() => _LargePriceDisplayState();
}

class _LargePriceDisplayState extends ConsumerState<LargePriceDisplay> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text =
            NumberTextInputFormatter.formatInitialValue(widget.originalPrice);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _controller = ref.watch(enteredPriceControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 円マーク
        Text(
          '¥',
          style: TextStyle(
            color: MyColors.themeColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        // 金額入力フィールド
        IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 50),
            child: TextFormField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: MyColors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
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
                if (value == '0') {
                  _controller.clear();
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
      ],
    );
  }
}
