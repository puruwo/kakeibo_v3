
// 固定費用のtileValueの抽象型
abstract class IMonthlyFixedTileValue {

  // expense
    int get id;
    DateTime get date;

    // fixed cost
    String  get name;
    int  get variable;
    int  get intervalNumber;
    int  get intervalUnit;
    String? get  nextPaymentDate;

    // 支出カテゴリー（v10で固定費カテゴリーから移行）
    // categoryName は大カテゴリー名、smallCategoryName は小カテゴリー名
    String get categoryName;
    String get smallCategoryName;
    String get colorCode;
    String get resourcePath;  

    String get frequencyLabel;
}
