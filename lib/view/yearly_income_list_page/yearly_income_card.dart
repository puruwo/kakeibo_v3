import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/income/income_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class YearlyIncomeCard extends ConsumerWidget {
  const YearlyIncomeCard({
    super.key,
    required this.value,
  });

  final IncomeHistoryTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の倍率を計算
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    // カテゴリーの色を取得
    final color = MyColors().getColorFromHex(value.colorCode);

    // 値段ラベル
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppInkWell(
        borderRadius: appCardRadius,
        color: MyColors.quarternarySystemfill,
        onTap: () async {
          _showModalBottomSheet(context);
        },
        onLongPress: () async {
          return await showMenuDialog(context, items: [
            MenuDialogItem(
                label: '編集',
                icon: Icons.edit_outlined,
                onPressed: () async {
                  _showModalBottomSheet(context);
                }),
            MenuDialogItem(
                label: '削除',
                icon: Icons.delete_outline,
                onPressed: () async {
                  showDeleteConfirmationDialog(
                    context,
                    onConfirm: () {
                      ref.read(incomeUsecaseProvider).delete(id: value.id);
                    },
                  );
                }),
          ]);
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: leftsidePadding, right: leftsidePadding),
              child: SizedBox(
                height: 69,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // アイコン
                    SizedBox(
                      height: 49,
                      width: 49,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SvgPicture.asset(
                          value.iconPath,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                          semanticsLabel: 'categoryIcon',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),

                    // アイコンの横のスペース
                    const SizedBox(
                      width: 8,
                    ),

                    // カテゴリー名と日付・メモのColumn
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 小カテゴリー
                          Text(
                            value.smallCategoryName,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.listCardTitleLabel,
                          ),

                          const SizedBox(height: 4),

                          // 日付とメモ
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${value.date.month}月${value.date.day}日',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.listCardSecondaryTitle,
                              ),
                              if (value.memo.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    value.memo,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.listCardSecondaryTitle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 値段
                    Row(
                      children: [
                        SizedBox(
                          width: 125,
                          child: Text(
                            priceLabel,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.listCardPriceLabel,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '+',
                          style: AppTextStyles.listCardPlusLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      //sccafoldの上に出すか
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(
        maxWidth: 2000,
      ),
      context: context,
      // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
      builder: (context) {
        IncomeEntity incomeEntity = IncomeEntity(
          id: value.id,
          date: DateFormat('yyyyMMdd').format(value.date),
          price: value.price,
          categoryId: value.paymentCategoryId,
          memo: value.memo,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          home: MediaQuery.withClampedTextScaling(
            // テキストサイズの制御
            minScaleFactor: 0.7,
            maxScaleFactor: 0.95,
            child: RegisaterPageBase.editIncome(
              incomeEntity: incomeEntity,
            ),
          ),
        );
      },
    );
  }
}
