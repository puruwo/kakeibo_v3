/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/big_category_edit_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/big_category_list_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/big_category_setting_footer.dart';
import 'package:kakeibo/view/component/app_component.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/editting_big_category_list/editting_big_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/is_big_category_list_edited/is_big_category_list_edited.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_edit_page/editting_fixed_cost_category_list/editting_fixed_cost_category_list.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_edit_page/is_fixed_cost_category_list_edited/is_fixed_cost_category_list_edited.dart';
import 'package:kakeibo/view_model/state/category_edit_page/edit_mode.dart';

// カテゴリータイプのEnum
enum CategoryType {
  expense, // 一般（支出）
  fixedCost, // 固定費
}

class CategorySettingPage extends ConsumerStatefulWidget {
  const CategorySettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategorySettingPageState();
}

class _BigCategorySettingPageState extends ConsumerState<CategorySettingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editmodeProvider = ref.watch(editModeNotifierProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,
        // ヘッダー
        appBar: AppBar(
          backgroundColor: MyColors.secondarySystemBackground,
          title: Text(
            'カテゴリー設定',
            style: MyFonts.pageHeaderText,
          ),

          //ヘッダー左のアイコンボタン
          leading: IconButton(
            // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
            onPressed: () {
              final isEditMode = ref.read(editModeNotifierProvider);
              if (isEditMode) {
                // 編集モードなら、providerを破棄して状態を非編集モードに変更
                ref.invalidate(isBigCategoryListEditedNotifierProvider);
                ref.invalidate(edittingBigCategoryListNotifierProvider);
                ref.invalidate(isFixedCostCategoryListEditedNotifierProvider);
                ref.invalidate(edittingFixedCostCategoryListNotifierProvider);
                ref.read(editModeNotifierProvider.notifier).updateState();
              } else {
                // 非編集モード時は閉じる
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            icon: const Icon(Icons.close, color: MyColors.white),
          ),

          // タブバー
          bottom: AppTab(
            tabController: _tabController,
            tabs: const [
              Tab(text: '一般'),
              Tab(text: '固定費'),
            ],
          ),
        ),

        // 本体
        body: TabBarView(
          controller: _tabController,
          children: [
            // 一般カテゴリータブ
            _buildCategoryContent(
              categoryType: CategoryType.expense,
              editmodeProvider: editmodeProvider,
            ),

            // 固定費カテゴリータブ
            _buildCategoryContent(
              categoryType: CategoryType.fixedCost,
              editmodeProvider: editmodeProvider,
            ),
          ],
        ),
      ),
    );
  }

  // カテゴリーコンテンツを構築（共通化）
  Widget _buildCategoryContent({
    required CategoryType categoryType,
    required bool editmodeProvider,
  }) {
    return Column(
      children: [
        Expanded(
          child: editmodeProvider == false
              // 非編集時
              ? BigCategoryListArea(categoryType: categoryType)
              // 編集時
              : BigCategoryEditArea(categoryType: categoryType),
        ),
        const Divider(height: 1),

        // フッターボタンエリア
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
          child: BigCategorySettingFooter(categoryType: categoryType),
        ),
      ],
    );
  }
}
