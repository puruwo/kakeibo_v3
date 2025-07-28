import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/income_tab/income_input_area.dart';

import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/common_input_field/memo_input_field.dart';
import 'package:kakeibo/view/register_page/submit_button.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

import 'package:kakeibo/view/register_page/common_input_field/date_input_field.dart';

class RegisterIncomePage extends ConsumerStatefulWidget {
  final RegisterScreenMode mode;

  final IncomeEntity? incomeEntity;

  /// タブが見えるかどうか
  final bool isTabVisible;

  const RegisterIncomePage(
      {this.mode = RegisterScreenMode.add,
      this.incomeEntity,
      required this.isTabVisible,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisaterIncomePageState();
}

class _RegisaterIncomePageState extends ConsumerState<RegisterIncomePage> {
  late IncomeEntity initialIncomeData;

  @override
  void initState() {
    // entityを受け取っていなければ初期データで宣言、受け取っていればそれを宣言
    initialIncomeData = widget.incomeEntity ??
        IncomeEntity(
          date: DateFormat('yyyyMMdd').format(DateTime.now()),
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
          appBar: widget.isTabVisible
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
                      widget.mode == RegisterScreenMode.add ? '記録' : '記録を編集する',
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
                    SizedBox(height: 5),

                    SizedBox(height: 8),

                    IncomeInputArea(originalPrice: initialIncomeData.price),

                    SizedBox(height: 8),

                    MemoInputField(originalMemo: initialIncomeData.memo),

                    SizedBox(height: 8),

                    DateInputField(originalDate: initialIncomeData.date),

                    SizedBox(height: 16),

                    // カテゴリー選択エリア
                    CategoryArea(
                        transactionMode: TransactionMode.income,
                        originalCategoryId: initialIncomeData.categoryId),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal:16.0),
            child: SubmitButton(
                transactionMode: TransactionMode.income,
                originalIncomeEntity: initialIncomeData),
          )),
    );
  }
}
