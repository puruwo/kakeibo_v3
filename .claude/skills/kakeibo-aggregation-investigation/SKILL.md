---
name: kakeibo-aggregation-investigation
description: >
  kakeiboアプリの集計ロジック（支出・収入・固定費の合計値計算）を調査・仕様化・修正するときの検証ルール。
  「この画面の支出に何が含まれているか」を判定する作業、Confluenceへの集計仕様化、
  集計ロジックを含むuse case／repositoryの修正、
  subagentに集計関連の調査を依頼するときは必ずこのSkillに従うこと。
---

# kakeibo 集計ロジック調査ルール

## このSkillが必要な背景

kakeiboアプリの集計ロジックには、メソッド名やusecase層のコードからは判別できない
「**SQL層に埋め込まれた給与/ボーナス/固定費フィルタ**」が複数存在する。

過去に「日次支出サマリー画面はボーナスを含む」と誤って整理してしまった事故が発生した。
原因は **リポジトリメソッドのSQLを読まずに、メソッド名と呼び出し元から推測した** こと。

このSkillは同じ間違いを繰り返さないための調査・検証ルールを定める。

---

## 重要原則

### 原則1：集計範囲はSQLのWHERE句で確定する

- リポジトリメソッドの「集計範囲」を **メソッド名・引数・呼び出し元から推測してはいけない**
- 必ず **実装SQLのWHERE句を自分の目で読む**
- 同じテーブル（例：`expense`）にアクセスするメソッドでも、メソッドごとに異なるフィルタが入っていることがある

### 原則2：subagentの「ロジック調査結果」は検証してから採用する

- `Explore` 等のsubagentが返す調査レポートは **概要把握用** として読み、
  仕様書に反映する前に必ずSQL層まで自分で再確認する
- 特に「〇〇のみ」「△△は含まない」といった集計範囲の記述は、
  どのレベル（SQL/Dart）で除外されているかを必ず特定する

### 原則3：中間プロバイダのフィールド分離設計を読み飛ばさない

- usecase層では「給与由来」「ボーナス由来」「確定済み固定費」「未確定固定費」を
  **別フィールド**として保持している中間プロバイダがある
- 利用側コードで「全フィールドを合算しているか／一部だけ合算しているか」を
  fold/sum 単位で確認する

---

## 集計ロジック調査の必須手順

集計値（合計支出・カテゴリー別合計など）を画面に表示するロジックを調査するときは、
以下を **すべて** 実施すること。一段階でも省略すると判断を誤る可能性が高い。

### Step 1: 画面 → ViewModel/Provider まで辿る

画面で表示している値が、どのProvider／Notifierから来ているかを特定する。

### Step 2: ViewModel/Provider 内の合算ロジックを読む

- どのフィールドを `fold` / `sum` / `+` で足しているか
- 足していないフィールドは何か
- 中間プロバイダ（例: `historicalTransactionNotifierProvider`）が
  「給与」「ボーナス」「固定費」を別フィールドで持っている場合、
  **どのフィールドが合算対象に入っているか** を1つずつ確認

### Step 3: 各フィールドのデータソース（usecase/repository）を辿る

- usecase層から呼ばれているリポジトリメソッドを特定する
- メソッド名だけで判断しない。**実装ファイル**を開く

### Step 4: SQLのWHERE句を直接読む

リポジトリ実装ファイル（`lib/repository/*.dart`）を開き、
対象メソッドのSQL文字列を読む。確認すべきポイント：

- `WHERE income_source_big_category = ?` 句の有無と値
  - `incomeSourceIdSalary` → 給与由来のみ
  - `incomeSourceIdBonus` → ボーナス由来のみ
  - フィルタなし → 給与・ボーナス両方
- 対象テーブル（`expense` / `fixed_cost_expense` / `income`）
- `UNION ALL` で複数テーブルを結合していないか
- 動的SQLの場合は引数に応じて WHERE 句がどう変わるか

### Step 5: テーブル単位で含む/含まないを表にまとめる

調査結果は以下のフォーマットでまとめる：

| 画面・要素 | 一般支出（給与） | 一般支出（ボーナス） | 確定済み固定費 | 未確定固定費 |
| --- | :---: | :---: | :---: | :---: |
| 画面名 | 含む/含まない | 含む/含まない | 含む/含まない | 含む/含まない |

「含む」「含まない」の判定根拠（SQL行番号 or fold処理の行番号）も
**ファイルパス:行番号** 形式で記録する。

---

