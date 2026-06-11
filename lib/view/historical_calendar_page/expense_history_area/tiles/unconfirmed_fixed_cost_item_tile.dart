import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/common_widget/price_input_dialog.dart';

class UnconfirmedFixedCostItemTile extends ConsumerWidget {
  const UnconfirmedFixedCostItemTile({
    super.key,
    required this.value,
    required this.leftsidePadding,
    required this.screenHorizontalMagnification,
  });

  final MonthlyUnconfirmedFixedCostTileValue value;
  final double leftsidePadding;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedCostExpenseUsecase = ref.read(fixedCostExpenseUsecaseProvider);
    final color = ColorCode.toColor(value.colorCode);

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

    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        showPriceInputDialog(context, value);
      },
      child: Dismissible(
        direction: DismissDirection.endToStart,
        key: Key(value.id.toString()),
        dragStartBehavior: DragStartBehavior.start,
        background: Container(color: MyColors.black),
        secondaryBackground: Container(
          color: context.colors.expense,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 18.0),
              child: Icon(Icons.delete, color: context.colors.icon),
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDeleteConfirmationDialog(context);
          }
          return null;
        },
        onDismissed: (direction) {
          fixedCostExpenseUsecase.delete(id: value.id);
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: leftsidePadding,
                right: leftsidePadding,
              ),
              child: SizedBox(
                height: 49,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // アイコン
                    SizedBox(height: 49, width: 49, child: icon),

                    // 固定費名
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 固定費名
                          SizedBox(
                            width: 153 * screenHorizontalMagnification,
                            child: Text(
                              value.name,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.listTilePrimaryTitle,
                            ),
                          ),
                          // 固定費（未確定）ラベル
                          SizedBox(
                            width: 153 * screenHorizontalMagnification,
                            child: Text(
                              '固定費(未確定)',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.listTileTirtiaryTitle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 値段
                    Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          '未確定',
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.listTileUnconfirmedPriceLabel,
                        ),
                      ),
                    ),

                    // nextArrowアイコン
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(size: 18, Icons.remove, color: context.colors.expense),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 0.25,
              height: 0.25,
              indent: 50 + leftsidePadding,
              endIndent: leftsidePadding,
              color: context.colors.separator,
            ),
          ],
        ),
      ),
    );
  }
}
