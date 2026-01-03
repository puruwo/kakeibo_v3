import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_income_value.freezed.dart';

/// 収入エクスポート用のValue
@freezed
class ExportIncomeValue with _$ExportIncomeValue {
  const factory ExportIncomeValue({
    required int id,
    required String date,
    required int price,
    @Default('') String memo,
    required String bigCategoryName,
    required int bigCategoryId,
    required String smallCategoryName,
    required int smallCategoryId,
  }) = _ExportIncomeValue;
}

List<dynamic> incomeToList(ExportIncomeValue instance) {
  return [
    instance.id,
    instance.date,
    instance.price,
    instance.memo,
    instance.bigCategoryName,
    instance.bigCategoryId,
    instance.smallCategoryName,
    instance.smallCategoryId,
  ];
}
