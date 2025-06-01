/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/bonus_home_page/bonus_expense_list_area/bonus_expense_list_area.dart';

class BonusHomePage extends ConsumerStatefulWidget {
  const BonusHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BonusHomePage();
}

class _BonusHomePage extends ConsumerState<BonusHomePage> {
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
              'ボーナス利用状況',
              style: MyFonts.pageHeaderText,
            ),
          ),

          // 本体
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: const SingleChildScrollView(
              child: Column(
                children: [
                  BonusExpenseListArea(),
                ],
              ),
            ),
          )),
    );
  }
}
