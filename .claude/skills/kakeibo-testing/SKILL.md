---
name: kakeibo-testing
description: >
  kakeiboのテスト（ロジックUT・DB結合・Widget結合）の構築・追加・修正ルール。
  テストを書くとき・Fakeリポジトリを触るとき・「テストを書いて/直して」と
  依頼されたときは必ずこのSkillに従うこと。
  対象はutil/domain_service/application/batchのUTと
  test/db_integration（repository層の本物SQL検証）・test/widget（画面）。
  E2E・ゴールデンテストは対象外。
---

# kakeibo ユニットテスト構築ガイド

2026-08にロジック層UT（381件・PR #54/#55/#56）を整備したときに確立した規約。
**新しいテストは必ず既存基盤（`test/helper/`）に乗せる。** mockito等の新しいモック機構を勝手に導入しない。

## TL;DR

| 原則 | 内容 |
|---|---|
| 基盤に乗せる | Fakeは `test/helper/fake_repositories.dart`、コンテナは `test/helper/test_container.dart` を使う・育てる |
| 本物を読んでからFakeを書く | 本物のIF **と repository実装（SQL）** を読み、条件・ORDER BY・デフォルト値フォールバックまで模す。**本物に無い仕様を捏造しない** |
| バグは固定しない | 実装バグを見つけたら「現状挙動をテストで固定」せず、修正提案としてユーザーに提示する（→ §6） |
| 検証3点セット | `dart format`（対象ファイルのみ）→ `flutter analyze`（変更ファイルに指摘0）→ `flutter test`（既存全件＋新規全件パス） |

## 1. テスト基盤の構成

```
test/
  helper/
    fake_repositories.dart   # 全リポジトリのFake（noSuchMethod方式・呼び出し記録つき）
    test_container.dart      # createContainer / aggregationSettingOverrides /
                             # buildDateScope / listenUpdateDBCount / FixedSystemDatetimeNotifier
    db_test_helper.dart      # DB結合テスト基盤（ffi・path_provider差し替え・resetDatabase・
                             # settleDbWrites・直SQLフィクスチャ投入）
    widget_test_helper.dart  # Widgetテスト基盤（TestFakes・pumpApp・実フォント読込・
                             # 既知バグ消費ヘルパー）
  util/ domain_service/ application/ batch/   # ロジックUT（lib/ の構成に対応させる）
  db_integration/            # repository層の本物SQL・スキーマ/マイグレーション検証
  widget/                    # 画面のWidget結合テスト（1画面=1ファイル）
```

- テストファイルは対象と同じ相対パスに `<対象名>_test.dart` で置く
- 1テーマ追加で肥大するとき（例: 既存クラスの別メソッド）は `<対象名>_<テーマ>_test.dart` で分けてよい
  （例: `fixed_cost_service_getfixedcosttotal_test.dart` / `budget_usecase_fetchall_test.dart`）

## 2. 基本パターン

```dart
// リポジトリIFのProviderをFakeでoverrideする（本番main.dartと同じDI機構）
final fakeRepository = FakeExpenseRepository();
final container = createContainer(overrides: [
  ...aggregationSettingOverrides(systemDate: DateTime(2025, 7, 6)), // 集計設定＋システム日時固定
  expenseRepositoryProvider.overrideWithValue(fakeRepository),
]);
final usecase = container.read(expenseUsecaseProvider);
```

- **基準シナリオ**: 集計設定は既定（開始日25日・開始月4月・basis=start）、システム日時は
  `2025/7/6` 固定（→ 集計期間 6/25〜7/24）。特別な理由がなければこれに揃える
- `createContainer` は `addTearDown` で自動disposeされる。**テスト関数の外で呼ばない**
  （groupの直下で呼ぶと落ちる。ヘルパー関数化して各test内で呼ぶ）

## 3. 対象別のテストパターン

| 対象 | 取得方法・注意 |
|---|---|
| 普通のUseCase | `container.read(xxxUsecaseProvider)` してメソッドを呼ぶ |
| `AsyncNotifierProvider.family` | `await container.read(provider(引数).future)`。familyの引数がクラスなら freezed/recordの等価性に注意 |
| `DateScopeEntity` が要る | `buildDateScope()`（test_container.dart）で組み立てる。periodStatusもここで制御 |
| Refを引数に取るサービス | **Refをbuildスコープの外へ持ち出さない**。`Provider.family<void, 引数>` を定義しbuild内で実行、テストは `container.read(provider(引数))` でトリガー（例: `fixed_cost_service_test.dart`） |
| `updateDBCountNotifierProvider`（autoDispose） | 素の `container.read` は毎回0に戻る。**`listenUpdateDBCount(container)` で購読を保持**してから検証する |
| SharedPreferences系（集計設定など） | setUpで `SharedPreferences.setMockInitialValues({})`。必要なら `TestWidgetsFlutterBinding.ensureInitialized()` |
| トップレベル純関数（fillOutOfPeriod / groupTransactionsByDate / buildExportCsvString等） | コンテナ不要で直接呼ぶ。**最優先でテストを書く場所** |

## 4. Fakeの設計原則（fake_repositories.dart を触るとき）

