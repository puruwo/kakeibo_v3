import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';

/// 年間支出一覧ページ（準備中）
///
/// 年間収支カードの「総支出」シェブロンからの遷移先。
/// 現状はプレースホルダーで、本実装は今後対応する。
class YearlyExpenseListPage extends StatelessWidget {
  const YearlyExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '支出一覧',
          style: AppTextStyles.pageHeaderText,
        ),
      ),
      body: Center(
        child: Text(
          '準備中',
          style: AppTextStyles.listEmptyMessage,
        ),
      ),
    );
  }
}
