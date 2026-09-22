/// レコード一括削除の対象種別（KP-031）
///
/// 遷移元のタイルの種別で決まり、一覧には同じ種別の全レコードだけを出す
/// （支出と収入は混ぜない → Vault「Kakeibo レコード一括削除仕様」§1）。
enum BulkDeleteMode {
  /// 支出（通常支出・固定費行・特別枠を含む `expense` の全行）
  expense,

  /// 収入（生活収支・特別枠を含む `income` の全行）
  income;

  /// 一覧ページの AppBar タイトル
  String get pageTitle => switch (this) {
    BulkDeleteMode.expense => '支出をまとめて削除',
    BulkDeleteMode.income => '収入をまとめて削除',
  };
}
