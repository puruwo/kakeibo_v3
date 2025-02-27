import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'datetime.g.dart';

@riverpod
class DateTimeNotifier extends _$DateTimeNotifier {
  @override
  DateTime build() {
    // 最初のデータ
    return DateTime.now();
  }

}
