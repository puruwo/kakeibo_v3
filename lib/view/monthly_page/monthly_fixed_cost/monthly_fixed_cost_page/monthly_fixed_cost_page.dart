import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/confirmed_fixed_cost_area/confirmed_fixed_cost_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/fixed_cost_header/fixed_cost_header.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/unconfirmed_fixed_cost_area/unconfirmed_fixed_cost_area.dart';

class MonthlyFixedCostPage extends ConsumerWidget {
  const MonthlyFixedCostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          '固定費',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ヘッダー
            const FixedCostHeader(),

            // リスト部分
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 確定済み固定費リストヘッダー
                    SizedBox(
                      width: 343 * context.screenHorizontalMagnification,
                      height: 35,
                      child: Text(
                        ' 確定分',
                        style: MyFonts.thirdPageSubheading,
                      ),
                    ),

                    // 確定済み固定費リスト
                    const ConfirmedFixedCostListArea(),

                    const SizedBox(height: 16.0),

                    // 未確定固定費リストヘッダー
                    SizedBox(
                      width: 343 * context.screenHorizontalMagnification,
                      height: 35,
                      child: Text(
                        ' 未確定分',
                        style: MyFonts.thirdPageSubheading,
                      ),
                    ),
                    // 未確定固定費リスト
                    const UnconfirmedFixedCostListArea(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
