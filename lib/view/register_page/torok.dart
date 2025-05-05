import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/input_molecule/expense_input_area/expense_input_area.dart';
import 'package:kakeibo/view/register_page/input_molecule/memo_input_field.dart';
import 'package:kakeibo/view/register_page/submit_expense_button.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';
import 'package:kakeibo/view_model/state/register_page/original_expense_entity/original_expense_entity.dart';

import 'package:kakeibo/view/register_page/input_molecule/date_input_field.dart';

class Torok extends ConsumerStatefulWidget {
  final RegisterScreenMode mode;

  final ExpenseEntity? expenseEntity;

  const Torok(
      {this.mode = RegisterScreenMode.add, this.expenseEntity, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TorokState();
}

class _TorokState extends ConsumerState<Torok> {
  late ExpenseEntity initialExpenseData;

  @override
  void initState() {
    // entityを受け取っていなければ初期データで宣言、受け取っていればそれを宣言
    initialExpenseData = widget.expenseEntity ??
        ExpenseEntity(
          date: DateFormat('yyyyMMdd').format(DateTime.now()),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // entityをproviderで管理し、各パーツからのアクセスを可能にする
      ref
          .read(originalExpenseEntityNotifierProvider.notifier)
          .setData(initialExpenseData);

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

        appBar: AppBar(
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

          //ヘッダー右のアイコンボタン
          actions: const [SubmitExpenseButton()],

          //ヘッダーの左ボタン
          leading: IconButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: const Icon(
              //バッテン
              Icons.close_rounded,
              color: MyColors.white,
            ),
          ),
        ),

        //body
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(leftsidePadding),
              child: const Column(
                children: [
                  SizedBox(height: 5),

                  SizedBox(height: 8),

                  ExpenseInputArea(),

                  SizedBox(height: 8),

                  MemoInputField(),

                  SizedBox(height: 8),

                  DateInputField(),

                  SizedBox(height: 16),

                  // カテゴリー選択エリア
                  CategoryArea(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
