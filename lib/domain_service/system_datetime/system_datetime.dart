import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_datetime.g.dart';

/// 運用日付
/// アプリ立ち上げ時点での日時を提供するプロバイダ
/// アプリ起動中は常に同じ日時を返す
/// アプリ内ではこのプロバイダを基準にして日付を扱う

@Riverpod(keepAlive: true)
class SystemDatetimeNotifier extends _$SystemDatetimeNotifier {
  @override
  DateTime build() {
    final now = DateTime(2025, 12, 31);
    // final now = DateTime.now();
    return now;
  }
}
