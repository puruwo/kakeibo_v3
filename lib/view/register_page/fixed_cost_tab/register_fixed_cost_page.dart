import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
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

  const RegisterFixedCostPage({
    this.mode = RegisterScreenMode.add,
    this.fixedCostEntity,
    required this.isAppBarVisible,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisterFixedCostPageState();
}

class _RegisterFixedCostPageState extends ConsumerState<RegisterFixedCostPage> {
  late FixedCostEntity initialFixedData;

  @override
  void initState() {
    initialFixedData = widget.fixedCostEntity ??
        FixedCostEntity(
          name: '',
          variable: 0,
          price: 0,
          fixedCostCategoryId: 0,
          intervalNumber: 1,
          intervalUnit: 1, // 月
          firstPaymentDate: DateFormat('yyyyMMdd')
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 支払い金額入力（変動スイッチ付き）
                FixedCostPriceInputArea(
                  initialFixedData: initialFixedData,
                ),

                const SizedBox(height: 8),

                // 名称入力
                // メモセクション（MemoInputFieldを流用）
                Row(
                  children: [
                    Expanded(
                      child: MemoInputField(
                        originalMemo: initialFixedData.name,
                        showIcon: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 支払い頻度（追加モードのみ）
                if (widget.mode == RegisterScreenMode.add)
                  PaymentFrequencyInputArea(
                    initialFixedData: initialFixedData,
                  ),

                const SizedBox(height: 24),

                // カテゴリー選択エリア
                Center(
                  child: CategoryArea(
                    transactionMode: TransactionMode.fixedCost,
                    originalCategoryId: initialFixedData.fixedCostCategoryId,
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
              transactionMode: TransactionMode.fixedCost,
              originalFixedCostEntity: initialFixedData,
            ),
          ),
        ),
      ),
    );
  }
}
