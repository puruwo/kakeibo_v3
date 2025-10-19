import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';

class ConfirmedFixedCostTile extends ConsumerWidget {
  const ConfirmedFixedCostTile({
    super.key,
    required this.value,
  });

  final MonthlyConfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    final drawableWidth = context.screenWidth - 64; // 左右のpaddingを引いた幅

    const leftColumnRatio = 0.43; // 左のカラムの比率
    const rightColumnRatio = 0.45; // 右のカラムの比率

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    // カテゴリーの色を取得
    final color = MyColors().getColorFromHex(value.colorCode);

    // 支払い日のフォーマット
    final paymentDateLabel =
        '${value.date.year}/${value.date.month}/${value.date.day}';

    // アイコン
    final icon = FittedBox(
      fit: BoxFit.scaleDown,
      child: SvgPicture.asset(
        value.resourcePath,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        semanticsLabel: 'categoryIcon',
        width: 25,
        height: 25,
      ),
    );
    // 値段ラベル
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppInkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: MyColors.quarternarySystemfill,
        onTap: () async {
          // showModalBottomSheet(
          //   //sccafoldの上に出すか
          //   useRootNavigator: true,
          //   isScrollControlled: true,
          //   useSafeArea: true,
          //   constraints: const BoxConstraints(
          //     maxWidth: 2000,
          //   ),
          //   context: context,
          //   // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
          //   builder: (context) {
          //     IncomeEntity incomeEntity = IncomeEntity(
          //       id: value.id,
          //       date: DateFormat('yyyyMMdd').format(value.date),
          //       price: value.price,
          //       categoryId: value.paymentCategoryId,
          //       memo: value.name,
          //     );

          //     return MaterialApp(
          //       debugShowCheckedModeBanner: false,
          //       theme: ThemeData.dark(),
          //       themeMode: ThemeMode.dark,
          //       darkTheme: ThemeData.dark(),
          //       home: MediaQuery.withClampedTextScaling(
          //         // テキストサイズの制御
          //         minScaleFactor: 0.7,
          //         maxScaleFactor: 0.95,
          //         child: RegisterIncomePage(
          //           incomeEntity: incomeEntity,
          //           mode: RegisterScreenMode.edit,
          //           isTabVisible: true,
          //         ),
          //       ),
          //     );
          //   },
          // );
        },
        onLongPress: () async {
          return await showCustomListDialog(context, actions: [
            DialogActionItem(
                label: '削除',
                onPressed: () async {
                  if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  showDeleteConfirmationDialog(
                    context,
                    onConfirm: () {
                      ref.read(expenseUsecaseProvider).delete(id: value.id);
                    },
                  );
                }),
          ]);
        },
        child: Padding(
          padding:
              EdgeInsets.only(left: leftsidePadding, right: leftsidePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // アイコン
                  Row(
                    children: [
                      SizedBox(height: 49, child: icon),
                      // アイコンの横のスペース
                      const SizedBox(
                        width: 8,
                      ),
                      // 名前
                      SizedBox(
                        width: 70 * screenHorizontalMagnification,
                        child: Text(value.name,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: MyFonts.cardPrimaryTitle),
                      ),
                    ],
                  ),
                  // 値段
                  SizedBox(
                    width: 125,
                    child: Text(
                      priceLabel,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: MyFonts.cardPriceLabel,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左列
                  SizedBox(
                    width: drawableWidth * leftColumnRatio,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 大カテゴリー名
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'カテゴリー',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: MyFonts.cardSecondaryTitle,
                              ),
                              // 小カテゴリー名
                              Text(
                                value.categoryName,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                style: MyFonts.cardSecondaryTitle,
                              ),
                            ]),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    ),
                  ),
                  // 右列
                  SizedBox(
                    width: drawableWidth * rightColumnRatio,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 大カテゴリー名
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '頻度',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: MyFonts.cardSecondaryTitle,
                              ),
                              // 小カテゴリー名
                              Text(
                                value.frequencyLabel,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                style: MyFonts.cardSecondaryTitle,
                              ),
                            ]),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '支払い日',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: MyFonts.cardSecondaryTitle,
                            ),
                            // 小カテゴリー名
                            Text(
                              paymentDateLabel,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: MyFonts.cardSecondaryTitle,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
