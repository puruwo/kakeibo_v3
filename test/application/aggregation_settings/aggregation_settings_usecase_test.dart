import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/aggregation_settings/aggregation_settings_usecase.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_repository.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_repository.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_repository.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity_repository.dart';
import 'package:kakeibo/repository/aggregation_start_day_repository.dart';
import 'package:kakeibo/repository/aggregation_start_month_repository.dart';
import 'package:kakeibo/repository/month_basis_repository.dart';
import 'package:kakeibo/repository/year_basis_repository.dart';
import 'package:kakeibo/domain_service/system_datetime/date_scope.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/historical_date_scope.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/home_date_scope.dart';

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

  group('AggregationSettingsUsecase.save の再計算トリガー（KP-005 D-5）', () {
    // 本物のリポジトリ（SharedPreferences 読み）を使い、日付スコープが
    // 新しい開始日で組み直されることを確認する。システム日時のみ固定する
    ProviderContainer createRealContainer() => createContainer(
      overrides: [
        // 集計設定の4リポジトリは main.dart と同じ SharedPreferences 実装を注入する
        // （素の Provider は UnimplementedError を投げる）
        aggregationStartDayRepositoryProvider.overrideWithValue(
          ImplementsAggregationStartDayRepository(),
        ),
        aggregationStartMonthRepositoryProvider.overrideWithValue(
          ImplementsAggregationStartMonthRepository(),
        ),
        monthBasisRepositoryProvider.overrideWithValue(
          ImplementsMonthBasisRepository(),
        ),
        yearBasisRepositoryProvider.overrideWithValue(
          ImplementsYearBasisRepository(),
        ),
        systemDatetimeNotifierProvider.overrideWith(
          () => FixedSystemDatetimeNotifier(DateTime(2026, 8, 29)),
        ),
      ],
    );

    test('save 後は4つの日付スコープが破棄され、再読込で新しい開始日の期間になる', () async {
      final container = createRealContainer();
      final usecase = container.read(aggregationSettingsUsecaseProvider);

      // 変更前（既定の25日）: 8/25〜9/24
      final before = await Future.wait([
        container.read(systemDateScopeEntityProvider.future),
        container.read(homeDateScopeEntityProvider.future),
        container.read(analyzePageDateScopeEntityProvider.future),
        container.read(historicalDateScopeEntityProvider.future),
      ]);
      for (final scope in before) {
        expect(
          scope.aggregationMonthPeriod.startDatetime,
          DateTime(2026, 8, 25),
        );
        expect(scope.yearPeriod.startDatetime, DateTime(2026, 4, 25));
      }

      await usecase.save(startDay: 20, startMonth: 1);

      // 変更後: 8/20〜9/19・年度は 2026/1/20〜2027/1/19
      final after = await Future.wait([
        container.read(systemDateScopeEntityProvider.future),
        container.read(homeDateScopeEntityProvider.future),
        container.read(analyzePageDateScopeEntityProvider.future),
        container.read(historicalDateScopeEntityProvider.future),
      ]);
      for (final scope in after) {
        expect(
          scope.aggregationMonthPeriod.startDatetime,
          DateTime(2026, 8, 20),
        );
        expect(scope.aggregationMonthPeriod.endDatetime, DateTime(2026, 9, 19));
        expect(scope.yearPeriod.startDatetime, DateTime(2026, 1, 20));
        expect(scope.yearPeriod.endDatetime, DateTime(2027, 1, 19));
      }
    });

    test('範囲外（0・29・13）で例外のときは保存値も日付スコープも変わらない', () async {
      final container = createRealContainer();
      final usecase = container.read(aggregationSettingsUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);
      await usecase.save(startDay: 15, startMonth: 7);
      final scopeBefore = await container.read(
        systemDateScopeEntityProvider.future,
      );
      final countBefore = dbCount.read();

      for (final (day, month) in [(0, 7), (29, 7), (15, 13)]) {
        await expectLater(
          () => usecase.save(startDay: day, startMonth: month),
          throwsA(isA<AppException>()),
        );
      }

      final settings = await usecase.fetch();
      expect(settings.startDay, 15);
      expect(settings.startMonth, 7);
      // 破棄されていないので同じインスタンスが返る
      final scopeAfter = await container.read(
        systemDateScopeEntityProvider.future,
      );
      expect(identical(scopeAfter, scopeBefore), isTrue);
      expect(dbCount.read(), countBefore);
    });
  });
}
