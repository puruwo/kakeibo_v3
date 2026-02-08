import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/batch/batch_history_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/view/component/modal.dart';
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

class _FoundationState extends ConsumerState<Foundation>
    with SingleTickerProviderStateMixin {
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

  // フェードインアニメーション用のコントローラー
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.value = 1.0; // 初期状態では完全に表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onBuildComplete(context, ref);
      _showExpenseEntrySheet(context); // 起動時に入力画面を表示する
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //navigationBarの状態管理
    final navigationBarState = ref.watch(navigationBarNumberNotifierProvider);

    return Scaffold(
      extendBody: true,
      // IndexedStack によって、各タブの Navigator を保持
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
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
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: MyColors.themeSecondaryColor,
            backgroundColor:
                MyColors.secondarySystemBackground.withOpacity(0.7),
            elevation: 0,
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
        ),
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
        // タブ切り替え前にopacityを0にする（ちらつき防止）
        _fadeController.value = 0.0;
        // タブを切り替える
        final notifier = ref.read(navigationBarNumberNotifierProvider.notifier);
        notifier.updateState(index);
        // フェードインアニメーションを開始
        _fadeController.forward();
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
  showAppModalBottomSheet(
    context,
    child: const RegisaterPageBase.addExpense(
      transactionMode: TransactionMode.expense,
    ),
  );
}
