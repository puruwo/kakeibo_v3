/// カテゴリー選択に関する型定義
///
/// CategoryAreaウィジェットで使用するenum、データクラスを定義

/// ボタンの表示状態
enum ButtonStatus {
  /// 選択中
  selected,

  /// 通常（非選択）
  normal,

  /// 表示なし（カテゴリーが存在しない枠）
  none,
}

/// トランザクションの種類
///
/// v10で固定費は支出タブのトグルに吸収したため fixedCost(1) を廃止した（仕様 §8.2）。
/// modeNumber はDB・SharedPreferencesのいずれにも永続化されていない
/// （リポジトリ全体で参照箇所が無いことを確認済み）ため、income の番号は 2→1 に詰めた。
enum TransactionMode {
  /// 支出
  expense(0),

  /// 収入
  income(1);

  final int modeNumber;
  const TransactionMode(this.modeNumber);
}

/// ページネーション情報
class CategoryPagination {
  /// 総ページ数
  final int pageCount;

  /// 1ページあたりのアイテム数
  final int itemsPerPage;

  const CategoryPagination({
    required this.pageCount,
    required this.itemsPerPage,
  });
}