1. `implements` + 使うメソッドのみ実装 + `noSuchMethod` — 未実装メソッドが呼ばれたら
   その場で落ちて「テスト経路の想定漏れ」を検知できる
2. **書き込みは記録する**: `insertedEntities` / `updatedEntities` / `deletedIds` 等の検証用リストを持つ。
   検証用リストは「呼び出し時に何を渡されたか」をそのまま保持する（id採番後の値で上書きしない）
3. **書き込みは状態にも反映する**: insert/update/delete は、以後の取得系メソッドから見える状態
   （`records` 等）にも反映すること。本物のDBは INSERT した瞬間から SELECT の対象になるため、
   記録用リストに積むだけだとFakeが本物より甘くなり、重複防止のような「既にあるか」を見る
   ロジックのテストが素通りする。idは本物の AUTOINCREMENT 相当で採番し（既存の最大id+1等）、
   `records` に入れるのは採番後のエンティティ・戻り値は採番されたidにする
4. **読み取りはメモリ内で本物のSQLを模す**: 期間フィルタ・`delete_flag=0`・`ORDER BY`（例:
   fetchNextPeriodPaymentはid降順）・該当なし時のデフォルトエンティティ返却まで、
   `lib/repository/` の実装に合わせる。**合っているかはFake側のdocコメントに根拠を書く**
5. **拡張は後方互換**: 既存コンストラクタ・メソッドのシグネチャを変えない。設定フィールドの
   追加はオプション引数か公開フィールドで
6. 期間・日付で返り値を変えたいときは既存の方式に従う:
   期間キーMap（`periodKeyOf(DateTime)`）／日付キーMap（内部で時刻を正規化）。
   未設定キーは単一値・メモリ集計へフォールバック

## 5. テストの書き方規約

- **test名は日本語で仕様を語る**（「◯◯なら△△になる」）。groupは対象メソッド単位
- AppExceptionは message まで固定する:
  `throwsA(isA<AppException>().having((e) => e.message, 'message', '0円以上で入力してください'))`
- **境界値を必ず含める**: 金額上限の±1・期間の開始/終了日ちょうど・年跨ぎ（12月→1月）・
  閏年（2/29）・0件/空リスト
- 値の期待はfreezedの等価性で `expect(actual, ExpectedEntity(...))` 直接比較できる
- コメントは日本語。テストデータには「なぜその値か」（例: `// 支出ID=200 / マスタID=30 を区別`）を残す

## 6. 実装バグを見つけたとき

テスト作成中に「実装がおかしい」と思ったら:

1. **現状挙動をテストで固定しない**（バグの固定化はUT整備の目的に反する）
2. 本物の実装・Wiki仕様・類似コード（同種の別画面など）と突き合わせて根拠を揃える
3. 影響（どの画面・どの設定で発症するか）と修正案をユーザーに提示し、判断を仰ぐ
4. 承認後: **修正commit（🐞bugfix_👾UT）とテストcommit（✈️feature_👾UT）を分ける**。
   修正commitには回帰検知テストを含めてよい
5. 参考: この流れで6件の本番バグを検出した（月シフト月末補正・バッチのdelete_flag欠落・
   確定操作のID取り違え/await漏れ・計画カードのステータス上書き・詳細カードの比率0）

## 7. 検証と品質ゲート（テスト追加のたびに必須）

```bash
dart format <今回触ったファイルだけ>   # 無関係ファイルの一括再整形をしない
flutter analyze                        # 変更・新規ファイルに error/warning/info 0
flutter test                           # 既存全件＋新規全件パス（1件でも落ちたら直してから次へ）
```

- commitは `flutter-commit-rules` に従う。チケット無しのテスト整備は識別子 `👾UT`
- テストのみのcommitは ✈️feature、Fake等の基盤修正のみは ♻️refactor
- テストのみの変更ならTestFlightトリガーは不要（lib/にバグ修正が入ったら必要）

## 8. DB結合・Widget結合テストの要点（2026-08-11新設・PR #57/#58）

- **DB結合**（`test/db_integration/`）: 本物の `DatabaseHelper` をffiで動かし本物のSQLを検証する。
  各ファイルの main() 冒頭で `setUpDbTestEnvironment()` を呼ぶ（一時ディレクトリ・毎テストの
  onCreate再作成・DebugSeeder無効化を面倒みてくれる）。void戻りの書き込みは
  `settleDbWrites()` で完了待ち。前提データは直SQLフィクスチャ（insertExpenseRow等）で投入
- **Widget結合**（`test/widget/`）: `pumpApp`＋`TestFakes`（main.dartと同じDIでFakeを注入）。
  **`pumpAndSettle` は使わない**（無限アニメでタイムアウト）。記録モーダル破棄の既知バグは
  `closeRegisterModal` / `unmountRegisterPage` で明示消費する（詳細はwidget_test_helper.dartの
  docコメント）。検証対象は表示・操作・Fakeの呼び出し記録（ロジックの再検証はしない）
- **スコープ外**: E2E（integration_test）・ゴールデンテスト・
  生成ファイル（*.g.dart / *.freezed.dart）・薄い委譲のみのProvider
