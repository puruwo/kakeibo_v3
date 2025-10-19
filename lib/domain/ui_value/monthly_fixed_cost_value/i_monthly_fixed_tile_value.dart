
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

    // fixed cost category
    String get categoryName;
    String get colorCode;
    String get resourcePath;  

    String get frequencyLabel;
}
