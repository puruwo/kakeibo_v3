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

# kakeibo テスト構築ガイド

2026-08にロジックUT→DB結合→Widget結合（計849件・PR #54〜#59）を整備したときに確立した規約。
**新しいテストは必ず既存基盤（`test/helper/`）に乗せる。** mockito等の新しいモック機構を勝手に導入しない。

## TL;DR

| 原則 | 内容 |
|---|---|
| 層を選ぶ | ロジック＝UT（§2〜3・Fake注入）／SQL・スキーマ＝DB結合（§8・本物DB）／表示・操作・配線＝Widget結合（§9・本物画面＋Fake）。**同じ検証を2層でやらない** |
| 基盤に乗せる | Fakeは `test/helper/fake_repositories.dart`、コンテナは `test/helper/test_container.dart`、DB結合は `db_test_helper.dart`、Widgetは `widget_test_helper.dart` を使う・育てる |
| 本物を読んでからFakeを書く | 本物のIF **と repository実装（SQL）** を読み、条件・ORDER BY・デフォルト値フォールバックまで模す。**本物に無い仕様を捏造しない** |
| バグは固定しない | 実装バグを見つけたら黙って現状挙動に合わせず、修正提案としてユーザーに提示する（判断待ちの固定方法と修正後の反転は→ §6） |
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
                             # pump系ユーティリティ・closeRegisterModal）
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
2. **書き込みは記録する**: `insertedEntities` / `updatedEntities` / `deletedIds` 等の検証用リストを持つ
3. **読み取りはメモリ内で本物のSQLを模す**: 期間フィルタ・`delete_flag=0`・`ORDER BY`（例:
   fetchNextPeriodPaymentはid降順）・該当なし時のデフォルトエンティティ返却まで、
   `lib/repository/` の実装に合わせる。**合っているかはFake側のdocコメントに根拠を書く**
4. **拡張は後方互換**: 既存コンストラクタ・メソッドのシグネチャを変えない。設定フィールドの
   追加はオプション引数か公開フィールドで
5. 期間・日付で返り値を変えたいときは既存の方式に従う:
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

1. **黙って現状挙動に合わせない**。本物の実装・Wiki仕様・類似コード（同種の別画面など）と
   突き合わせて根拠を揃える
2. 影響（どの画面・どの設定で発症するか）と修正案をユーザーに提示し、判断を仰ぐ
3. **判断待ちの間の固定方法**: そのケースをskip/削除せず、「実挙動を検証するテスト＋
   docコメントで『実装準拠・疑わしい』と明示」で固定する。必発の例外・オーバーフローは
   「そのエラーだけが出る」ことをexpectで明示消費する（握りつぶすと別の異常も見えなくなる）
4. 修正が承認されたら: **修正commit（🐞bugfix_👾UT）とテストcommit（✈️feature_👾UT）を分け**、
   手順3で固定したテストの期待を正常側へ**反転**する（例: 「例外が1件だけ出る」→「例外が出ない」）。
   反転済みテストが再発時の自動検知になる。修正がUIに及ぶ場合はシミュレータでの
   動作確認・スクショ評価（kakeibo-workflow §4）とTestFlightトリガーも必要
5. 参考: この流れで計10件の本番バグを検出・修正した（UT: 月シフト月末補正・バッチの
   delete_flag欠落・確定操作のID取り違え/await漏れ・計画カードのステータス上書き・
   詳細カードの比率0／結合: モーダルdispose例外・2pxオーバーフロー・カテゴリー0件
   クラッシュ・フォント名大小不一致）。仕様判断がつかないもの（カレンダーの拠出元無視・
   budget重複行の採用規則など）は実挙動固定のまま申し送りに残っている

## 7. 検証と品質ゲート（テスト追加のたびに必須）

```bash
dart format <今回触ったファイルだけ>   # 無関係ファイルの一括再整形をしない
flutter analyze                        # 変更・新規ファイルに error/warning/info 0
flutter test                           # 既存全件＋新規全件パス（1件でも落ちたら直してから次へ）
```

- commitは `flutter-commit-rules` に従う。チケット無しのテスト整備は識別子 `👾UT`
- テストのみのcommitは ✈️feature、Fake等の基盤修正のみは ♻️refactor
- テストのみの変更ならTestFlightトリガーは不要（lib/にバグ修正が入ったら必要）

## 8. DB結合テスト（test/db_integration/）

repository層の**本物のSQL**・スキーマ・マイグレーションを `sqflite_common_ffi` で検証する層。
UTのFakeが模したSQLの答え合わせでもある（食い違いを見つけたら§6のフローへ）。

### 使い方

