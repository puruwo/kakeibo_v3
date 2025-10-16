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
import 'package:kakeibo/view/register_page/income_tab/register_income_page.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class IncomeHistoryTile extends ConsumerWidget {
  const IncomeHistoryTile({
    super.key,
    required this.value,
  });

  final IncomeHistoryTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

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
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      color: MyColors.quarternarySystemfill,
      onTap: () async {
        _showModalBottomSheet(context);
      },
      onLongPress: () async {
        return await showCustomListDialog(context, actions: [
          DialogActionItem(
              label: '編集',
              onPressed: () async {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                _showModalBottomSheet(context);
              }),
          DialogActionItem(
              label: '削除',
              onPressed: () async {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                showDeleteConfirmationDialog(
                  context,
                  onConfirm: () {
                    ref.read(incomeUsecaseProvider).delete(id: value.id);
                  },
                );
              }),
        ]);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
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
                    SizedBox(height: 49, child: icon),

                    // アイコンの横のスペース
                    const SizedBox(
                      width: 8,
                    ),

                    // 大カテゴリー、小カテゴリーのColumn
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 大カテゴリーとメモ
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              SizedBox(
                                width: 70 * screenHorizontalMagnification,
                                child: Text(value.bigCategoryName,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: MyFonts.cardPrimaryTitle),
                              ),
                              SizedBox(
                                width: 75 * screenHorizontalMagnification,
                                child: Text(' ${value.memo}',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: MyFonts.cardPrimaryTitle),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          // 小カテゴリーと日付
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 75 * screenHorizontalMagnification,
                                child: Text(
                                  value.smallCategoryName,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: MyFonts.cardSecondaryTitle,
                                ),
                              ),
                              SizedBox(
                                width: 73 * screenHorizontalMagnification,
                                child: Text(
                                  '${value.date.month}月${value.date.day}日',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: MyFonts.cardSecondaryTitle,
                                ),
                              ),
                            ],
                          )
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
                            style: MyFonts.cardPriceLabel,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '+',
                          style: MyFonts.cardPlusLabel,
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
            child: RegisterIncomePage(
              incomeEntity: incomeEntity,
              mode: RegisterScreenMode.edit,
              isTabVisible: true,
            ),
          ),
        );
      },
    );
  }
}
