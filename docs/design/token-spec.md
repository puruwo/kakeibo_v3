# セマンティックトークン仕様（フェーズ0 完了）

> 色監査（2026-06-06）＋設計判断に基づく確定仕様。`semantic-token-blueprint-draft.md` を置き換える。
> これを入力として STEP5（tokens.json生成）へ進んだ。**フェーズ0（実装まで）完了（2026-06-11）— §0参照。**
>
> **確定した方針**
> - 汎用セマンティック体系（surface/text/border/primary 等）
> - ライト/ダーク両対応
> - ドメイントークン採用（expense/income）。error/success は必要時に別途追加
> - ライト値 = Apple公式ライトモード値（ダークがApple由来のため整合）
> - 未使用定数（0参照）は削除、linkColorは `color.link` に昇格
> - フィル/ラベル4段階は維持、`jet`（完全透明用途のみ）はトークン化しない
>
> **値の出典**
> - ダーク = 既存コードの値（視覚的後退を避けるため現状維持。Apple公式ダークと一致）
> - ライト = Apple公式ライト値（出典: ColorCompatibility / Apple UIKit semantic colors）
> - `🔸` = Apple非準拠のブランド/ドメイン/独自色。ライト値は暫定（ライト背景での見え方を実機で要確認）

色値は8桁HEX（`#RRGGBBAA`）で表記。

---

## 0. フェーズ0 ステータス：**完了**（2026-06-11 更新）

設計→デザイン→実装 自動化パイプライン **フェーズ0（デザイントークンの単一ソース化）は完了**。

- ✅ `design-tokens/tokens.json` → `tool/generate_tokens.dart` で `lib/theme/app_colors.dart` を生成（`AppColors` ThemeExtension ＋ const TextStyle 用の静的クラス `AppColorsDark` / `AppColorsLight`）
- ✅ `MaterialApp` に light/dark テーマと `AppColors` を接続（当面 `themeMode.dark` 固定）
- ✅ 旧 `MyColors`（`lib/constant/colors.dart`）を**全廃・ファイル削除**。UI色は **ThemeExtension に一本化** — `context.colors.*`（ランタイム）／`AppColorsDark.*`（const文脈）／`CategoryPalette.*`（データ色）
- ✅ 色ハードコード検出フック（`scripts/check_hardcoded_color.sh` + PostToolUse）を導入
- ✅ ダーク見た目は従来と不変（値同一マッピングを原則。意図的な例外は下表 `mintBlue→income` のみ）

### 決定3（カテゴリーデータ色）：**確定** ✅
- カテゴリーのデータ色を `CategoryPalette`（`lib/theme/category_palette.dart`、tokens.json の `category` セットから生成）で**トークン化**
- DB文字列⇄`Color` の変換ヘルパーを `MyColors` から `ColorCode`（`lib/util/color_code.dart`）に**分離**（ロジック不変）
- 消費側（color_select_dialog のスウォッチ／`sql_on_create` のシード／固定費定数／予測グラフ注入）を `CategoryPalette` 参照へ
- **DB無影響**：シードの6桁HEXは全て従来値と**バイト一致を機械確認**（`expense1Hex='FF7171'` 等）。既存DBの保存値も不変

### バケットB（少数参照ニュートラル等）：確定マッピング
| 旧 MyColors | 値(dark) | 移行先 | 移行先値(dark) | 備考 |
|---|---|---|---|---|
| `white` | #FFFFFF | `onPrimary` / `text` | #FFFFFF | 主色/色付き背景上→`onPrimary`、surface前景→`text`（dark同値・差はlight時のみ顕在化） |
| `black` | #000000 | `surface` | #000000 | Dismissible背景・プレースホルダ等 |
| `systemGray2` | #636366 | `textSecondary` / `icon` | #EBEBF5 60% / #8E8E93 | 用途別（テキスト→textSecondary / アイコン→icon。実際の5箇所は全てアイコン→`icon`）。※意味優先のため厳密な値一致ではない |
| `systemGray5` | #2C2C2C | `fillOpaque` | #2C2C30 | 確認ダイアログ背景。※僅差（下位1バイト） |
| `mintBlue` | #36C5F1 | `income` | #21D19F | **★色変更を伴う（#36C5F1 → #21D19F、承認済み）**。カレンダーの土曜/収入色 |

> バケットBは `systemGray2`/`systemGray5` の意味優先の寄せ（僅かな値差）と `mintBlue→income` の意図的色変更を含む。`white`/`black` はダークで値同一。

