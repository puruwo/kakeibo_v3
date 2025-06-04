/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_expense_list_area/bonus_expense_list_area.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_area.dart';

class BonusHomePage extends ConsumerStatefulWidget {
  const BonusHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BonusHomePage();
}

class _BonusHomePage extends ConsumerState<BonusHomePage> {
  @override
  Widget build(BuildContext context) {

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
        body: Stack(
          children: [
            // 上部（ここに通常の内容など追加）
            const Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: BonusPlanArea(),
                )
              ],
            ),
            DraggableScrollableSheet(
                // 初期の表示割合
                initialChildSize: 0.7,
                // 最小の表示割合
                minChildSize: 0.7,
                // 最大の表示割合
                maxChildSize: 1.0,
                // ドラッグを離した時に一番近いsnapSizeになるか
                snap: true,
                // snapで止める時の割合
                snapSizes: const [0.7, 1.0],
                builder: (context, scrollController) {
                  return Container(
                    // 背景色 & 角丸
                    decoration: const BoxDecoration(
                      color: MyColors.secondarySystemBackground,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [
                        // 少し上からの影をつけると見栄えが良い
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [

                          // SingleChildScrollViewの範囲がドラッグできる範囲
                          // スクロールするにはscrollControllerを渡す必要があり、そのウィジェットに囲まれた領域だけがスクロール可能になる
                          SingleChildScrollView(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [

                                // ハンドルバー
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 4.0),
                                  child: Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),

                                // タブ
                                const TabBar(
                                  tabs: [
                                    Tab(text: 'ボーナス支出'),
                                    Tab(text: 'ボーナス収入'),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1),

                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: TabBarView(
                                children: [
                                  BonusExpenseListArea(),
                                  Center(child: Text('タブ2の内容')),
                                ],
                              ),
                            ),
                          ),

                          // フッターボタンエリア
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('カテゴリ編集・追加'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MyColors.themeColor,
                                    ),
                                    child: const Text('予算を編集する'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
