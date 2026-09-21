// UnconfirmedFixedCostPromptRule（未確定固定費の促しの対象判定・純粋関数）のテスト
//
// 基準シナリオ: 開始日25日・今日 2025/7/6 → 現在の月度は 6/25〜7/24（KP-028）。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/unconfirmed_fixed_cost_prompt_rule/unconfirmed_fixed_cost_prompt_rule.dart';

void main() {
  // 現在の月度（6/25〜7/24）
  final currentPeriod = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  group('isLaunchPromptTarget（起動時の促しの対象）', () {
    bool judge(DateTime paymentDate, {bool isConfirmed = false}) =>
        UnconfirmedFixedCostPromptRule.isLaunchPromptTarget(
          paymentDate: paymentDate,
          isConfirmed: isConfirmed,
          currentPeriod: currentPeriod,
        );

    test('支払日が現在の月度の開始日の前日なら対象になる', () {
      expect(judge(DateTime(2025, 6, 24)), isTrue);
    });

    test('支払日が現在の月度の開始日ちょうどなら対象にならない', () {
      expect(judge(DateTime(2025, 6, 25)), isFalse);
    });

    test('支払日が現在の月度の中・未来なら対象にならない', () {
      expect(judge(DateTime(2025, 7, 5)), isFalse);
      expect(judge(DateTime(2025, 8, 1)), isFalse);
    });

    test('何か月も前・前年の未確定行も対象になる', () {
      expect(judge(DateTime(2025, 1, 10)), isTrue);
      expect(judge(DateTime(2024, 12, 31)), isTrue);
    });

    test('確定済みの行は過去の月度でも対象にならない', () {
      expect(judge(DateTime(2025, 6, 24), isConfirmed: true), isFalse);
    });

    test('現在の月度の開始日に時刻が付いていても日付だけで判定する', () {
      final result = UnconfirmedFixedCostPromptRule.isLaunchPromptTarget(
        paymentDate: DateTime(2025, 6, 25),
        isConfirmed: false,
        currentPeriod: PeriodValue(
          startDatetime: DateTime(2025, 6, 25, 9, 30),
          endDatetime: DateTime(2025, 7, 24),
        ),
      );
      expect(result, isFalse);
    });
  });

  group('isOverdueTarget（月間分析の注意バナーの対象）', () {
    bool judge(
      DateTime paymentDate, {
      required DateTime today,
      bool isConfirmed = false,
      PeriodValue? shownPeriod,
    }) => UnconfirmedFixedCostPromptRule.isOverdueTarget(
      paymentDate: paymentDate,
      isConfirmed: isConfirmed,
      today: today,
      shownPeriod: shownPeriod ?? currentPeriod,
    );

    test('猶予日数は3日', () {
      expect(UnconfirmedFixedCostPromptRule.overdueGraceDays, 3);
    });

    test('支払日から2日後はまだ対象にならない', () {
      expect(judge(DateTime(2025, 7, 1), today: DateTime(2025, 7, 3)), isFalse);
    });

    test('支払日から3日後ちょうどで対象になる', () {
      expect(judge(DateTime(2025, 7, 1), today: DateTime(2025, 7, 4)), isTrue);
    });

    test('今日に時刻が付いていても日付だけで判定する', () {
      // 運用日付は起動時刻を含む。3日後の 0:01 でも対象になる
      expect(
        judge(DateTime(2025, 7, 1), today: DateTime(2025, 7, 4, 0, 1)),
        isTrue,
      );
      // 2日後の 23:59 は対象にならない
      expect(
        judge(DateTime(2025, 7, 1), today: DateTime(2025, 7, 3, 23, 59)),
        isFalse,
      );
    });

    test('支払日が未来の行は対象にならない', () {
      expect(
        judge(DateTime(2025, 7, 20), today: DateTime(2025, 7, 6)),
        isFalse,
      );
    });

    test('月度の開始日・終了日ちょうどの支払日は月度内として扱う', () {
      expect(judge(DateTime(2025, 6, 25), today: DateTime(2025, 7, 6)), isTrue);
      expect(
        judge(DateTime(2025, 7, 24), today: DateTime(2025, 7, 27)),
        isTrue,
      );
    });

    test('表示中の月度の外にある支払日は3日経過していても対象にならない', () {
      // 開始日の前日・終了日の翌日
      expect(
        judge(DateTime(2025, 6, 24), today: DateTime(2025, 7, 6)),
        isFalse,
      );
      expect(
        judge(DateTime(2025, 7, 25), today: DateTime(2025, 8, 6)),
        isFalse,
      );
    });

    test('月末・年末をまたぐ3日後も正しく数える', () {
      final yearEndPeriod = PeriodValue(
        startDatetime: DateTime(2025, 12, 25),
        endDatetime: DateTime(2026, 1, 24),
      );
      // 12/30 の3日後は 1/2
      expect(
        judge(
          DateTime(2025, 12, 30),
          today: DateTime(2026, 1, 1),
          shownPeriod: yearEndPeriod,
        ),
        isFalse,
      );
      expect(
        judge(
          DateTime(2025, 12, 30),
          today: DateTime(2026, 1, 2),
          shownPeriod: yearEndPeriod,
        ),
        isTrue,
      );
    });

    test('確定済みの行は3日経過していても対象にならない', () {
      expect(
        judge(
          DateTime(2025, 7, 1),
          today: DateTime(2025, 7, 6),
          isConfirmed: true,
        ),
        isFalse,
      );
    });
  });
}
