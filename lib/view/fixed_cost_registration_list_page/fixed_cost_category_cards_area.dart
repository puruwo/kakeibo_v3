import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/fixed_cost_registration_list_value/fixed_cost_registration_list_entity.dart';
import 'package:kakeibo/view/fixed_cost_registration_list_page/fixed_cost_item_tile.dart';

class FixedCostCategoryCardsArea extends StatelessWidget {
  const FixedCostCategoryCardsArea({
    super.key,
    required this.group,
  });

  final FixedCostCategoryGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリーヘッダー（アイコン + 名前）
          Padding(
            padding: const EdgeInsets.only( bottom: 8),
            child: Row(
              children: [
                // カテゴリーアイコン
                SvgPicture.asset(
                  group.categoryIconPath,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    MyColors().getColorFromHex(group.categoryColorCode),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                // カテゴリー名
                Text(
                  group.categoryName,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: MyColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 固定費アイテムのリスト
          Column(
            children: [
              for (int i = 0; i < group.items.length; i++) ...[
                FixedCostItemTile(item: group.items[i]),
                if (i < group.items.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
