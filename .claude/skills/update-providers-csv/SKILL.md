---
name: update-providers-csv
description: >
  kakeiboプロジェクトのProviderを追加・修正・削除したとき、
  lib/docs/providers.csvを最新状態に同期するルールを定義する。
  Providerファイルを変更するときは必ずこのSkillに従うこと。
---

# providers.csv 更新ルール

## 対象ファイル

`lib/docs/providers.csv`

Providerに関わるファイルを変更した場合、作業完了前に必ずこのCSVを更新する。

---

## 更新が必要なタイミング

| 操作 | 対応 |
|------|------|
| Providerを新規追加 | CSVに1行追加 |
| Provider名を変更 | CSVの `provider_name` を更新 |
| 返り値の型を変更 | CSVの `return_type` を更新 |
| Provider型を変更（例: StateProvider→NotifierProvider） | CSVの `provider_type` を更新 |
| `family` / `autoDispose` / `keepAlive` を変更 | 対応する列を更新 |
| ファイルを移動・リネーム | CSVの `file_path` を更新 |
| 依存するProviderを変更 | CSVの `dependencies` を更新 |
| Providerを削除 | CSVから該当行を削除 |

---

## CSVの列定義

| 列名 | 内容 |
|------|------|
| `provider_name` | Provider変数名（例: `expenseRepositoryProvider`） |
| `provider_type` | Provider種別（`Provider` / `NotifierProvider` / `AutoDisposeNotifierProvider` / `FutureProvider` / `AsyncNotifierProvider` / `StateProvider`） |
| `return_type` | 返り値の型（例: `Map<int, int>` / `List<ExpenseEntity>`） |
| `layer` | アーキテクチャ層（`Repository` / `Service` / `Usecase` / `GlobalState` / `State` / `AsyncData` / `MiddleProvider`） |
| `family` | `.family` 修飾子の有無（`true` / `false`） |
| `auto_dispose` | `.autoDispose` 修飾子の有無（`true` / `false`） |
| `keep_alive` | `keepAlive: true` の有無（`true` / `false`） |
| `file_path` | 定義元の `.dart` ファイルパス（`.g.dart` は記載しない） |
| `summary` | 日本語での概要（1行） |
| `dependencies` | 依存するProvider名を ` / ` 区切りで列挙 |

---

## layer の判断基準

| layer | 対象 |
|-------|------|
| `Repository` | DBアクセスの抽象インターフェース（main.dartでDI注入されるもの） |
| `Service` | ドメインサービス・期間計算など純粋なビジネスロジック |
| `Usecase` | ユースケース（複数リポジトリを束ねる処理） |
| `GlobalState` | アプリ全体で共有する状態（日付スコープ・DBカウンター等） |
| `State` | 特定画面・入力フォーム専用の状態（入力コントローラー・編集フラグ等） |
| `AsyncData` | DBから非同期でデータ取得する `FutureProvider` / `AsyncNotifierProvider` |
| `MiddleProvider` | 日付スコープを解決して別Providerに渡す中間プロバイダー |

---

## 注意事項

- `file_path` は `.g.dart` ではなく定義元の `.dart` を記載する
- `return_type` に `,` が含まれる場合（例: `Map<int, int>`）、CSVのセルをダブルクォートで囲む必要はなく、カンマを含まない表記（例: `Map<int int>`）で記載する
- `dependencies` が複数ある場合は ` / ` で区切る（カンマ不使用）