## 集計ロジックを修正するときの追加ルール

リポジトリやusecaseのメソッドを修正する場合：

1. 修正対象メソッドの **すべての呼び出し元** を `grep` で確認する
   - 同じメソッドが複数の画面から呼ばれている可能性が高い
   - フィルタを変更すると無関係な画面まで挙動が変わる
2. 影響を受ける画面を一覧化し、それぞれの仕様（含む/含まない）と整合するか確認
3. 必要なら新しいメソッドを追加し、既存メソッドは触らない選択も検討する

---

## subagentに調査を依頼するときの指示テンプレ

`Explore` などにkakeiboの集計ロジックを調査させる場合、以下を **必ず** プロンプトに含める：

```
重要な調査ルール:
- リポジトリメソッドの集計範囲をメソッド名から推測しないこと
- 必ず lib/repository/*.dart の実装ファイルを開き、SQLのWHERE句を読むこと
- WHERE income_source_big_category = の値を確認し、
  「給与のみ／ボーナスのみ／両方」のいずれかを明記すること
- usecase層で fold/sum している場合は、どのフィールドが合算対象に入っているかを確認すること
- 中間プロバイダ（例: historicalTransactionNotifierProvider）が
  expenses / bonusExpenses / confirmedFixedCosts / unconfirmedFixedCosts などの
  別フィールドを持っている場合、それぞれが合算対象に入っているかを確認すること

報告フォーマット:
| 画面・要素 | 一般支出（給与） | 一般支出（ボーナス） | 確定済み固定費 | 未確定固定費 |
判定根拠としてファイルパス:行番号を明記すること
```

調査結果を受け取ったあとも、仕様書反映前に **自分でSQLを再確認する**。

---

## kakeibo固有のフィルタ位置ガイド

調査時に確認すべき主要箇所。SQLのWHERE句や fold ロジックがあるファイル一覧。

### 一般支出（expenseテーブル）にアクセスするメソッドのフィルタ

ファイル: `lib/repository/expense_repository.dart`

| メソッド名 | フィルタの有無 | フィルタ内容 |
| --- | --- | --- |
| `fetchDailyExpenseByPeriod` | あり | `income_source_big_category = incomeSourceIdSalary` （給与のみ） |
| `fetchDailyExpenseListByDate` | あり | `income_source_big_category = incomeSourceIdSalary` （給与のみ） |
| `fetchTotalExpenseByPeriodWithBigCategory(bigId)` | あり（引数依存） | 引数の `bigId` でフィルタ |

> 上記は調査時点のスナップショット。新規メソッド追加・既存メソッド修正により変わるため、
> 必ず最新のコードを開いて確認すること。

### 中間プロバイダのフィールド分離（合算対象の判定が必要）

ファイル: `lib/application/expense_history/historical_transaction_usecase.dart`

`historicalTransactionNotifierProvider` が返す `HistoricalAllTransactionsValue` は
以下を **別フィールド** で保持する：

- `expenses` （給与由来の一般支出のみ。`incomeSourceIdSalary` で取得）
- `bonusExpenses` （ボーナス由来の一般支出）
- `incomes` / `bonusIncomes`
- `confirmedFixedCosts` / `unconfirmedFixedCosts`

このプロバイダを利用するViewModel/Providerは、
**どのフィールドを合算しているか** を1つずつ確認すること。
（例: `resolved_daily_expense_summary_provider.dart` は `expenses` のみ合算し、
`bonusExpenses` は合算していない → ボーナス除外）

### カテゴリー別集計

ファイル: `lib/repository/category_repository.dart`

`CategoryAccountingRepository` の SQL は `expense` テーブルのみを対象とし、
`income_source_big_category` を引数で受け取る設計。

---

## 集計仕様化（Confluence記述）前のチェックリスト

集計仕様をConfluenceに書く前に、以下をすべて確認する。

- [ ] 画面 → Provider → usecase → repository → SQL の全パスを辿った
- [ ] SQLのWHERE句を実際に開いて読んだ（grep結果だけで判断していない）
- [ ] usecase/Provider層の fold/sum の対象フィールドを1つずつ確認した
- [ ] 「含む／含まない」の表に、根拠ファイルパス:行番号を併記できる
- [ ] subagentの調査結果を採用する場合、SQL層まで自分で再確認した
- [ ] 同じテーブルにアクセスするメソッドが複数ある場合、それぞれのフィルタを区別している

すべてチェックできない場合、Confluenceへの仕様化は **保留** し、追加調査を行うこと。
