# kakeibo 自動化パイプライン 引き継ぎドキュメント

> Confluence設計 → Figma → 実装 を Claude Code で自動化するプロジェクトの引き継ぎ資料。
> フェーズ0（デザイントークン単一ソース化）完了時点。以降を Claude Code で自走するための
> 全体設計・現在地・次の手順・プロンプトをまとめる。

---

## 0. このドキュメントの使い方

- リポジトリの `docs/` に置き、Claude Code セッション開始時に参照させる
- 各「プロンプト」ブロックはそのまま Claude Code に貼って使える
- 既存スキル（後述）に従わせること。特に flutter-commit-rules / git-safe-rules
- **1ステップずつ実行し、検証 → コミット → 次へ。一度に全部やらせない**

---

## 1. プロジェクトの目的

kakeibo（Flutter家計簿アプリ、現在ダークのみ、カップル/共同機能を追加開発中）で、
**壁打ち（Confluence）→ デザイン（Figma）→ 実装 のフローを Claude Code で自動化する。**
最新の Claude Code 機能（subagents / skills / hooks / MCP）を使う。

前提環境（設定済み）:
- Atlassian MCP（Confluence + Jira）。cloudId `91ae6d4d-2dee-4ec6-beb1-da91884ef1aa`、
  親ページ「カップル家計簿アプリ構想」pageId `6291465`
- Figma MCP（`get_design_context` 等）

---

## 2. 現在地：フェーズ0完了（できたこと）

**デザイントークンを単一ソース化し、約400箇所の色参照を移行、旧 `MyColors` を削除した。**
見た目はダークのままほぼ不変（意図的変更はカレンダー収入色 `#36C5F1`→`#21D19F` の1点のみ）。

### ファイル構成

| ファイル | 役割 |
|---------|------|
| `design-tokens/tokens.json` | **全色の唯一の定義元**。primitive / light / dark / category の4セット（Tokens Studio形式） |
| `tool/generate_tokens.dart` | tokens.json → Dartコード生成スクリプト（`dart run tool/generate_tokens.dart`） |
| `lib/theme/app_colors.dart`（生成物） | `AppColors`（ThemeExtension・29トークン）+ `context.colors` 拡張（const用 `AppColorsDark`/`AppColorsLight` は KP-013 で廃止） |
| `lib/theme/app_theme.dart` | ThemeData の正本 `AppTheme.light()/dark()`（Material 既定色をトークンで上書き。KP-013） |
| `lib/theme/category_palette.dart`（生成物） | カテゴリーの支出12色/収入4色/グレー（Color とDB用hex文字列。KP-012 で刷新） |
| `lib/util/color_code.dart` | hex↔Color 変換ヘルパー（旧 MyColors から分離） |
| `lib/main.dart` / `lib/app.dart` | `ThemeModeStore` の保存値を起動時に読み込み、`KakeiboApp` が `themeModeNotifierProvider` を watch して MaterialApp に渡す（既定ライト。KP-013） |
| `scripts/check_hardcoded_color.sh` + `.claude/settings.json` | ハードコード色 検出 hook |

`lib/constant/colors.dart`（旧 `MyColors`、47定数）は**削除済み**。

### 確定した決定事項

1. 汎用セマンティック体系（`surface` / `text` / `fill` / `primary` / `expense` / `income` 等の3層）
2. ライト/ダーク両対応（dark = 既存 = Apple ダーク値、light = Apple公式ライト値）
3. ドメイントークン採用（`expense`/`income`）。`success`/`error` は必要時に追加
4. カテゴリーデータ色を `CategoryPalette` でトークン化。DBの `color_code` とバイト一致＝**DB無影響**
5. 色テーマ方式は **ThemeExtension**（figma2flutter の ITokens は不採用。理由: light/dark切替が
   MaterialApp の theme/darkTheme/themeMode に相乗りでき、モードの真実が一元化されるため）

### 運用ルール（既存スキル `kakeibo-design-tokens` に記載）

