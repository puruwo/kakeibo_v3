import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';

/// 家族機能のプレースホルダー画面（未実装）
class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.systemBackground,
      appBar: AppBar(
        backgroundColor: MyColors.systemBackground,
        centerTitle: true,
        title: Text('家族', style: AppTextStyles.pageHeaderText),
      ),
      body: Center(
        child: Text('準備中', style: AppTextStyles.listEmptyMessage),
      ),
    );
  }
}
