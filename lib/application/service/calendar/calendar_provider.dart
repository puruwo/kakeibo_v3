import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/service/calendar/calendar_usecase.dart';
import 'package:kakeibo/domain/calendar_day_entity/calendar_tile_entity.dart';

final calendarProvider = FutureProvider.family.autoDispose<List<List<CalendarTileEntity>>,int>(
  (ref, calendarPage) async => ref.watch(calendarUsecaseProvider).fetch(calendarPage),
);
