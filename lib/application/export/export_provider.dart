import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/export/export_usecase.dart';

final exportProvider =
    FutureProvider.autoDispose<void>((ref) => ref.watch(exportUsecaseProvider).exportAll());
