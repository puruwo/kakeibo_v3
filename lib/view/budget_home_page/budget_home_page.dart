/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/budget_home_page/income_list_area/income_list_area.dart';

class BudgetHomePage extends ConsumerStatefulWidget {
  const BudgetHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BudgetHomePage();
}

class _BudgetHomePage extends ConsumerState<BudgetHomePage> {
  @override
  Widget build(BuildContext context) {
    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
          backgroundColor: MyColors.secondarySystemBackground,
          // ヘッダー
          appBar: AppBar(
            backgroundColor: MyColors.secondarySystemBackground,
            title: Text(
              '毎月の予算',
              style: MyFonts.pageHeaderText,
            ),
          ),

          // 本体
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: SingleChildScrollView(
              child: const Column(
                children: [
                  IncomeListArea(),
                ],
              ),
            ),
          )),
    );
  }
}
