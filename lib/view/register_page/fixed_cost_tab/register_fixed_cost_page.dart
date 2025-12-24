import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/common_input_field/memo_input_field.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/price_input_area/fixed_cost_price_input_area.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_input_area.dart';
import 'package:kakeibo/view/register_page/submit_button.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class RegisterFixedCostPage extends ConsumerStatefulWidget {
  final RegisterScreenMode mode;

  final FixedCostEntity? fixedCostEntity;

  final bool isAppBarVisible;

  const RegisterFixedCostPage(
      {this.mode = RegisterScreenMode.add,
      this.fixedCostEntity,
      required this.isAppBarVisible,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisterExpensePageState();
}

class _RegisterExpensePageState extends ConsumerState<RegisterFixedCostPage> {
  late FixedCostEntity initialFixedData;

  @override
  void initState() {
    // entityを受け取っていなければ初期データで宣言、受け取っていればそれを宣言
    initialFixedData = widget.fixedCostEntity ??
        FixedCostEntity(
          name: '',
          variable: 0,
          price: 0,
          fixedCostCategoryId: 0,
          intervalNumber: 1,
          intervalUnit: 1, // 月
          firstPaymentDate: DateFormat('yyyyMMdd').format(DateTime.now()),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 編集モードか？
      ref
          .read(registerScreenModeNotifierProvider.notifier)
          .setData(widget.mode);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    //レイアウト------------------------------------------------------------------------------------

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
          backgroundColor: MyColors.secondarySystemBackground,
          appBar: widget.isAppBarVisible
              ? AppBar(
                  // ヘッダーの色
                  backgroundColor: MyColors.secondarySystemBackground,

                  // ヘッダーの形
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  title: SizedBox(
                    child: Text(
                      widget.mode == RegisterScreenMode.add
                          ? '固定費を設定'
                          : '固定費を編集する',
                      style: MyFonts.regesterHeaderLabel,
                    ),
                  ),

                  //ヘッダーの左ボタン
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    icon: const Icon(
                      //バッテン
                      Icons.close_rounded,
                      color: MyColors.white,
                    ),
                  ),
                )
              : null,

          //body
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(leftsidePadding),
                child: Column(
                  children: [
                    const SizedBox(height: 5),

                    MemoInputField(
                        originalMemo: initialFixedData.name, titleLabel: "名称"),

                    const SizedBox(height: 8),

                    FixedCostPriceInputArea(
                      initialFixedData: initialFixedData,
                    ),

                    const SizedBox(height: 8),

                    widget.mode == RegisterScreenMode.add
                        ? PaymentFrequencyInputArea(
                            initialFixedData: initialFixedData,
                          )
                        : Container(),

                    const SizedBox(height: 16),

                    // カテゴリー選択エリア
                    CategoryArea(
                        transactionMode: TransactionMode.fixedCost,
                        originalCategoryId:
                            initialFixedData.fixedCostCategoryId),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SubmitButton(
                transactionMode: TransactionMode.fixedCost,
                originalFixedCostEntity: initialFixedData),
          )),
    );
  }
}