- 色の単一ソースは tokens.json。それ以外に色値を書かない
- アプリからは `context.colors.<token>`。`Color(0x...)` / `Colors.*` を直書きしない
- `app_colors.dart` / `category_palette.dart` は生成物（手編集禁止）
- 半透明色の変換規則: tokens は `#RRGGBBAA`、Flutter は `0xAARRGGBB`（アルファ先頭）
- 役割テキストスタイルは `context.textStyles.*`（`AppColors` を受け取るインスタンス。KP-013）、CustomPainter は constructor で色と TextStyle を注入

---

## 3. アーキテクチャ（パイプライン全体像）

```
Confluence設計 ──▶ 画面スペック ──▶ Figma画面 ──▶ 実装設計 ──▶ 実装
   (MCP)            (text)         (Figma MCP)    (text)      (code)
```

### 工程の成熟度（重要）

| 工程 | 方向 | 自動化成熟度 |
|------|------|------------|
| Confluence設計 → 画面スペック | text→text | 高 |
| 画面スペック → Figma画面（生成） | text→visual | **低〜中**（Figmaコンポーネント前提） |
| Figma → 実装設計 | visual→text | 中〜高（Figma Dev Mode MCP） |
| 実装設計 → 実装 | text→code | 高 |

### Claude Code 機能の役割分担

| 機能 | 役割 | 配置 |
|------|------|------|
| **subagent** | 各工程の専門ワーカー（独立コンテキスト・ツール制限） | `.claude/agents/` |
| **skill** | 各工程の「どうやるか」の手順書 | `.claude/skills/` |
| **hook** | flutter analyze・ハードコード検出など決定論的強制 | `.claude/settings.json` |
| **MCP** | 外部接続（Atlassian / Figma） | 設定済み |

### オーケストレーションの原則

- **subagent は別の subagent を呼べない。** メイン会話が順番に chain する
- 1機能（Confluenceページ1つ / Figma1画面）= 1パイプライン実行。全部一度に流さない
- Figma生成と実装の各段で**人間レビューを挟む**（特にFigma生成は叩き台まで）
- Agent Teams（実験的）はソロ開発では不要（トークン3〜4倍）

---

## 4. 正直な前提と制約

- **いま即組めるのは「Figma→実装」方向。** 「Confluence→Figma生成」方向は最も未成熟で、
  かつ成立には **Figmaコンポーネントライブラリ（トークンにバインドされたボタン/入力/カード等）** が必要。
  現状あるのはトークン（tokens.json）のみで、Figmaコンポーネントは未整備
- **Figma生成は人間レビュー必須。** デザインの良し悪し・情報設計は人間の領域。自動生成は叩き台まで
- **デザイン方針そのものは自動化対象外。** カップル機能の見た目等の判断は壁打ち（Confluence）で人間が決める

---

## 5. ロードマップ（A / B / C と依存関係）

```
【フェーズ0】デザイントークン  ✅完了
        │
        ├─ A: ライトモード有効化（独立して進行可）
        ├─ B: 共同カラーパレット（決定6・要Confluence壁打ち）
        └─ C: Figma→実装パイプライン  ◀ 選択中（既存機能で構築）
              C-0 骨組み（agents/skills/hooks）
              C-1 既存Figma→実装 の検証（成熟・即価値）
              C-2 Figmaコンポーネントライブラリ整備（Confluence→Figma生成の前提）
              C-3 Confluence→Figma生成（C-2完了後）
```

A・B は C と独立。B は C-3（カップル画面生成）に効いてくる。

---

## 6. 次にやること：C（Figma→実装パイプライン）

方針: **既存機能で構築。** まず成熟した「Figma→実装」を1画面で通して検証し（C-1）、
並行で前提となるコンポーネントライブラリを整える（C-2）、その後 Confluence→Figma 生成（C-3）。

### C-0：パイプライン骨組みの整備

subagent・skill・hook を用意する。実装はまだしない。

> **✅ C-0 完了**。agents 5つ・skills 雛形3つ・CLAUDE.md 追記は 2026-06-12 実施
> （ブランチ `claude/auto-flow-training-1/pipeline-c0-skeleton`、PR #44 でdevマージ済み）。
> 残っていた 4. の dart analyze hook も同日 `.claude/settings.json` の
> `hooks.PostToolUse[0].hooks` に適用済み（構文エラーファイルで exit 2 ブロックの発火を確認）。
> `--no-fatal-warnings` により既存の warning/info ではブロックせず、エラーのみ
> exit 2 で Claude にフィードバックされる。

