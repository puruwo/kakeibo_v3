import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';

class AppTab extends StatelessWidget implements PreferredSizeWidget {
  const AppTab({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  final TabController tabController;
  final List<Tab> tabs;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: context.colors.primary,
      unselectedLabelStyle: AppTextStyles.unselectedLabelStyle,
      labelStyle: AppTextStyles.selectedLabelStyle,
      indicatorWeight: 2,
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