### Painter（6c-2）
`annual_balance_chart_painter` / `prediction_graph_painter` 内のバケットA色は、コンストラクタ引数（`final Color`）注入＋Widget側で `context.colors.*` を渡す方式に移行（const TextStyle は対象外）。

---

## 1. プリミティブ層（ブランド/ドメインの素値・モード非依存）

| プリミティブ | 値 | 用途 |
|------------|-----|------|
| `brand.teal` | `#0BB283FF` | ブランド主色（旧themeColor） |
| `brand.teal-subtle` | `#D7FFF4FF` | 主色の淡色（旧themeThinColor）🔸 |
| `domain.red` | `#FF7171FF` | 支出（旧pink）🔸 |
| `domain.green` | `#21D19FFF` | 収入（旧incomeEmerald）🔸 |

> Apple由来のニュートラル/背景/フィル/ラベルは、モードで値が変わるためプリミティブ単独では持たず、
> セマンティック層で light/dark を直接定義する（下記）。

---

## 2. セマンティック層（UIコードが参照する層）

### ブランド / アクセント

| トークン | light | dark | 置き換え対象（旧名・参照数） |
|---------|-------|------|--------------------------|
| `color.primary` | `#0BB283FF` 🔸 | `#0BB283FF` | themeColor(28), blackmint(0), buttonPrimary(1) |
| `color.on-primary` | `#FFFFFFFF` | `#FFFFFFFF` | 主色上の白文字 |
| `color.primary-subtle` | `#D7FFF4FF` 🔸 | `#D7FFF4FF` | themeThinColor(1) |

### 面（背景）

| トークン | light | dark | 置き換え対象 |
|---------|-------|------|------------|
| `color.surface` | `#FFFFFFFF` | `#000000FF` | systemBackground(2) |
| `color.surface-elevated` | `#F2F2F7FF` | `#1C1C1EFF` | secondarySystemBackground(19) |
| `color.surface-elevated-2` | `#FFFFFFFF` ⚠️ | `#2C2C2EFF` | tertiarySystemBackground(8), ハードコード#2C2C2E(2) |

> ⚠️ Appleの非グループ背景はライトで base/tertiary が共に白になり、3段階の差が潰れる。
> 3段階の段差をライトでも維持したい場合は、`surface-elevated-2` ライト値を `#F2F2F7FF` にするか、
> グループ背景スタック（#F2F2F7 / #FFFFFF / #F2F2F7）の採用を検討。要判断。

### フィル（カード・入力・チップ・スケルトン）

| トークン | light | dark | 置き換え対象 |
|---------|-------|------|------------|
| `color.fill` | `#78788033` | `#7878805B` | systemfill(3) |
| `color.fill-secondary` | `#78788028` | `#78788051` | secondarySystemfill(16) ← 入力欄 |
| `color.fill-tertiary` | `#7676801E` | `#7676803D` | tirtiarySystemfill(17) ← スケルトン・選択 |
| `color.fill-quaternary` | `#74748014` | `#76768039` | quarternarySystemfill(15) ← カード |
| `color.fill-opaque` | `#EFEFF0FF` 🔸 | `#2C2C30FF` | quarternarySystemfillOpaque(4) |

### テキスト

| トークン | light | dark | 置き換え対象 |
|---------|-------|------|------------|
| `color.text` | `#000000FF` | `#FFFFFFFF` | label(25), white(文字用途) |
| `color.text-secondary` | `#3C3C4399` | `#EBEBF599` | secondaryLabel(44) |
| `color.text-tertiary` | `#3C3C434C` | `#EBEBF54C` | tirtiaryLabel(2) |

> quarternaryLabel(0参照)は削除。

### 罫線・区切り

| トークン | light | dark | 置き換え対象 |
|---------|-------|------|------------|
| `color.separator` | `#3C3C4349` | `#54545899` | separater(41) |

### ドメイン色（収支）

| トークン | light | dark | 置き換え対象 |
|---------|-------|------|------------|
| `color.expense` | `#FF7171FF` 🔸 | `#FF7171FF` | pink(支出用途 21) |
| `color.income` | `#21D19FFF` 🔸 | `#21D19FFF` | incomeEmerald(8) |

> 🔸 ライト背景では `#FF7171`（明るい赤）・`#21D19F`（ティール緑）ともにコントラストが弱い可能性。
> テキスト用途で使う場合は要確認。必要なら濃色のライト変種を別途定義。

