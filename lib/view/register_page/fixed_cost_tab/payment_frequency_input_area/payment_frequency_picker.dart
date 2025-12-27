// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/register_page_styles.dart';
import 'package:kakeibo/view_model/state/register_page/payment_frequency_controller/payment_frequency_controller.dart';

// 支出登録画面の拠出元選択画面
// 拠出元表示部分をタップしたら出現する

class PaymentFrequencyPicker extends ConsumerStatefulWidget {
  const PaymentFrequencyPicker(
      {super.key, required this.originalPaymentFrequency});

  final PaymentFrequencyValue originalPaymentFrequency;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomeSourcePickerState();
}

class _IncomeSourcePickerState extends ConsumerState<PaymentFrequencyPicker> {
  late int selectedFrequencyNumber;
  late PaymentFrequencyIntervalUnit selectedIntervalUnit;

  final List<PaymentFrequencyIntervalUnit> items = [
    PaymentFrequencyIntervalUnit.month,
    PaymentFrequencyIntervalUnit.year,
  ];

  @override
  void initState() {
    super.initState();
    selectedFrequencyNumber = widget.originalPaymentFrequency.intervalNumber;
    selectedIntervalUnit = widget.originalPaymentFrequency.intervalUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // タイトル
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '支払い頻度を設定',
              style: MyFonts.dialogTitle,
              textAlign: TextAlign.center,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 支払い頻度の間隔
              DropdownMenu<int>(
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textStyle: RegisterPageStyles.pickerLargeNumber,
                trailingIcon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: MyColors.secondaryLabel,
                ),
                width: 70,
                initialSelection: selectedFrequencyNumber,
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      selectedFrequencyNumber = value;
                    });
                  }
                },
                dropdownMenuEntries: List.generate(
                    11,
                    (i) => DropdownMenuEntry(
                        value: i + 1, label: (i + 1).toString())),
              ),

              // 支払い頻度の単位
              DropdownMenu<PaymentFrequencyIntervalUnit>(
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textStyle: RegisterPageStyles.pickerMediumText,
                trailingIcon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: MyColors.secondaryLabel,
                ),
                width: 80,
                initialSelection: selectedIntervalUnit,
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      selectedIntervalUnit = value;
                    });
                  }
                },
                dropdownMenuEntries: items
                    .map((item) => DropdownMenuEntry(
                        value: item, label: item.japaneseName))
                    .toList(),
              ),
              const Text("に1回"),
            ],
          ),

          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              // キャンセルボタン
              TextButton(
                // キャンセルボタンを押した時の処理
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.buttonSecondary,
                ),
                child: Text(
                  'キャンセル',
                  style: MyFonts.secondaryButtonText,
                ),
              ),

              // OKボタン
              MainButton(
                buttonType: ButtonColorType.main,
                buttonText: 'OK',
                // OKボタンを押した時の処理
                onPressed: () {
                  ref
                      .read(paymentFrequencyControllerNotifierProvider.notifier)
                      .setData(PaymentFrequencyValue.fromDB(
                        intervalNumber: selectedFrequencyNumber,
                        intervalUnitNumber:
                            selectedIntervalUnit.inturvalUnitNumber,
                      ));

                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
