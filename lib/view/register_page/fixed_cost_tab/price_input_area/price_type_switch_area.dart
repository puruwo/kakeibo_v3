import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/register_page/price_type_switch_controller/price_type_switch_controller.dart';

// 固定費のタイプを切り替えるエリア
// 金額が固定されているか、変動するかを切り替える

class PriceTypeSwitchArea extends ConsumerStatefulWidget {
  const PriceTypeSwitchArea({super.key, required this.originalState});
  final bool originalState;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PriceTypeSwitchArea();
}

class _PriceTypeSwitchArea extends ConsumerState<PriceTypeSwitchArea> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初期値をセット
      ref
          .read(priceTypeSwitchControllerNotifierProvider.notifier)
          .setData(widget.originalState);
    });
  }

  @override
  Widget build(BuildContext context) {
    // コントローラの初期化
    final isOn = ref.watch(priceTypeSwitchControllerNotifierProvider);

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // プレースホルダー
          Text(
            "支払い額変あり",
            textAlign: TextAlign.right,
            style: RegisterPageStyles.placeHolder,
          ),

          // 選択状態
          Theme(
            // ThemeDataを上書きして、トグルOnの時のborderを透明にする
            data: ThemeData(
              useMaterial3: true,
            ).copyWith(
              colorScheme: Theme.of(context)
                  .colorScheme
                  .copyWith(outline: Colors.transparent),
            ),
            // トグルスイッチ
            // 大きさを小さくするためにTransform.scaleを使用
            child: Transform.scale(
              alignment: Alignment.centerRight,
              scale: 0.7,
              child: Switch(
                activeTrackColor: MyColors.themeColor, // トグルON時のバー色
                inactiveTrackColor: MyColors.systemGray, // トグルOFF時のバー色
                thumbColor: MaterialStateProperty.all(Colors.white), // トグルの丸の色
                value: isOn,
                onChanged: (value) {
                  ref
                      .read(priceTypeSwitchControllerNotifierProvider.notifier)
                      .setData(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
