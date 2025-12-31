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
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class IncomeItemTile extends ConsumerWidget {
  const IncomeItemTile({
    super.key,
    required this.value,
    required this.leftsidePadding,
    required this.screenHorizontalMagnification,
  });

  final IncomeHistoryTileValue value;
  final double leftsidePadding;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // アイコン
    final icon = FittedBox(
      fit: BoxFit.scaleDown,
      child: SvgPicture.asset(
        value.iconPath,
        semanticsLabel: 'categoryIcon',
        width: 25,
        height: 25,
      ),
    );
    // 値段ラベル
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
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
            padding:
                EdgeInsets.only(left: leftsidePadding, right: leftsidePadding),
            child: SizedBox(
              height: 49,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // アイコン
                  SizedBox(height: 49, width: 49, child: icon),

                  // 大カテゴリー、小カテゴリーのColumn
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 大カテゴリー
                        SizedBox(
                          width: 153 * screenHorizontalMagnification,
                          child: Text(
                            value.bigCategoryName,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style:
                                HistoryListStyles.historyTileBigCategoryLabel,
                          ),
                        ),

                        // 小カテゴリーとメモ
                        Row(
                          children: [
                            // 小カテゴリー
                            SizedBox(
                              width: 56,
                              child: Text(
                                ' ${value.smallCategoryName}',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: HistoryListStyles.historyTileSubLabel,
                              ),
                            ),
                            // メモ
                            SizedBox(
                              width: 90 * screenHorizontalMagnification,
                              child: Text(
                                ' ${value.memo}',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: MyColors.secondaryLabel),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  // 値段
                  Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            priceLabel,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style:
                                HistoryListStyles.historyTileIncomePriceLabel,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // nextArrowアイコン
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      size: 18,
                      Icons.add,
                      color: MyColors.mintBlue,
                    ),
                  )
                ],
              ),
            ),
          ),
          Divider(
            thickness: 0.25,
            height: 0.25,
            indent: 50 + leftsidePadding,
            endIndent: leftsidePadding,
            color: MyColors.separater,
          )
        ],
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(
        maxWidth: 2000,
      ),
      context: context,
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
