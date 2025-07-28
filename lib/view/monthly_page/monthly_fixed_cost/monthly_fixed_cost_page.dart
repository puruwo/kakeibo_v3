import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/confirmed_fixed_cost_area/confirmed_fixed_cost_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/unconfirmed_fixed_cost_area/unconfirmed_fixed_cost_area.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 343 * context.screenHorizontalMagnification,
            height: 35,
            child: Text(
              ' 確定分',
              style: MyFonts.thirdPageSubheading,
            ),
          ),
          const ConfirmedFixedCostListArea(),

          const SizedBox(height: 16.0),

          SizedBox(
            width: 343 * context.screenHorizontalMagnification,
            height: 35,
            child: Text(
              ' 未確定分',
              style: MyFonts.thirdPageSubheading,
            ),
          ),
          const UnconfirmedFixedCostListArea(),
        ]),
      ),
    );
  }
}
