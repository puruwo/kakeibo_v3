import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';

/// 記録モーダルのカテゴリーグリッドに直接出すカテゴリーの規則（KP-032）
///
/// グリッドは 15セル／ページ・最大2ページ（30セル）で、末尾の1セルは「すべて」に固定する。
/// 直接出せるカテゴリーは `default_displayed = 1` のものを表示順の先頭から最大29件。
/// 30件以上に旗が立っていても29件で打ち切る（v14 で全行1のまま多く持つ利用者向け）。
class RegisterGridCategoryRule {
  const RegisterGridCategoryRule._();

  /// 1ページのセル数（5列×3行）
  static const int cellsPerPage = 15;

  /// ページ数の上限
  static const int maxPages = 2;

  /// 直接表示できるカテゴリーの上限（30セル − 「すべて」セル1つ）
  static const int maxDisplayedCount = cellsPerPage * maxPages - 1;

  /// 記録画面に直接出すカテゴリーを取り出す
  ///
  /// [all] は表示順（`sortKey`）に並んだ一覧。順序は保つ。
  static List<T> displayed<T extends ICategoryEntity>(List<T> all) {
    return all
        .where((category) => category.defaultDisplayed == 1)
        .take(maxDisplayedCount)
        .toList();
  }

  /// 表示中の件数が上限に達しているか
  static bool isFull(int displayedCount) => displayedCount >= maxDisplayedCount;

  /// 「すべて」セルを含めたセル数からページ数を求める（最低1ページ）
  static int pageCountFor(int cellCount) {
    if (cellCount <= 0) return 1;
    return ((cellCount - 1) ~/ cellsPerPage) + 1;
  }
}
