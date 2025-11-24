import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';

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
      indicatorColor: MyColors.themeColor,
      unselectedLabelStyle: MyFonts.unselectedLabelStyle,
      labelStyle: MyFonts.selectedLabelStyle,
      indicatorWeight: 2,
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