```
kakeibo の設計→実装 自動化パイプラインの骨組みを作る。実コードの変更はしない。

1. .claude/agents/ に以下の subagent 定義を作る（各YAML frontmatter + 指示。
   引き継ぎドキュメントの「8. subagent定義」の内容をベースにする）:
   - design-auditor（読み取り専用）
   - confluence-reader（読み取り専用）
   - figma-to-impl（読み取り専用）
   - flutter-implementer
   - figma-builder（※C-2完了まで使わないが定義だけ用意）
2. .claude/skills/ に以下の新規スキルの雛形を作る（説明と手順の骨子。
   詳細は対応工程に着手する時に詰める）:
   - confluence-to-screenspec
   - figma-to-implplan
   （figma-from-screenspec は C-2 後に作るので今回は空の雛形でよい）
3. CLAUDE.md に、これらの agents/skills と kakeibo-design-tokens スキル、
   tokens.json 運用への参照を1〜2行ずつ追記（内容は複製せず参照に留める）
4. 既存 hook（ハードコード色検出）に加え、Dart編集後の flutter analyze を
   PostToolUse hook で実行する設定が無ければ追加

完了後: 作成したファイル一覧と CLAUDE.md の差分を報告。コミット（git-safe-rules準拠）
```

### C-1：既存Figma → 実装 の検証（1画面）

成熟した方向。既存の大まかなFigmaデザイン1画面を選び、パイプラインを通す。

```
既存Figmaの1画面を対象に、Figma→実装 のパイプラインを検証する。

対象: <FigmaのURL or ノードID を1つ指定>

手順:
1. @figma-to-impl を使い、Figma MCP の get_design_context で対象ノードの
   UI構造を取得。既存 lib/ のアーキテクチャ（状態管理・ディレクトリ構成・
   共通Widget・kakeibo-design-tokens）を踏まえ、実装設計（影響範囲・新規/変更
   ファイル・使用する context.colors トークン）を出力。実装はまだしない
2. 出力された実装設計を確認（ここで人間レビュー）
3. 確認後、@flutter-implementer で実装。色は必ず context.colors.* を使い、
   ハードコードしない。flutter analyze を通す
4. flutter-commit-rules に従いコミット

注意:
- 既存の命名規則・パターンに合わせる（lib/ の類似画面を参照）
- get_design_context が返す色は、対応する context.colors トークンに読み替える
  （生のhexをそのまま使わない）
- 1画面で止める。うまくいけば横展開する
```

### C-2：Figmaコンポーネントライブラリの整備（Confluence→Figma生成の前提）

トークンをFigmaに反映し、コア部品をコンポーネント化する。ここは**人間のデザイン判断**を伴う。

```
Figma側にデザイントークンとコアコンポーネントを整備する。

1. トークンのFigma反映:
   - design-tokens/tokens.json を Tokens Studio for Figma プラグインで
     Figma Variables に取り込む手順を説明（GitHub連携での同期設定含む）
   - ※これはFigmaプラグイン側の手動操作。Claude Codeは手順提示まで
2. コアコンポーネントの洗い出し:
   - 既存アプリの頻出UI（ボタン primary/secondary、入力フィールド、カード、
     リスト項目、チップ、ダイアログ等）を lib/ から洗い出して一覧化
   - 各コンポーネントの状態（default/disabled 等）とバリアントを整理
3. （任意）Figma MCP でコンポーネントの叩き台を作成できる範囲を提案
   ※レイアウトの最終判断は人間が行う前提

完了後: コンポーネント一覧（状態/バリアント付き）と、Figma反映手順、
Claude Codeで作れる範囲/人間が決める範囲の切り分けを報告
```

### C-3：Confluence → Figma 生成（C-2 完了後）

コンポーネントが揃って初めて成立する。`figma-from-screenspec` スキルもここで詰める。

