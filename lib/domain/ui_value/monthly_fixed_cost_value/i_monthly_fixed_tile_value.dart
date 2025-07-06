
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

    // small category
    String get smallCategoryName;

    // big tegory
    String get bigCategoryName;
    String get colorCode;
    String get resourcePath;

    String get frequencyLabel;
}
