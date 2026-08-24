import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/icon_select_dialog.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_color_contoroller/big_category_color_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_icon_contoroller/big_category_icon_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_name_contoroller/big_category_name_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_big_category_appearance_edited/is_big_category_appearance_edited.dart';

/// 支出カテゴリーの外観編集エリア（案件 UIデザイン改修 §2）
///
/// 固定高さのCardContainer＋固定幅TextField＋ピル型行を廃止し、
/// 「外観」インセットグループ（名称／アイコン／カテゴリーカラー）へ統一する。
/// 名称行を先頭に置く（ユーザー決定）。
class CategoryAppearanceEditArea extends ConsumerStatefulWidget {
  const CategoryAppearanceEditArea({
    required this.bigId,
    required this.categoryType,
    super.key,
  });

  final int bigId;
  final CategoryType categoryType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryAppearanceEditAreaState();
}

class _BigCategoryAppearanceEditAreaState
    extends ConsumerState<CategoryAppearanceEditArea> {
  @override
  void initState() {
    super.initState();

    // 取得したデータをコントローラーに格納し編集できる状態にする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // -1の時は新規作成のため、initialItemはなく、下記処理はしない
      if (widget.bigId == -1) {
        return;
      }

      Future(() async {
        // 一度だけ取得してセット
        final initialItem = await ref.watch(
          bigCategoriesProvider(widget.bigId).future,
        );

        ref.read(bigCategoryNameControllerProvider).text =
            initialItem.bigCategoryName;
        ref
            .read(bigCategroyColorControllerNotifierProvider.notifier)
            .initState(ColorCode.toColor(initialItem.colorCode));
        ref
            .read(bigCategroyIconControllerNotifierProvider.notifier)
            .initState(initialItem.resourcePath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = ref.watch(bigCategroyIconControllerNotifierProvider);
    final color = ref.watch(bigCategroyColorControllerNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppInsetGroup(
        header: '外観',
        children: [
          // 名称（先頭・インライン編集）
          // 文字数制限は旧実装どおり設けない（既存の長い名称を切り詰めないため）。
          // 旧実装のautofocus・クリア（×）ボタンはインセット行化に伴い廃止
          // （行タップで編集開始する語彙に統一。案件 UIデザイン改修 §2）
          AppInsetRow.textField(
            icon: Icons.drive_file_rename_outline_rounded,
            label: '名称',
            controller: ref.watch(bigCategoryNameControllerProvider),
            hintText: 'カテゴリー名を入力',
            onChanged: (_) {
              // 大カテゴリーの見た目が編集されたことを通知
              ref
                  .read(isBigCategoryAppearanceEditedNotifierProvider.notifier)
                  .updateState(true);
            },
          ),

          // アイコン（右端に現在のアイコンをカテゴリー色でプレビュー）
          AppInsetRow.navigation(
            icon: Icons.grid_view_rounded,
            label: 'アイコン',
            valueWidget: SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              semanticsLabel: 'categoryIcon',
              width: 20,
              height: 20,
            ),
            onTap: () {
              showIconSelectSheet(context);
            },
          ),

          // カテゴリーカラー（右端に現在色のスウォッチ）
          AppInsetRow.navigation(
            icon: Icons.palette_outlined,
            label: 'カテゴリーカラー',
            valueWidget: Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () async {
              await showColorSelectSheet(context);
            },
          ),
        ],
      ),
    );
  }
}
