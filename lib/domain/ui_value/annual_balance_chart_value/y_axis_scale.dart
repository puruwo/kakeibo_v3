import 'package:freezed_annotation/freezed_annotation.dart';

part 'y_axis_scale.freezed.dart';

/// 生活収支グラフのY軸スケール情報
/// usecase で計算され、UI は描画のみで参照する
@freezed
class YAxisScale with _$YAxisScale {
  const factory YAxisScale({
    required double minValue, // 折れ線エリアの下限
    required double maxValue, // 折れ線エリアの上限
    required double interval, // グリッド間隔（10k/20k/50k/100k...）
    required List<double> gridValues, // 水平グリッド線を引く値
  }) = _YAxisScale;
}
