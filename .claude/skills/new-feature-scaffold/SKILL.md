---
name: new-feature-scaffold
description: >
  kakeiboでデータを扱う新機能（新しいentity・テーブル・UseCase）を追加するときの足場生成手順。
  「新機能を追加して」「〇〇のテーブル/entityを追加して」「機能の足場を作って」と指示されたとき、
  またはflutter-implementerがデータ層を伴う新規実装を行うときは必ずこのスキルに従うこと。
---

# 新機能の足場生成（entity → repository → usecase → UI）

CLAUDE.md「Adding a New Feature That Modifies Data」の7手順を、実コードの命名規則・
配置規則・雛形に落としたもの。**順番を飛ばさない**こと（特に build_runner と provider 登録の漏れが頻出）。

## なぜこの形か

- リポジトリのproviderは **interface側（domain層）に `UnimplementedError` で定義**し、
  main.dart で実装を `overrideWithValue` する。テスト時に同じ口からフェイクを注入するため
- UseCaseは `Ref` を持ち、リポジトリへのアクセスを **getter** に切り出す（既存コードの統一様式）
- DB書き込み後に `updateDBCountNotifier.incrementState()` を呼ばないと **UIが更新されない**
  （全ページがこのカウンタをwatchして再フェッチする設計）

## 配置と命名の対応表

| 層 | パス | 命名 |
|---|---|---|
| entity | `lib/domain/db/<entity>/<entity>_entity.dart` | `XxxEntity`（@freezed） |
| repository IF + provider | `lib/domain/db/<entity>/<entity>_repository.dart` | `XxxRepository` / `xxxRepositoryProvider` |
| repository 実装 | `lib/repository/<entity>_repository.dart` | `ImplementsXxxRepository` |
| usecase | `lib/application/<feature>/<feature>_usecase.dart` | `XxxUsecase` / `xxxUsecaseProvider` |
| 画面状態 | `lib/view_model/state/<page>/` | ページ単位のディレクトリ |
| UI | `lib/view/<page>/` | 既存ページの構成に合わせる |

## 手順

### 1. entity（@freezed）

```dart
// lib/domain/db/my_entity/my_entity.dart
@freezed
class MyEntity with _$MyEntity {
  const factory MyEntity({required int id, required String name}) = _MyEntity;
  factory MyEntity.fromJson(Map<String, dynamic> json) => _$MyEntityFromJson(json);
}
```

### 2. build_runner（entity作成・変更のたびに必須）

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. repository interface + provider（domain層）

```dart
// lib/domain/db/my_entity/my_entity_repository.dart

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final myEntityRepositoryProvider = Provider<MyEntityRepository>(
  (_) => throw UnimplementedError("MyEntityRepositoryの実装がされていません。"),
);

/// 〇〇に関するリポジトリ
abstract interface class MyEntityRepository {
  Future<List<MyEntity>> fetchAll();
  Future<void> insert(MyEntity entity);
}
```

### 4. repository 実装

```dart
// lib/repository/my_entity_repository.dart
class ImplementsMyEntityRepository implements MyEntityRepository {
  @override
  Future<void> insert(MyEntity entity) async {
    await DatabaseHelper.instance.insert('my_table', entity.toJson());
  }
}
```

- テーブル名・カラム名は文字列を直書きせず `lib/model/table_calmn_name.dart` の定数を使う

### 5. main.dart に override を登録（漏れると実行時 UnimplementedError）

```dart
// main() の ProviderScope overrides: に追記
myEntityRepositoryProvider.overrideWithValue(ImplementsMyEntityRepository()),
```

### 6. usecase

```dart
// lib/application/my_feature/my_feature_usecase.dart
final myFeatureUsecaseProvider = Provider<MyFeatureUsecase>(MyFeatureUsecase.new);

class MyFeatureUsecase {
  MyFeatureUsecase(this._ref);
  final Ref _ref;

  MyEntityRepository get _repository => _ref.read(myEntityRepositoryProvider);

  UpdateDBCountNotifier get _updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  Future<void> addData(MyEntity entity) async {
    await _repository.insert(entity);
    _updateDBCountNotifier.incrementState(); // ★これを忘れるとUIが更新されない
  }
}
```

### 7. UI接続（読み取り側）

```dart
final myDataProvider = FutureProvider<List<MyUIValue>>((ref) async {
  ref.watch(updateDBCountNotifierProvider); // DB変更で再フェッチ
  return await ref.read(myFeatureUsecaseProvider).fetchUIData();
});
```

- UIに返すのは生のentityではなく `lib/domain/ui_value/` のUIモデル

## 新しいDBテーブルを伴う場合（手順1の前に）

1. **必ず公式テーブル設計書を先に確認**: `/Users/puruwo/dev/家計簿/設計書/テーブル設計書/`
2. `lib/model/sql_on_create.dart` に CREATE TABLE を追加
3. `lib/model/database_helper.dart` の `_databaseVersion` をインクリメント
4. 既存ユーザー向けに `lib/model/sql_on_update.dart` へマイグレーションを追加
5. `lib/model/table_calmn_name.dart` に定数を追加

## 完了チェックリスト

- [ ] build_runner 実行済み（`*.freezed.dart` / `*.g.dart` が生成されている）
- [ ] main.dart に `overrideWithValue` 登録済み
- [ ] DB書き込み後の `incrementState()` 呼び出しあり
- [ ] 色は `context.colors.*`（kakeibo-design-tokens）、UIは共通widget優先（kakeibo-common-components）
- [ ] Provider追加分を `lib/docs/providers.csv` に同期（update-providers-csv）
- [ ] `flutter analyze` エラー0件
