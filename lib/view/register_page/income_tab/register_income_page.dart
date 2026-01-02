import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/common_input_field/date_memo_row.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/price_input_row.dart';
import 'package:kakeibo/view/register_page/submit_button.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class RegisterIncomePage extends ConsumerStatefulWidget {
  final RegisterScreenMode mode;
  final IncomeEntity? incomeEntity;

  /// タブが見えるかどうか
  final bool isTabVisible;

  const RegisterIncomePage({
    this.mode = RegisterScreenMode.add,
    this.incomeEntity,
    required this.isTabVisible,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisterIncomePageState();
}

class _RegisterIncomePageState extends ConsumerState<RegisterIncomePage> {
  late IncomeEntity initialIncomeData;

  @override
  void initState() {
    initialIncomeData = widget.incomeEntity ??
        IncomeEntity(
          date: DateFormat('yyyyMMdd')
              .format(ref.read(systemDatetimeNotifierProvider)),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(registerScreenModeNotifierProvider.notifier)
          .setData(widget.mode);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final leftsidePadding = 16.0 * context.screenHorizontalMagnification;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 上部：支出ピル + 大きな金額表示
                PriceInputRow(
                  mode: widget.mode,
                  originalPrice: initialIncomeData.price,
                ),

                const SizedBox(height: 32),

                // 日付+メモ行
                DateMemoRow(
                  originalDate: initialIncomeData.date,
                  originalMemo: initialIncomeData.memo,
                ),

                const SizedBox(height: 24),

                // カテゴリー選択エリア
                Center(
                  child: CategoryArea(
                    transactionMode: TransactionMode.income,
                    originalCategoryId: initialIncomeData.categoryId,
                    showRearrangeLink: true,
                  ),
                ),

                // 完了ボタン用のスペース
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        // 固定フッターの完了ボタン
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SubmitButton(
              transactionMode: TransactionMode.income,
              originalIncomeEntity: initialIncomeData,
            ),
          ),
        ),
      ),
    );
  }
}
