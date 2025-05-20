import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/register_page/expense_tab/price_input_area/income_souce_picker.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';

// 支出登録ページにおける拠出元の入力部分

class IncomeSourceInputField extends ConsumerStatefulWidget {
  const IncomeSourceInputField({super.key,required this.originalIncomeSourceBigCategory});
  final int originalIncomeSourceBigCategory;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomeSourceInputField();
}

class _IncomeSourceInputField extends ConsumerState<IncomeSourceInputField> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      // 拠出元予算カテゴリーの初期値をセット
      ref
          .read(enteredIncomeSourceControllerNotifierProvider.notifier)
          .setData(widget.originalIncomeSourceBigCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    // コントローラの初期化
    final incomeSourceBigCategory =
        ref.watch(enteredIncomeSourceControllerNotifierProvider);

    return GestureDetector(
      child: Container(
        decoration: const BoxDecoration(
          color: MyColors.transparent,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // プレースホルダー
            Text(
              "拠出元",
              textAlign: TextAlign.left,
              style: MyFonts.placeHolder,
            ),

            // 選択状態
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 拠出元選択状態
                Text(
                  ref
                      .watch(anIncomeBigCategoryProvider(incomeSourceBigCategory))
                      .when(
                          data: (data) => data.name,
                          loading: () => '',
                          error: (e, _) => ''),
                  textAlign: TextAlign.right,
                  style: MyFonts.inputText,
                ),
                // テキストとアイコンの間のスペース
                const SizedBox(width: 4),
                // 矢印アイコン
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: MyColors.secondaryLabel,
                )
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return const IncomeSourcePicker();
            });
      },
    );
  }
}
