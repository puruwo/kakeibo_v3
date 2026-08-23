import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/price_input_row.dart';
import 'package:kakeibo/view/register_page/income_tab/income_basic_group.dart';
import 'package:kakeibo/view/register_page/submit_button.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_initialized_controller.dart';
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
      _initializeInputs();
    });

    super.initState();
  }

  /// 日付・メモの初期値をセットする
  ///
  /// 日付・メモをインセットグループ化して行Widget側の初期化が無くなったため、
  /// 支出タブと同じくページ側で1回だけ流し込む（仕様 §6.9）。
  void _initializeInputs() {
    // 追加モードで既に初期化済みの場合は、ピル切り替え時に入力値を保持するためスキップ
    final isInitialized = ref.read(inputInitializedControllerProvider);
    if (widget.mode == RegisterScreenMode.add && isInitialized) {
      return;
    }

    ref.read(enteredMemoControllerProvider).text = initialIncomeData.memo;
    ref.read(inputDateControllerNotifierProvider.notifier).setData(
          DateTime.parse(
            '${initialIncomeData.date.substring(0, 4)}-${initialIncomeData.date.substring(4, 6)}-${initialIncomeData.date.substring(6, 8)}',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final leftsidePadding = 16.0 * context.screenHorizontalMagnification;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,
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

                // 基本グループ（日付／メモ）
                const IncomeBasicGroup(),

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
