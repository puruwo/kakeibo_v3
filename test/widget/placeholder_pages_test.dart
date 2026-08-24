// 未実装のプレースホルダー画面のスモークテスト
//
// 家族タブ（lib/view/family_page/）は本実装前の「準備中」表示のみ。
// 実装が入ったらこのテストが落ちるので、差し替えの合図になる。
// （年間支出一覧は本実装済み → yearly_expense_list_page_test.dart）
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/view/family_page/family_page.dart';

import '../helper/widget_test_helper.dart';

void main() {
  testWidgets('家族タブは「準備中」のプレースホルダー表示', (tester) async {
    await pumpApp(tester, home: const FamilyPage());
    await pumpTimes(tester);

    expect(find.text('家族'), findsOneWidget); // AppBar
    expect(find.text('準備中'), findsOneWidget);
  });
}