```
Confluence設計から Figma画面を生成する（C-2のコンポーネント整備が前提）。

対象Confluenceページ: <pageId を1つ>（cloudId 91ae6d4d-2dee-4ec6-beb1-da91884ef1aa）

手順:
1. @confluence-reader で設計ページを読み、画面スペック（要素/データ/状態/遷移）を出力
2. 人間レビュー
3. @figma-builder で、確立済みコンポーネント・トークンのみを使って Figma に画面を組む。
   新しい色・サイズを発明しない。コンポーネントで表現できない要素があれば止めて報告
4. 人間レビュー（レイアウトの妥当性）
5. 問題なければ C-1 の要領で実装へ

※この工程は叩き台生成。品質は C-2 のコンポーネント充実度に依存する
```

---

## 7. 並行で進められる A / B

### A：ライトモードの有効化 ✅ 完了（2026-09-11 KP-013）

トークンは両対応済みだった。KP-013 で次を実施した（詳細は Vault 案件「Kakeibo 案件 ライトモード対応とテーマ再構築」）。

1. 6c-3b: 役割スタイル4クラスを `AppColors` を受け取るインスタンスにし、呼び出し側は
   `context.textStyles.xxx` で現在のテーマの色が入ったスタイルを受け取る（`AppColorsDark.*` は廃止）
2. ライト値の視覚確認: シミュレータで主要画面を確認。面の段差はカード地トークン `card-surface`
   （ライト `#F2F2F7`）の新設で解消。`overlay` のライト値を白60%へ変更
3. ThemeData の正本 `AppTheme.light()/dark()` を新設し、Material 既定色（seed 紫）を排除
4. 既定ライト。設定画面の「ダークモード」スイッチで切替（`ThemeModeStore` に保存・起動時に事前読込）

### B：共同カラーパレット（決定6）

Confluenceの壁打ちで色方針を決めてから、トークンに追加。

```
共同（カップル）アクセント色を決めてトークン化する（決定6）。
- Confluence「共同カラーパレットの具体的な色設計」の議論を確認/壁打ち
- 決まった色を tokens.json の semantic 層に color.couple-accent 等として light/dark で追加
- 再生成し context.colors から使えるようにする
- confluence-discussion-archiver で決定を記録、整合性チェッカーを実行
```

---

## 8. subagent 定義（`.claude/agents/`）

各ファイルの frontmatter + 指示の骨子。`mcpServers` / `tools` でツールを絞る。

### design-auditor（読み取り専用）
```markdown
---
name: design-auditor
description: Figmaと既存Flutterコードのデザインドリフト（ハードコード色・命名不整合・トークン未使用）を監査する。修正はしない。
tools: Read, Grep, Glob
mcpServers: [figma]
model: sonnet
---
design-tokens/tokens.json の定義を把握し、lib/ のハードコード色や context.colors 未使用箇所、
Figmaコンポーネントの命名/バリアント不整合を検出して優先度順に報告する。修正はしない。
```

### confluence-reader（読み取り専用）
```markdown
---
name: confluence-reader
description: Confluenceの設計ページを読み、実装可能な画面スペック（要素/データ/状態/遷移）に構造化する。
tools: Read, Grep, Glob
mcpServers: [atlassian]
skills: [confluence-to-screenspec]
model: sonnet
---
指定ページを Atlassian MCP で読み、画面に必要な要素を抽出して構造化スペックを出力する。
実装判断は含めず要件構造化に徹する。
```

### figma-to-impl（読み取り専用）
```markdown
---
name: figma-to-impl
description: Figmaデザインから Flutter 実装設計を作る。既存アーキテクチャと context.colors トークンに沿った計画を立てる。実装はしない。
tools: Read, Grep, Glob
mcpServers: [figma]
skills: [figma-to-implplan, kakeibo-design-tokens]
model: sonnet
---
Figma MCP の get_design_context で UI構造を取得し、既存 lib/ のパターンに沿った実装設計
（影響範囲・新規/変更ファイル・使用トークン）を出力する。色は context.colors トークンに読み替える。実装はしない。
```

