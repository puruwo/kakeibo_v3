import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/batch/batch_history_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/monthly_page/monthly_page.dart';
import 'package:kakeibo/view/year_page/year_page.dart';
import 'package:kakeibo/view_model/state/navigation_bar_number.dart';
import 'package:kakeibo/view_model/state/initial_open.dart';

class Foundation extends ConsumerStatefulWidget {
  const Foundation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FoundationState();
}

class _FoundationState extends ConsumerState<Foundation> {
  // 各タブごとの Navigator にアクセスするための GlobalKey
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  //navigationBarに設定するbodyのpageリスト
  final List<Widget> pageList = [
    const YearPage(),
    Container(), // 2番目のタブは入力画面を表示するための空のコンテナ
    const MonthlyPage(),
    const ExpenseHistoryPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onBuildComplete(context, ref);

      _showExpenseEntrySheet(context); // 起動時に入力画面を表示する
    });
  }

  @override
  Widget build(BuildContext context) {
    //navigationBarの状態管理
    final navigationBarState = ref.watch(navigationBarNumberNotifierProvider);

    return Scaffold(
      // IndexedStack によって、各タブの Navigator を保持
      body: IndexedStack(
        index: ref.watch(navigationBarNumberNotifierProvider),
        children: [
          Navigator(
            key: navigatorKeys[0],
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (_) => pageList[0],
              );
            },
          ),
          Container(), // 2番目のタブは入力画面を表示するための空のコンテナ
          Navigator(
            key: navigatorKeys[2],
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (_) => pageList[2],
              );
            },
          ),
          Navigator(
            key: navigatorKeys[3],
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (_) => pageList[3],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: MyColors.themeSecondaryColor,
        backgroundColor: MyColors.quarternarySystemfill,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'ホーム'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
              ),
              label: '入力'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph_rounded), label: '分析'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: '履歴'),
        ],
        currentIndex: navigationBarState,
        onTap: (int index) {
          _selectTab(index, ref);
        },
      ),
    );
  }

  // タブがタップされたときの処理
  void _selectTab(int index, WidgetRef ref) {
    // 1をタップしたときは、入力画面を表示する
    if (index == 1) {
      _showExpenseEntrySheet(ref.context);
    }
    // それ以外のタブがタップされた場合
    else {
      // 同じタブが再タップされた場合は、Navigatorを初期状態までポップしてリセットする
      if (index == ref.read(navigationBarNumberNotifierProvider)) {
        // 同じタブが再タップされた場合、タブ内の Navigator を初期状態までポップしてリセットする
        navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      } else {
        final notifier = ref.read(navigationBarNumberNotifierProvider.notifier);
        notifier.updateState(index);
      }
    }
  }
}

void _onBuildComplete(BuildContext context, WidgetRef ref) async {
  final isInitialOpen = ref.read(initialOpenNotifierProvider);
  if (isInitialOpen == false) return;
  // 月の変わり目にバッチ処理を実行
  final result =
      await ref.read(batchProcessUsecaseProvider).grobalBatchProscessing();
  print('バッチ処理の結果: $result');

  //状態を更新
  final initialOpenNotifier = ref.read(initialOpenNotifierProvider.notifier);
  initialOpenNotifier.updateState();
}

void _showExpenseEntrySheet(BuildContext context) {
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
          child: const RegisaterPageBase.addExpense(
              transactionMode: TransactionMode.expense),
        ),
      );
    },
  );
}
