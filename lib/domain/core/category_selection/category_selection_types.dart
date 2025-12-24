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
enum TransactionMode {
  /// 支出
  expense(0),

  /// 固定費
  fixedCost(1),

  /// 収入
  income(2);

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