- 各テストファイルの `main()` 冒頭で `setUpDbTestEnvironment()` を1回呼ぶ。これだけで
  ①FFI初期化 ②path_providerをスイート固有の一時ディレクトリへ差し替え
  （**flutter testはスイートを並列実行するため固定パスだとDBファイルが衝突する**）
  ③毎テストの `resetDatabase()`（onCreateから再作成・DebugSeeder無効化）が効く
- 前提データは直SQLフィクスチャ（`insertExpenseRow` 等・id明示可）で決定的に投入し、
  **検証対象の書き込みだけ**をrepository経由で実行する
- **void戻りの書き込み**（expense/income/budget等のinsert/update/delete）はawaitできない。
  呼んだ後 `settleDbWrites()` で完了待ちする（足りないときは `waitUntil` / `waitUntilRowCount`）

### 観点（本物のSQLを読んで分岐単位で張る）

- 期間条件は `>=` `<=` `<` の別まで読み、開始日・終了日ちょうど＋期間外＋年跨ぎを張る
- ORDER BYが無いクエリの順序を検証しない（idソートして集合として比較する）
- onCreateのシード前提: 支出大カテゴリ7・小15／収入大2・小4／固定費カテゴリ5／
  batch_history初期1件。シード数に依存する検証は根拠コメント付きでこの値を使う
- 横断JOIN系（category集計・small_category_tile・daily_expense）はFakeが模していない
  固定値注入型なので、**この層が唯一の担保**。0埋め（IFNULL）・非表示カテゴリの除外・
  拠出元絞りの有無を実装から読んで固定する

### マイグレーションのテスト

- 単体（toV7/toV8等）: 旧形状テーブルをテスト内DDLで作る（出典は `sql_on_update.dart` の
  旧CREATE文。**出典コメント必須**）→ 実行 → 列構成・データ引き継ぎ・バックフィルを検証
- チェーン: `DatabaseHelper` のパスへ旧バージョンのDBファイルを事前生成してから
  `DatabaseHelper.instance.database` にアクセスし、**本番のonUpgrade経路**で順次適用されて
  `user_version` が上がることを検証する
- 冪等性（2回連続実行）と中断残骸（`*_new` テーブル残存）への耐性も張る

## 9. Widget結合テスト（test/widget/）

本物の画面Widgetを描画・操作し「表示・操作・ユースケース配線」を検証する層。
**ロジックの正しさはUTの担当なので再検証しない。** 1画面=1ファイル。

### 使い方

- `pumpApp(tester, home: 対象画面, fakes: TestFakes(...))` で開く。main.dartと同じ構成
  （全リポジトリのFake注入・ダークテーマ固定・textScaler 1.0・390×844/DPR 3.0・
  基準シナリオ2025/7/6）が入り、戻り値の `TestFakes` で書き込み記録を検証できる
- 検証は3種: ①表示（Fakeに入れた値が画面に出る）②操作（タップ→遷移先のkey/文言の出現・
  ダイアログ・エラー表示）③配線（Fakeの `insertedEntities` / `confirmExpense` 等の記録）

### 落とし穴（実地で確立したもの）

- **`pumpAndSettle` は使わない**（CircularProgressIndicator等の無限アニメで必ずタイムアウト）。
  `pumpTimes` / `pumpAndCollectExceptions` / `pumpCatchingZoneErrors` を使う
- フォントは実物を読み込む（`pumpApp` 内の `loadAppFonts()`）。テスト既定の等幅フォントだと
  文字幅の計測が実機とズレて**偽のRenderFlexオーバーフロー**が出る
- Foundationは起動時に記録モーダルを自動表示する（**Wiki遷移図に記載の仕様**）。下の画面を
  触るテストはまず `closeRegisterModal` で閉じる（破棄で例外が出ないことも同時に担保される）
- IndexedStackの非表示タブ・モーダルの裏を find で探すときは `skipOffstage: false`
- カテゴリーアイコン画像は検証しない（`category_handler` がDB直叩きのためテストでは常に空表示）
- レイアウトオーバーフローはテスト失敗として現れる。**握りつぶさない**: 実装バグなら§6の
  フローで扱う。1フレームに複数例外が出るケースは `tester.takeException()` が
  「Multiple exceptions」に化けるので、`FlutterError.onError` を差し替えて個別回収する

## 10. スコープ外（このSkillで扱わないもの）

- E2E（`integration_test` パッケージによる実機結合）・ゴールデンテスト（スクショ比較）
- 生成ファイル（*.g.dart / *.freezed.dart）・薄い委譲のみのProvider
- シミュレータでの動作確認・スクショ評価の手順 → `kakeibo-simulator` / `kakeibo-workflow` §4
