// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_income_small_category_list/editting_income_small_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_small_category_list_edited/is_income_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';

/// 小カテゴリー名の最大文字数（旧ダイアログから据え置き）
const int _kMaxNameLength = 20;

/// 文字数カウンターの幅。桁が増えても入力欄の幅が動かないように固定する
const double _kCounterWidth = 52;

/// 小カテゴリーの新規追加シートを開く（案件 KP-010）
///
/// 旧 `NewSmallCategoryInputNameDialog`（中央ダイアログ）の置き換え。
/// アイコン選択シートと同じく root の Navigator に載せる。
Future<void> showNewSmallCategoryInputSheet(
  BuildContext context, {
  required int bigCategoryId,
  CategoryType categoryType = CategoryType.expense,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => NewSmallCategoryInputSheet(
      bigCategoryId: bigCategoryId,
      categoryType: categoryType,
    ),
  );
}

/// 小カテゴリーの新規追加シート本体（案件 KP-010・ADR-030 のシート語彙）
///
/// 器・余白・ハンドルは予想額の入力シートに合わせている。
/// 追加した項目は編集中リストに載るだけで、DBへの反映はページの完了ボタンで行う。
class NewSmallCategoryInputSheet extends ConsumerStatefulWidget {
  const NewSmallCategoryInputSheet({
    required this.bigCategoryId,
    this.categoryType = CategoryType.expense,
    super.key,
  });

  final int bigCategoryId;
  final CategoryType categoryType;

  @override
  ConsumerState<NewSmallCategoryInputSheet> createState() =>
      _NewSmallCategoryInputSheetState();
}

class _NewSmallCategoryInputSheetState
    extends ConsumerState<NewSmallCategoryInputSheet> {
  final _textContoroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 文字数カウンターと「追加」の活性を入力に追従させる
    _textContoroller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textContoroller.removeListener(_onTextChanged);
    _textContoroller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 空白だけの名前は追加させない（保存側の検査も isEmpty のため素通りしてしまう）
    final canSubmit = _textContoroller.text.trim().isNotEmpty;

    return Padding(
      // キーボードで入力欄が隠れないように押し上げる
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          border: Border(top: BorderSide(color: context.colors.surfaceBorder)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ハンドル
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.handle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('小カテゴリーを追加', style: context.textStyles.sheetTitle),
              const SizedBox(height: 14),
              _buildNameField(context),
              const SizedBox(height: 10),
              Text(
                '一覧の末尾に追加されます。保存するまで確定しません',
                style: context.textStyles.insetGroupNote,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: MainButton(
                      buttonType: ButtonColorType.secondary,
                      buttonText: 'キャンセル',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: MainButton(
                      buttonType: ButtonColorType.main,
                      buttonText: '追加',
                      onPressed: canSubmit ? _onAddPressed : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 名称の入力欄（右端に文字数カウンター）
  ///
  /// 塗りと余白は `InputDecoration` に持たせる。外側の `Container` で塗ると、
  /// 塗りの大半が `TextField` のタップ領域の外になりカーソルを置けない。
  Widget _buildNameField(BuildContext context) {
    // maxLength と同じ数え方（書記素クラスタ）で数える
    final currentLength = _textContoroller.text.characters.length;

    return TextField(
      controller: _textContoroller,
      // オートフォーカスさせるか
      autofocus: true,
      // テキストの揃え(上下)
      textAlignVertical: TextAlignVertical.center,
      // カーソルの色
      cursorColor: context.colors.primary,
      // カーソルの先の太さ
      cursorWidth: 2,
      // 入力するテキストのstyle
      style: context.textStyles.sheetTextInput,
      // 行数の制約
      minLines: 1,
      maxLines: 1,
      // 最大文字数の制約
      maxLength: _kMaxNameLength,
      // 枠や背景などのデザイン
      decoration: InputDecoration(
        // trueにするとテキストフィールド全体の密度が下がる
        isDense: true,

        // 右下の既定カウンターは使わず、入力欄の右端に自前で出す
        counterText: '',

        // 背景の塗りつぶし（入力欄の範囲がわかるように塗る）
        filled: true,
        fillColor: context.colors.fillSecondary,

        // ヒントテキスト
        hintText: '小カテゴリー名',
        hintStyle: context.textStyles.listTileTextFieldHint,

        // テキストの余白
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),

        // 境界線を設定しないとアンダーラインが表示されるので透明でもいいから境界線を設定
        // 何もしていない時の境界線
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        // 入力時の境界線
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),

        // 文字数カウンター（入力欄の内側・右端）
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(
            width: _kCounterWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$currentLength / $_kMaxNameLength',
                style: context.textStyles.numericCaption,
              ),
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),


      // onTapOutside は付けない。シート内のボタンを押したときに
      // 先にキーボードが閉じてシートが下がり、1回目のタップが空振りするため。
      // キーボードを閉じたいときはキーボードの「完了」を使う
      // （シート外のタップはキーボードではなくシート自体を閉じる）
      onEditingComplete: () {
        //キーボードを閉じる
        FocusScope.of(context).unfocus();
      },
    );
  }

  /// 「追加」。編集中リストへ載せるだけで、永続化はページの完了ボタンで行う
  void _onAddPressed() {
    // 前後の空白は落として保存する
    final name = _textContoroller.text.trim();
    if (name.isEmpty) {
      return;
    }

    if (widget.categoryType == CategoryType.income) {
      // 収入小カテゴリー用entity
      // id（負の一意な値）と表示順は addSmallCategory が採番し直す。
      // 仮値も負にしておく（0以上は「DBにある既存項目」を意味するため）
      final entity = EditIncomeSmallCategoryValue(
        id: -1,
        bigCategoryKey: widget.bigCategoryId,
        name: name,
        smallCategoryOrderKey: 0,
        displayOrderInBig: 0,
        defaultDisplayed: 1,
        editedStateDisplayOrder: 0,
        etitedStateIsChecked: true,
      );

      ref
          .read(
            edittingIncomeSmallCategoryListNotifierProvider(
              widget.bigCategoryId,
            ).notifier,
          )
          .addSmallCategory(entity);

      ref
          .read(
            isIncomeSmallCategoryListEditedNotifierProvider(
              widget.bigCategoryId,
            ).notifier,
          )
          .updateState(true);
    } else {
      // 入力された名前を使って新しい小カテゴリーのentityを作成。
      // id（負の一意な値）と表示順は addSmallCategory が採番し直す。
      // 仮値も負にしておく（0以上は「DBにある既存項目」を意味するため）
      final entity = EditExpenseSmallCategoryValue(
        id: -1,
        bigCategoryKey: widget.bigCategoryId,
        name: name,
        smallCategoryOrderKey: 0, // 新規作成なので0
        displayOrderInBig: 0,
        defaultDisplayed: 1,
        editedStateDisplayOrder: 0,
        etitedStateIsChecked: true,
      );

      // 追加する処理をここに書く
      ref
          .read(
            edittingSmallCategoryListNotifierProvider(
              widget.bigCategoryId,
            ).notifier,
          )
          .addSmallCategory(entity);

      // 変更を加えたことを管理する状態管理する
      ref
          .read(
            isSmallCategoryListEditedNotifierProvider(
              widget.bigCategoryId,
            ).notifier,
          )
          .updateState(true);
    }

    Navigator.of(context).pop();
  }
}