### flutter-implementer
```markdown
---
name: flutter-implementer
description: 実装設計に基づき Flutter コードを実装する。
tools: Read, Edit, Write, Bash, Grep, Glob
skills: [kakeibo-design-tokens, flutter-commit-rules, git-safe-rules]
model: sonnet
---
既存の命名規則・設計パターンに従い実装する。色は context.colors.* を使いハードコードしない。
各タスク後に flutter analyze を通す。コミットは flutter-commit-rules に従う。
```

### figma-builder（C-2完了後に使用）
```markdown
---
name: figma-builder
description: 画面スペックとデザインシステムから Figma に画面を組む。確立済みコンポーネント・トークンのみ使う。新規デザインは発明しない。
mcpServers: [figma]
skills: [figma-from-screenspec]
model: sonnet
---
既存コンポーネント・トークンだけで画面を組み立てる。スペックに無い要素を追加しない。
コンポーネントで表現できない要素があれば止めて報告する。
```

---

## 9. 追加する skill

`.claude/skills/` に作る。中身は対応工程に着手する時に詰める（C-0では雛形）。

- **confluence-to-screenspec**: Confluence設計 → 画面スペックの変換手順と出力フォーマット
- **figma-to-implplan**: Figma（get_design_context）+ 既存アーキテクチャ → 実装設計の手順。
  色はトークン読み替え、状態管理パターンの踏襲
- **figma-from-screenspec**（C-2後）: 画面スペック → Figma組み立て手順。使うコンポーネント/
  トークンの選び方、発明禁止ルール

雛形作成プロンプト例:
```
.claude/skills/figma-to-implplan/SKILL.md を作る。
description は「Figmaデザインから Flutter 実装設計を作る作業で使う」。
本文に: get_design_context の使い方、出力フォーマット（影響範囲/新規・変更ファイル/
使用する context.colors トークン）、既存 lib/ パターンの踏襲、色のトークン読み替え規則
（生hex→context.colorsの対応の見つけ方）を記載。skill-creator スキルの作法に従う。
```

---

## 10. 未決事項

- **決定6**: 共同（カップル）アクセント色（Bで確定）
- **ライト値の視覚確認**: 🔸トークン群（Aで確定）。特に surfaceElevated2 のライト段差
- **Figmaコンポーネントライブラリ**: 未整備（C-2で構築）。Confluence→Figma生成の前提
- **Firebase**: カップル機能の多くが依存。未構築（共同機能の実装時に必要）

---

## 11. これまでの原則・学び（Claude Code に守らせたいこと）

フェーズ0で有効だったやり方。次フェーズでも踏襲する。

- **機械検証を効かせる。** 「目視で値を見比べる」より、bashでバイト一致を照合する/
  定義を先に消して『残ればコンパイルエラー』の状態にして網羅を型システムに保証させる、が確実
- **一括グローバル置換をしない。** 同じ旧定数でも用途で移す先が変わる（white→onPrimary/text 等）。
  用途・場所で分けて進める
- **小さくコミット。** 1バッチ=機能ディレクトリ単位など。各コミット前に flutter analyze。
  巻き戻しと切り分けが楽になる
- **context が無い場所は注入。** enum/関数/デフォルト引数/Painter は色定数を埋め込まず、
  context を持つ呼び出し側から色を渡す
- **既存挙動・データを壊さない検証を必須に。** DB無影響（バイト一致）、見た目不変を毎回確認
- **生成物は手編集しない。** tokens.json を直して再生成
- **新規流入を hook で止める。** ハードコード色検出を常時オン
- **1機能ずつ・人間レビューを挟む。** 特にFigma生成は叩き台。一気通貫の完全自動は最後

---

## 付録: 参考プロンプト（パイプライン1機能の通し実行・C-3確立後）

```
<機能名> をパイプラインで実装する。1機能=1通し。

1. @confluence-reader: Confluenceページ <pageId> → 画面スペック
2. （人間レビュー）
3. @figma-builder: スペック + デザインシステム → Figma画面（既存コンポーネントのみ）
4. （人間レビュー：レイアウト妥当性）
5. @figma-to-impl: Figma → 実装設計
6. （人間レビュー）
7. @flutter-implementer: 実装（context.colors使用・analyze・コミット）

各段の成果物を提示し、レビュー待ちで止まること。全段を無確認で進めない。
```
