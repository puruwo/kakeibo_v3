import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/constant/sqf_constants.dart';

//Freezedで生成されるデータクラス
part 'expense_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'expense_entity.g.dart';

// 支出データのエンティティ
@freezed
class ExpenseEntity with _$ExpenseEntity {
  const factory ExpenseEntity({
    @Default(1) int id,
    required String date,
    // 実額。未確定の固定費行の間は NULL（v10でNULL許容化）
    int? price,
    @Default(0) int paymentCategoryId,
    @Default('') String memo,
    @Default(AccountTypeConstants.living) int incomeSourceBigCategory,
    // 固定費マスタへの参照。NULL＝通常支出（v10で追加）
    int? fixedCostId,
    // 0=未確定 / 1=確定。通常支出は常に1（v10で追加）
    @Default(1) int isConfirmed,
    // 予想額。変動固定費の実績生成時に設定し、確定後も保持する（v10で追加）
    int? estimatedPrice,
  }) = _ExpenseEntity;

  const ExpenseEntity._();

  /// 集計・表示で使う実効金額
  ///
  /// 未確定の固定費行は実額(price)を持たないため予想額(estimatedPrice)で代替する。
  /// SQL側の共通式 COALESCE(price, estimated_price) と同じ意味（仕様 §3）。
  int get effectivePrice => price ?? estimatedPrice ?? 0;

  @override
  factory ExpenseEntity.fromJson(Map<String, dynamic> json) =>
      _$ExpenseEntityFromJson(json);
}
