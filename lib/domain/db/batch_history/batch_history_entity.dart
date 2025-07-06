import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'batch_history_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'batch_history_entity.g.dart';

// 支出データのエンティティ
@freezed
class BatchHistoryEntity with _$BatchHistoryEntity {
  const factory BatchHistoryEntity({
    int? id,
    required String startDate,
    required String endDate,
    required int status,
  }) = _BatchHistoryEntity;

  @override
  factory BatchHistoryEntity.fromJson(Map<String, dynamic> json) =>
      _$BatchHistoryEntityFromJson(json);
}
