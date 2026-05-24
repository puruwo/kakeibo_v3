---
name: kakeibo-skill-maintenance
description: >
  kakeiboプロジェクトでの実装完了後にSkillを作成・更新するルール。
  コード変更・バグ修正・新機能実装が完了したとき、
  または「skill化してください」と言われたときは必ずこのSkillに従うこと。
---

# Skill 作成・更新ルール

## いつ実行するか

コード変更・バグ修正・新機能実装が完了した後、以下のいずれかに該当するときに実行する：

- 「skillを更新して」「skill化して」と明示的に依頼されたとき
- 実装完了後に自発的に実行してよい（ただし必須ではない）

---

## Skill化する内容の判断基準

**対象（Skill化すべき）**:

| 種類 | 判断の目安 |
|---|---|
| 今後の実装で詰まりやすいパターン | 今回バグになった原因・落とし穴・非自明な制約 |
| contextが必要な知識 | コードを読むだけでは分からない仕様・設計意図・歴史的経緯 |
| 仕様理解が必要な領域 | 集計期間の計算・DB設計・状態管理のルールなど |

**対象外（Skill化しない）**:

- 一般的な Flutter / Dart パターン（kakeibo 固有でないもの）
- コードを読めば自明な内容
- 一時的な対応や特定チケットにしか関係しない修正
- 上記の「対象」に該当するものがない場合 → **何もしない**

---

## 作成・更新の手順

### 1. 既存Skillの確認

新規作成の前に、内容が既存Skillに追記できないか確認する。

```
/Users/puruwo/dev/kakeibo/claude_workspace/.claude/skills/
├── annual-balance-chart/       # 生活収支グラフの設計・実装
├── confluence-kakeibo-spec/    # Confluence仕様書ルール
├── kakeibo-common-components/  # 共通UIコンポーネント
├── kakeibo-period-patterns/    # 集計期間計算の落とし穴集
├── kakeibo-skill-maintenance/  # (このファイル)
├── kakeibo-style-rules/        # カラー・フォント定義ルール
├── update-font-usage-csv/      # font_usage.csv 同期ルール
└── update-providers-csv/       # providers.csv 同期ルール
```

追記が適切な場合（例：既存パターン集への新パターン追加）は追記を優先する。

### 2. 作成・更新先

**プロジェクト直下のみ** を対象とする。グローバル（`~/.claude/skills/`）には作成・更新しない。

```
# ✅ 正しい場所
/Users/puruwo/dev/kakeibo/claude_workspace/.claude/skills/<skill-name>/SKILL.md

# ❌ 禁止
~/.claude/skills/<skill-name>/SKILL.md
```

### 3. フォーマット

```markdown
---
name: <kebab-case-name>
description: >
  1〜2行の説明。
  いつこのSkillを使うか（トリガー条件）を含めること。
---

# タイトル

## セクション
...
```

- 説明文の `description` には **いつ使うか（トリガーキーワードや状況）** を必ず書く
- 内容は「なぜそうするか（Why）」を中心に書く。コードを読めば分かる「何をするか（What）」は省略してよい
- 具体的な ✅ / ❌ の例コードを付けると効果が高い

---

## 判断フローチャート

```
実装が完了した
    ↓
今回の変更に「詰まりやすいパターン・仕様固有の知識」はあったか？
    ├─ No → 何もしない
    └─ Yes
          ↓
        既存のSkillに追記できるか？
          ├─ Yes → 該当Skillを編集（Edit tool）
          └─ No  → プロジェクト直下に新規作成（Write tool）
```
