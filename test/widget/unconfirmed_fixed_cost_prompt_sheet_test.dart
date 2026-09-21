// 未確定固定費の一覧シート（lib/view/unconfirmed_fixed_cost_prompt/）のWidget結合テスト（KP-028）
//
// 起動時の促し（Foundation → 記録モーダルの上に一覧シート）の配線と、
// シート内の操作（あとで・予想額で確定）を確認する。
// 対象の判定は UnconfirmedFixedCostPromptRule / Usecase のUTで担保済み。
// 月間分析のバナーからの導線は monthly_page_test で見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view/foundation.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_sheet.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 起動時に自動表示される記録モーダルもカテゴリーを引くため、マスタを積む
  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 4,
      colorCode: '00AAFF',
      bigCategoryName: '光熱費',
      resourcePath: 'assets/images/icon_bolt.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
  ];
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 41,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 4,
      displayedOrderInBig: 1,
      smallCategoryName: '電気',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 42,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 4,
      displayedOrderInBig: 2,
      smallCategoryName: '水道',
      defaultDisplayed: 1,
    ),
  ];

  // 変動固定費のマスタ（30:電気代 / 31:水道代）
  const fixedCosts = [
    FixedCostEntity(
      id: 30,
      name: '電気代',
      variable: 1,
      estimatedPrice: 6000,
      expenseSmallCategoryId: 41,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250805',
    ),
    FixedCostEntity(
      id: 31,
      name: '水道代',
      variable: 1,
      estimatedPrice: 4100,
      expenseSmallCategoryId: 42,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250815',
    ),
  ];

  // 今日 2025/7/6・開始日25日 → 現在の月度は 6/25〜7/24。
  // 6/5・6/15 は前の月度なので起動時の促しの対象になる
  const pastElectricity = ExpenseEntity(
    id: 200,
    date: '20250605',
    price: null,
    paymentCategoryId: 41,
    memo: '電気代',
    fixedCostId: 30,
    isConfirmed: 0,
    estimatedPrice: 6000,
  );
  const pastWater = ExpenseEntity(
    id: 201,
    date: '20250615',
    price: null,
    paymentCategoryId: 42,
    memo: '水道代',
    fixedCostId: 31,
    isConfirmed: 0,
    estimatedPrice: 4100,
  );
  // 現在の月度の未確定行（起動時の促しの対象外）
  const currentElectricity = ExpenseEntity(
    id: 202,
    date: '20250705',
    price: null,
    paymentCategoryId: 41,
    memo: '電気代',
    fixedCostId: 30,
    isConfirmed: 0,
    estimatedPrice: 6000,
  );

  TestFakes buildFakes({required List<ExpenseEntity> expenses}) => TestFakes(
    expense: FakeExpenseRepository(initialRecords: expenses),
    fixedCost: FakeFixedCostRepository(initialRecords: fixedCosts),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
  );

  final sheet = find.byType(UnconfirmedFixedCostPromptSheet);

  testWidgets('過去の月度に未確定行があると、起動時に記録モーダルの上へ一覧シートが出る', (tester) async {
    await pumpApp(
      tester,
      home: const Foundation(),
      fakes: buildFakes(
        expenses: const [pastElectricity, pastWater, currentElectricity],
      ),
    );
    await pumpTimes(tester);

    expect(sheet, findsOneWidget);
    expect(find.text('金額が未入力の固定費があります'), findsOneWidget);
    // 現在の月度の行（7/5）は数えない
    expect(find.text('過去の月の固定費が2件、未入力のままです'), findsOneWidget);
    expect(find.text('6/5・予想 ¥ 6,000'), findsOneWidget);
    expect(find.text('6/15・予想 ¥ 4,100'), findsOneWidget);
    expect(find.text('7/5・予想 ¥ 6,000'), findsNothing);
    // 支払日の古い順（電気代 6/5 → 水道代 6/15）
    expect(
      tester.getTopLeft(find.text('6/5・予想 ¥ 6,000')).dy,
      lessThan(tester.getTopLeft(find.text('6/15・予想 ¥ 4,100')).dy),
    );
    // 記録モーダルは下に開いたまま
    expect(find.byType(RegisaterPageBase, skipOffstage: false), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('「あとで」で一覧シートだけが閉じ、記録モーダルが残る', (tester) async {
    await pumpApp(
      tester,
      home: const Foundation(),
      fakes: buildFakes(expenses: const [pastElectricity]),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('あとで'));
    await pumpTimes(tester);

    expect(sheet, findsNothing);
    expect(find.byType(RegisaterPageBase), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('過去の月度に未確定行が無ければ一覧シートは出ない', (tester) async {
    await pumpApp(
      tester,
      home: const Foundation(),
      fakes: buildFakes(expenses: const [currentElectricity]),
    );
    await pumpTimes(tester);

    expect(sheet, findsNothing);
    expect(find.byType(RegisaterPageBase), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('「予想額で確定」は確認を挟んで確定し、0件になるとシートが閉じる', (tester) async {
    final fakes = await pumpApp(
      tester,
      home: const Foundation(),
      fakes: buildFakes(expenses: const [pastElectricity]),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('予想額で確定'));
    await pumpTimes(tester);

    // 確認ダイアログ（ActionSheet 型）
    expect(find.text('予想額で確定しますか？'), findsOneWidget);
    expect(
      find.text('電気代（6/5）を¥ 6,000で確定します。\n金額はあとから変更できます。'),
      findsOneWidget,
    );

    await tester.tap(find.text('確定する'));
    await pumpTimes(tester);

    // 予想額が実額になって確定される
    final updated = await fakes.expense.fetchById(id: 200);
    expect(updated?.price, 6000);
    expect(updated?.isConfirmed, 1);
    // 対象が0件になったのでシートは自動的に閉じる
    expect(sheet, findsNothing);
    expect(find.byType(RegisaterPageBase), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('確認でキャンセルすると確定されず、一覧もそのまま', (tester) async {
    final fakes = await pumpApp(
      tester,
      home: const Foundation(),
      fakes: buildFakes(expenses: const [pastElectricity]),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('予想額で確定'));
    await pumpTimes(tester);
    await tester.tap(find.text('キャンセル'));
    await pumpTimes(tester);

    expect(fakes.expense.updatedEntities, isEmpty);
    expect(sheet, findsOneWidget);
    expect(find.text('6/5・予想 ¥ 6,000'), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('2件のうち1件を確定すると、シートは残って1件になる', (tester) async {
    await pumpApp(
      tester,
      home: const Foundation(),
      fakes: buildFakes(expenses: const [pastElectricity, pastWater]),
    );
    await pumpTimes(tester);

    // 先頭（電気代 6/5）の「予想額で確定」
    await tester.tap(find.text('予想額で確定').first);
    await pumpTimes(tester);
    await tester.tap(find.text('確定する'));
    await pumpTimes(tester);

    expect(sheet, findsOneWidget);
    expect(find.text('過去の月の固定費が1件、未入力のままです'), findsOneWidget);
    expect(find.text('6/5・予想 ¥ 6,000'), findsNothing);
    expect(find.text('6/15・予想 ¥ 4,100'), findsOneWidget);

    await unmountRegisterPage(tester);
  });
}
