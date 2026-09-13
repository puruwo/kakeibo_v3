// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/component/app_selection_sheet.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_icon_contoroller/big_category_icon_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_icon_controller/income_big_category_icon_controller.dart';

/// アイコンの分類セクション（案件 UIデザイン改修 §8）
class IconSection {
  const IconSection(this.title, this.assetNames);

  final String title;
  final List<String> assetNames;
}

/// 支出カテゴリー用アイコン40種（KP-023。Material Symbols Rounded・Filled の
/// `icon_*.svg`）。一般的な家計簿アプリの分類を基準に意味で分類して全提示する
const List<IconSection> expenseIconSections = [
  IconSection('食・買い物', [
    'icon_meal', // 食費
    'icon_local_cafe', // カフェ・外食
    'icon_commodity', // 日用品
    'icon_clothes', // 衣服
    'icon_content_cut', // 美容
    'icon_local_laundry_service', // クリーニング・家事
    'icon_local_atm', // 現金・ATM
    'icon_credit_card', // ローン・返済
  ]),
  IconSection('健康・趣味・交際', [
    'icon_medical', // 医療
    'icon_medication', // 薬・ドラッグストア
    'icon_fitness_center', // 健康・運動
    'icon_sports_esports', // 趣味・娯楽
    'icon_favo', // 推し・嗜好品
    'icon_movie', // 映画・音楽
    'icon_confirmation_number', // イベント・チケット
    'icon_liquor', // お酒
    'icon_groups', // 交際費
    'icon_celebration', // 冠婚葬祭
    'icon_featured_seasonal_and_gifts', // プレゼント
    'icon_handshake', // 寄付
  ]),
  IconSection('教育・移動', [
    'icon_school', // 教育
    'icon_menu_book', // 書籍
    'icon_child_care', // 子ども
    'icon_pets', // ペット
    'icon_travel', // 旅行
    'icon_transportation', // 交通
    'icon_directions_car', // 車
    'icon_local_gas_station', // ガソリン
  ]),
  IconSection('住まい・固定費', [
    'icon_home', // 住居・家賃
    'icon_chair', // 家具・家電
    'icon_bolt', // 電気
    'icon_water_drop', // 水道
    'icon_local_fire_department', // ガス
    'icon_router', // 通信
    'icon_smartphone', // スマホ
    'icon_subscription', // サブスク
    'icon_health_and_safety', // 保険
    'icon_receipt_long', // 税金
  ]),
  IconSection('その他', [
    'icon_star', // 特別支出
    'icon_others', // その他
  ]),
];

/// 収入カテゴリー用アイコン15種（KP-023）
const List<IconSection> incomeIconSections = [
  IconSection('給与・事業', [
    'icon_regular_income', // 給与
    'icon_workspace_premium', // 賞与
    'icon_extra_income', // 臨時収入
    'icon_work', // 副業
    'icon_storefront', // 事業・フリーランス
    'icon_real_estate_agent', // 家賃収入
  ]),
  IconSection('資産・その他', [
    'icon_finance', // 投資・配当
    'icon_toll', // 利息
    'icon_savings', // 貯金の取り崩し
    'icon_account_balance', // 年金
    'icon_request_quote', // 還付金・給付金
    'icon_volunteer_activism', // 仕送り・援助
    'icon_sell', // 売却・フリマ
    'icon_local_parking', // ポイント
    'icon_wallet', // その他
  ]),
];

/// カテゴリーアイコン選択シートを表示する（選択即決定）
Future<void> showIconSelectSheet(
  BuildContext context, {
  CategoryType categoryType = CategoryType.expense,
}) {
  return AppSelectionSheet.show(
    context,
    title: 'カテゴリーアイコンを選択',
    child: IconSelectDialog(categoryType: categoryType),
  );
}

/// アイコン選択シートの中身（分類セクション＋5列グリッド）
class IconSelectDialog extends ConsumerWidget {
  const IconSelectDialog({
    super.key,
    this.categoryType = CategoryType.expense,
  });

  final CategoryType categoryType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 選択中アイコンのパスを取得
    final iconPath = categoryType == CategoryType.income
        ? ref.watch(incomeBigCategoryIconControllerNotifierProvider)
        : ref.watch(bigCategroyIconControllerNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final section in (categoryType == CategoryType.income
            ? incomeIconSections
            : expenseIconSections)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
            child: Text(section.title, style: context.textStyles.insetGroupHeader),
          ),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            // 正方形セルだと縦に間延びするため、セル高を約55ptに詰める
            childAspectRatio: 1.3,
            children: [
              for (final url in section.assetNames.map(_assetUrl))
                _IconCell(
                  url: url,
                  isSelected: url == iconPath,
                  onTap: () => _select(context, ref, url),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// アセット名→パスの組み立て（選択判定・タップ結果のずれ防止のため1箇所に集約）
  static String _assetUrl(String name) => 'assets/images/$name.svg';

  void _select(BuildContext context, WidgetRef ref, String url) {
    Navigator.of(context).pop();
    if (categoryType == CategoryType.income) {
      ref
          .read(incomeBigCategoryIconControllerNotifierProvider.notifier)
          .updateState(url);
    } else {
      ref
          .read(bigCategroyIconControllerNotifierProvider.notifier)
          .updateState(url);
    }
  }
}

/// グリッドの1セル。円44px・アイコン20px。
/// 選択中は primaryTint地 + 1.5px primary枠 + primaryアイコン。
class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.url,
    required this.isSelected,
    required this.onTap,
  });

  final String url;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isSelected ? context.colors.primary : context.colors.textSecondary;

    return Center(
      child: AppInkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? context.colors.primaryTint : null,
            border: isSelected
                ? Border.all(color: context.colors.primary, width: 1.5)
                : null,
          ),
          child: Center(
            child:
                CategoryHandler().iconWidget(url, iconColor, width: 20, height: 20),
          ),
        ),
      ),
    );
  }
}
