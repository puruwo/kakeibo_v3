import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/page/third_page.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:kakeibo/view_model/provider/navigation_bar.dart';
import 'package:kakeibo/view_model/provider/initial_open.dart';
import 'package:kakeibo/view_model/provider/update_DB_count.dart';

import 'package:kakeibo/view/page/torok.dart';
import 'package:kakeibo/view/page/home.dart';

class Foundation extends StatefulHookConsumerWidget {
  const Foundation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FoundationState();
}

class _FoundationState extends ConsumerState<Foundation> {
  @override
  Widget build(BuildContext context) {
    //navigationBarの状態管理
    final navigationBarState = ref.watch(navigationBarNotifierProvider);

    //アプリを開いた時か判定
    //開いた時なら登録画面を表示
    ref.listen(initialOpenNotifierProvider, (oldState, newState) {
      //なんもしやん
    });

    final isInitialOpen = ref.read(initialOpenNotifierProvider);

    //WidgetsBindingで囲むことで、ビルドが終わったタイミングで中の処理が走る
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isInitialOpen == true) {
        showModalBottomSheet(
          //sccafoldの上に出すか
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          constraints: const BoxConstraints(
            maxWidth: 2000,
          ),
          context: context,
          // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
          builder: (context) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark(),
              themeMode: ThemeMode.dark,
              darkTheme: ThemeData.dark(),
              home: MediaQuery.withClampedTextScaling(
                // テキストサイズの制御
                minScaleFactor: 0.7,
                maxScaleFactor: 0.95,
                child: Torok(),
              ),
            );
          },
        );

        final notifier = ref.read(initialOpenNotifierProvider.notifier);
        notifier.updateState();
      }
    });

    //navigationBarに設定するbodyのpageリスト
    List<Widget> pageList = [const Home(), const Third()];

    return Scaffold(
      body: MaterialApp(
        home: pageList[navigationBarState],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.blackmint,
        onPressed: () {
          showModalBottomSheet(
            //sccafoldの上に出すか
            useRootNavigator: true,
            isScrollControlled: true,
            useSafeArea: true,
            constraints: const BoxConstraints(
              maxWidth: 2000,
            ),
            context: context,
            // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
            builder: (context) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData.dark(),
                themeMode: ThemeMode.dark,
                darkTheme: ThemeData.dark(),
                home: MediaQuery.withClampedTextScaling(
                  // テキストサイズの制御
                  minScaleFactor: 0.7,
                  maxScaleFactor: 0.95,
                  child: Torok(),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MyColors.quarternarySystemfill,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: '履歴'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph_rounded), label: 'グラフ')
        ],
        currentIndex: navigationBarState,
        onTap: (int index) {
          // watchで取ってきたステート(viewのstate)にタップされた引数(index)番目のViewTypeを代入する
          final notifier = ref.read(navigationBarNotifierProvider.notifier);
          notifier.updateState(index);
        },
      ),
    );
  }
}
