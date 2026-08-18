import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/aggregation_settings/aggregation_settings_usecase.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/test_container.dart';

void main() {
  // AggregationSettingsStore は SharedPreferences 実装のため、
  // プラグインのモックを差し込めるようバインディングを初期化しておく
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // テストごとに保存内容を空（未設定）に戻す
    SharedPreferences.setMockInitialValues({});
  });

  group('AggregationSettingsUsecase.save のバリデーション', () {
    test('開始日が1未満・29以上ならエラー（境界の28日は通る）', () async {
      final container = createContainer();
      final usecase = container.read(aggregationSettingsUsecaseProvider);

      await expectLater(
        () => usecase.save(startDay: 0, startMonth: 4),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '開始日は1〜28日の間で設定してください',
          ),
        ),
      );
      await expectLater(
        () => usecase.save(startDay: 29, startMonth: 4),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '開始日は1〜28日の間で設定してください',
          ),
        ),
      );

      // 上限の境界（28日）はエラーにならない
      await usecase.save(startDay: 28, startMonth: 4);
      expect((await usecase.fetch()).startDay, 28);
    });

    test('開始月が1未満・13以上ならエラー（境界の12月は通る）', () async {
      final container = createContainer();
      final usecase = container.read(aggregationSettingsUsecaseProvider);

      await expectLater(
        () => usecase.save(startDay: 25, startMonth: 0),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '開始月は1〜12月の間で設定してください',
          ),
        ),
      );
      await expectLater(
        () => usecase.save(startDay: 25, startMonth: 13),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '開始月は1〜12月の間で設定してください',
          ),
        ),
      );

      // 上限の境界（12月）はエラーにならない
      await usecase.save(startDay: 25, startMonth: 12);
      expect((await usecase.fetch()).startMonth, 12);
    });
  });

  group('AggregationSettingsUsecase の保存と取得', () {
    test('保存した値がfetchでそのまま返る', () async {
      final container = createContainer();
      final usecase = container.read(aggregationSettingsUsecaseProvider);

      await usecase.save(startDay: 15, startMonth: 7);

      final settings = await usecase.fetch();
      expect(settings.startDay, 15);
      expect(settings.startMonth, 7);
    });

    test('保存するとDB更新カウンタが増える', () async {
      final container = createContainer();
      final usecase = container.read(aggregationSettingsUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);
      expect(dbCount.read(), 0);

      await usecase.save(startDay: 15, startMonth: 7);

      expect(dbCount.read(), 1);
    });

    test('未設定ならfetchは既定値（25日・4月）を返す', () async {
      final container = createContainer();
      final usecase = container.read(aggregationSettingsUsecaseProvider);

      final settings = await usecase.fetch();
      expect(settings.startDay, 25);
      expect(settings.startMonth, 4);
    });

    test('下限の境界（開始日1日・開始月1月）も保存して取得できる', () async {
      final container = createContainer();
      final usecase = container.read(aggregationSettingsUsecaseProvider);

      await usecase.save(startDay: 1, startMonth: 1);

      final settings = await usecase.fetch();
      expect(settings.startDay, 1);
      expect(settings.startMonth, 1);
    });
  });
}
