import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'payment_frequency_value.freezed.dart';

enum PaymentFrequencyIntervalUnit {
  month('月',1), // 月
  year('年',2); // 年

  final String japaneseName;
  final int inturvalUnitNumber;

  const PaymentFrequencyIntervalUnit(this.japaneseName,this.inturvalUnitNumber);

  // ★ カスタムプロパティをキーにして抽出するメソッド
  static PaymentFrequencyIntervalUnit? fromInturvalUnitNumber(int inturvalUnitNumber) {
    return PaymentFrequencyIntervalUnit.values
        .firstWhere(
          (e) => e.inturvalUnitNumber == inturvalUnitNumber,
          orElse: () => PaymentFrequencyIntervalUnit.month, // デフォルトは月 
        );
  }

}

@freezed
class PaymentFrequencyValue with _$PaymentFrequencyValue {
  const factory PaymentFrequencyValue({
    required int intervalNumber,
    required PaymentFrequencyIntervalUnit intervalUnit,
    required String dateLabel,
  }) = _PaymentFrequencyValue;

  // "初期化ロジック付きのカスタムfactory"を用意
  factory PaymentFrequencyValue.fromDB({
    required int intervalNumber,
    required int intervalUnitNumber,
  }) {
    // intervalUnitNumberが1なら月、2なら年とする
    final intervalUnit = intervalUnitNumber == 1
        ? PaymentFrequencyIntervalUnit.month
        : PaymentFrequencyIntervalUnit.year;

    // ここでlabelを取得
    final dateLabel = _makeDateLabel(intervalNumber, intervalUnit);

    return PaymentFrequencyValue(
      intervalNumber: intervalNumber,
      intervalUnit: intervalUnit,
      dateLabel: dateLabel,
    );
  }
}

// 計算ロジック（外部関数でOK）
String _makeDateLabel(int intervalNumber, PaymentFrequencyIntervalUnit intervalUnit) {
  if (intervalUnit == PaymentFrequencyIntervalUnit.month) {
    if (intervalNumber == 1) {
      return '毎月';
    } else if (intervalNumber == 2) {
      return '隔月';
    } else {
      return '$intervalNumberヶ月毎';
    }
  } else if (intervalUnit == PaymentFrequencyIntervalUnit.year) {
    if (intervalNumber == 1) {
      return '毎年';
    } else if (intervalNumber == 2) {
      return '隔年';
    } else {
      return '$intervalNumber年毎';
    }
  } else {
    return '';
  }
}
