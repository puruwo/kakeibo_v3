import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// 日次支出サマリーページ（仮実装）
/// DateTimeを表示するだけのシンプルなページ
class DailyExpenseSummaryPage extends StatelessWidget {
  const DailyExpenseSummaryPage({super.key, required this.date});

  final DateTime date;

  static Route<void> route(DateTime date) {
    return MaterialPageRoute(
      builder: (context) => DailyExpenseSummaryPage(date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.systemBackground,
      appBar: AppBar(
        title: const Text('支出情報'),
        backgroundColor: MyColors.systemBackground,
        foregroundColor: MyColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.year}年${date.month}月${date.day}日',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MyColors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '(仮実装ページ)',
              style: TextStyle(
                fontSize: 14,
                color: MyColors.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