### 状態・インタラクション

| トークン | light | dark | 置き換え対象 |
|---------|-------|------|------------|
| `color.icon` | `#8E8E93FF` | `#8E8E93FF` | systemGray(7) ※両モード同値 |
| `color.disabled` | `#D1D1D6FF` | `#3A3A3CFF` | systemGray4(3) |
| `color.overlay` | `#00000033` 🔸 | `#00000033` | hoverColor(1) |
| `color.link` | `#007AFFFF` | `#0A84FFFF` | linkColor(新規有効化) |
| `color.handle` | `#C7C7CCFF` 🔸 | `#D9D9D9FF` | barHandler(1) |

> 残りニュートラル（systemGray2/5 等の少数参照）は、置き換え時に `color.icon` / `color.disabled` /
> `color.text-*` のいずれかに寄せる。対応はSTEP6の置換マッピングで個別に決める。

---

## 3. 【決定3・確定 ✅】データ色（カテゴリーパレット）

UIクロームではなくDBデータ（`color_code`）。**`CategoryPalette`（`lib/theme/category_palette.dart`、
tokens.json の `category` セットから生成）でトークン化済み**。旧 `MyColors` 定数との二重保持は解消。
変換ヘルパーは `ColorCode`（`lib/util/color_code.dart`）に分離（ロジック不変・**DB無影響＝シードのバイト一致を機械確認**）。
詳細は §0「フェーズ0 ステータス＞決定3」を参照。

- 支出パレット(8): `#FF7171 #FB5B01 #3DD8E0 #4BA6FF #BB87FF #DF2828 #FFC700 #AC3E00`（`CategoryPalette.expense1..8`）
- 収入パレット(4): `#21D19F #10B981 #059669 #6EE7B7`（`CategoryPalette.income1..4`）
- 固定費: `#8E8E93`（全カテゴリー同色 / `CategoryPalette.fixedCost`）
- DB保存用6桁HEX定数も併記（`CategoryPalette.expense1Hex='FF7171'` 等）— シード/注入はこれを参照

---

## 4. 【決定6・未確定】共同（カップル）アクセント

Confluence未決事項「共同カラーパレットの具体的な色設計」と合流させて決める。
決まったら `color.couple-accent` 等としてセマンティック層に追加。**STEP5では保留**。

---

## 5. ライト値の実機確認リスト（🔸）

Apple準拠でない以下は、ライト背景での見え方を実機/Figmaで確認し、必要なら調整：

- `color.primary` `#0BB283` — 白背景上のボタン/文字コントラスト
- `color.primary-subtle` `#D7FFF4` — 白背景でほぼ視認不可の懸念。ライトは別値が必要な可能性大
- `color.expense` `#FF7171` / `color.income` `#21D19F` — 白背景上のコントラスト（特に文字）
- `color.fill-opaque` ライト `#EFEFF0` — 暫定。実際の用途（年間収支グラフのグラデ等）で確認
- `color.overlay` `#000000` 20% — ライトでは妥当。ダークでは白オーバーレイの方が自然な場合あり
- `color.handle` ライト `#C7C7CC` — 白背景で見えるグレーか確認
- `color.surface-elevated-2` ライト（⚠️ 上記）— 3段階の段差維持の判断

---

## 6. 進捗と残課題

**完了（フェーズ0）**:
- STEP5: `tokens.json` 生成 ✅
- STEP6: `lib/theme/` 生成 ＋ MaterialApp に light/dark 接続 ＋ 旧 `MyColors.*` 全置換（約400箇所）＋ `colors.dart` 削除 ＋ ハードコード色 検出hook ✅
- 決定3（カテゴリーパレット）確定・実装 ✅（§0・§3）
- バケットB（少数参照ニュートラル）の用途別移行 ✅（§0）／ Painter注入 ✅

**残課題（次フェーズ）**:
1. **ライト有効化（6c-3b）**: const TextStyle 内の `AppColorsDark.*` 直参照を剥がす（context依存化）→ `themeMode.system` へ切り替え。併せて §5 の🔸（ライト値の実機確認）と §2「面」⚠️（surface 3段差）を確定
2. **決定6（共同カラーパレット）**: Confluence未決事項と合流し `color.couple-accent` 等を確定 → `tokens.json` 追加（§4）
3. **Figma生成の自動化**: `tokens.json` ⇄ Figma変数 の同期、画面デザイン生成の自動化