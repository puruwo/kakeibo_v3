import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kakeibo/view_model/reference_day_impl.dart';

part 'kaknin_active_datetime.g.dart';


@riverpod
class KakninActiveDatetimeNotifier extends _$KakninActiveDatetimeNotifier {
  @override
  DateTime build() {
    // 最初のデータ
    final now = DateTime.now();
    return DateTime(now.year,now.month,now.day);
  }

  void updateState(DateTime dateTime) {
    // データを上書き
    state = dateTime;
  }  

  void updateToNextReferenceDay() {
    final newDt = getNextReferenceDay(state);
    state = newDt;
  }  

  void updateToPreviousReferenceDay() {
    final newDt = getPreviousReferenceDay(state);
    state = newDt;
  }  
}
