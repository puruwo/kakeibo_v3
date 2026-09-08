enum BigCategoryDetailEditScreenMode {
  edit, // 編集モード
  newCategoryAdd, // 追加モード
}

/// 新規カテゴリー作成中の大カテゴリーID
///
/// まだDBに行が無いため、編集中リスト（大カテゴリーごとのfamily）のキーにこの値を使う
const int kNewCategoryBigId = -1;
