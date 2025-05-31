import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'year_basis_entity.freezed.dart';

// 月の基準採択を集計期間の初日にするか、最終日にするかの設定

// ex)一年の集計期間を202504から202603とした場合
// 2025年と表示するか、2026年と表示するか
// start -> 2025年
// end -> 2026年

enum YearBasis {start, end}

@freezed
class YearBasisEntity with _$YearBasisEntity {
  const factory YearBasisEntity({
    required YearBasis monthBasis,
  }) = _YearBasisEntity;

}