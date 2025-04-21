import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';

// selectedDatetimeNotifierProviderを参照して、そのカレンダーの日付が選択されているかどうかを判定するProvider
final isDateboxSelectedProvider = Provider.family
    .autoDispose<bool, DateTime>((ref, boxDate)  {
  final selectedDate = ref.watch(selectedDatetimeNotifierProvider);
  if (boxDate == selectedDate) {
    return true;
  } else {
    return false;
  }
});
