/// libraryImport
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/budget_setting_page/budget_cotegory_area.dart';
import 'package:kakeibo/view/budget_setting_page/submit_budget_button.dart';

class BudgetSettingPage extends ConsumerStatefulWidget {
  const BudgetSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetSettingPageState();
}

class _BudgetSettingPageState extends ConsumerState<BudgetSettingPage> {
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
          title: Text(
            '今月の予算を入力',
            style: MyFonts.pageHeaderText,
          ),

          backgroundColor: MyColors.secondarySystemBackground,
          //ヘッダー左のアイコンボタン
          leading: IconButton(
              // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              icon: const Icon(
                Icons.close,
                color: MyColors.white,
              )),

          //ヘッダー右のアイコンボタン
          actions: const [SubmitBudgetButton()],
        ),

        // 本体
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                      'カテゴリー',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '先月の支出',
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: MyColors.secondaryLabel,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 123,
                        child: Text(
                          '今月の予算',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.notoSans(
                              fontSize: 16,
                              color: MyColors.secondaryLabel,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //区切り線
            Divider(
              thickness: 0.25,
              height: 0.25,
              indent: leftsidePadding,
              endIndent: leftsidePadding,
              color: MyColors.separater,
            ),

            // リスト部分
            const BudgetCategoryArea()
          ],
        ),
      ),
    );
  }
}
