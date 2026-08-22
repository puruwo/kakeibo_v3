/// 収入大カテゴリーの既定カテゴリー（onCreate初期データ）
///
/// 既定2カテゴリーは削除禁止・会計種別の変更不可（ADR-025）。
/// その判定は必ず [isDefaultCategory] を使い、id直値の比較を書かない。
class IncomeBigCategoryConstants {
  // 月次収入（会計種別: 生活収支）
  static const int monthlyIncomeId = 1;

  // ボーナス（会計種別: 特別枠）
  static const int bonusId = 2;

  /// 既定カテゴリー（削除・会計種別変更を禁止する対象）かどうか
  static bool isDefaultCategory(int id) =>
      id == monthlyIncomeId || id == bonusId;
}

/// 会計種別（income_big_category.account_type / expense.income_source_big_category の値）
///
/// ADR-025: 収入大カテゴリーごとに会計種別（生活収支/特別枠）を持ち、
/// 集計スコープはカテゴリーIDではなく会計種別で決まる。
/// expense.income_source_big_category も歴史的経緯で大カテゴリーIDを格納していたが、
/// v9以降は会計種別値（1=生活収支, 2=特別枠）として扱う。
class AccountTypeConstants {
  // 生活収支（一般会計）
  static const int living = 1;

  // 特別枠（特別会計。旧「ボーナス」スコープ）
  static const int special = 2;

  // UI表示ラベル（拠出元セレクタ・カテゴリー編集の会計種別で共通に使う）
  static const String livingLabel = '生活収支';
  static const String specialLabel = '特別枠';

  /// 会計種別値からUIラベルを返す
  static String label(int accountType) =>
      accountType == special ? specialLabel : livingLabel;
}

/// 収入小カテゴリーの既定ID（onCreate初期データ）
///
/// 「新しい収入を追加」の初期選択カテゴリー等、小カテゴリーIDが必要な箇所で使う。
/// 大カテゴリー定数（1/2）と値が偶然一致していたため誤用されていた箇所の是正用。
class IncomeSmallCategoryConstants {
  // 給与（大カテゴリー: 月次収入）
  static const int salary = 1;

  // ボーナス（大カテゴリー: ボーナス）
  static const int bonus = 2;
}
