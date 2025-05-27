import 'package:intl/date_symbol_data_local.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/constant/properties.dart';
// DateTimeの日本語対応
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/view/monthly_page/expense_history_digest_area/expense_history_digest_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_expense_history_value_provider.dart';

class ExpenceHistoryDigestArea extends ConsumerStatefulWidget {
  const ExpenceHistoryDigestArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenceHistoryDigestAreaState();
}

class _ExpenceHistoryDigestAreaState
    extends ConsumerState<ExpenceHistoryDigestArea> {
  List<DateTime> itemKeys = [];

  @override
  Widget build(BuildContext context) {

    // DateTimeの日本語対応
    initializeDateFormatting();

//状態管理---------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------

    return ref.watch(resolvedExpenseHistoryDigestValueProvider).when(
        data: (allItems) {
      final headFiveitems = allItems.take(5).toList();
      if (headFiveitems.isNotEmpty) {
        return Column(
            children: List.generate(headFiveitems.length, (index) {
          return ExpenseHistoryDigestTile(
            tileValue: headFiveitems[index],
          );
        }));
      } else {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                '記録がまだありません',
                style: TextStyle(color: MyColors.secondaryLabel, fontSize: 16),
              ),
            ),
          ],
        );
      }
    }, error: (error, stackTrace) {
      return const Center(
        child: Text('データの取得に失敗しました'),
      );
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }

  double listSmallcategoryMemoOffsetGetter(double screenWidthSize) {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return screenWidthSize - defaultWidth;
  }
}
