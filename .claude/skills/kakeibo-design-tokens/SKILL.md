---
name: kakeibo-design-tokens
description: kakeiboアプリで色を扱うすべての作業に適用する。新しい色トークンを追加するとき、既存機能のUIを編集・実装するとき、色をハードコードしそうになったとき、ライト/ダーク対応の色を扱うときは必ずこのスキルに従う。「色を追加」「テーマ色」「context.colors」「ハードコード色」「ThemeExtension」「tokens.json」に関わる作業で使用する。design-tokens/tokens.json（単一ソース）→ tool/generate_tokens.dart → AppColors(ThemeExtension) の流れ、#RRGGBBAA→0xAARRGGBB のアルファ変換規則、const TextStyle / CustomPainter での例外パターンを定義する。
---

# kakeibo デザイントークン運用

## 大原則

- 色の単一ソースは `design-tokens/tokens.json`。**ここ以外に色値を書かない。**
- アプリコードからは `context.colors.<token>` で参照する。`Color(0x...)` や `Colors.*` を直接書かない。
- `lib/theme/app_colors.dart` は**生成物**。手で編集しない（`tool/generate_tokens.dart` が生成する）。
- 色以外のデザイン値（角丸・寸法・フォント・タイポグラフィ）も tokens.json の **`global` セット**が単一ソース。
  Figma側のVariables/スタイルはここから生成する。値を変えるときは tokens.json を先に直し、
  対応するFlutter側定数（`appCardRadius` / `InputPageWidgetSize` / `AppTextStyles` 等）と一致させる
  （`global` セットは現状コード生成対象外のため、コード側は手動同期）。

## 新しい色を追加する手順

1. **tokens.json に追加**
   - ブランド/ドメインの素値 → `primitive` セット
   - 意味を持つ色 → `light` と `dark` の両方に同じ名前で追加（値はモード別）
   - 命名は意味ベースの kebab-case（例: `surface-elevated`, `text-secondary`）。
     見た目ベースの名前（`red`, `lightGray` 等）にしない
   - ライト値: Appleのsemantic colorに対応するものは公式ライト値を使う。
     それ以外は値を決めた上で「白背景での見え方の視覚確認が必要」とメモを残す
2. **再生成**: `dart run tool/generate_tokens.dart`
3. **検証**: 半透明色は `#RRGGBBAA` → `0xAARRGGBB`（アルファ先頭）に正しく変換されているか確認。
   例: `#EBEBF599` → `Color(0x99EBEBF5)`
4. **使用**: `context.colors.<camelCaseToken>`（kebab→camel。例 `on-primary` → `onPrimary`）
5. `flutter analyze` を通す
6. （Figma運用時）Tokens Studio for Figma で `tokens.json` を同期

## 既存UIを編集・実装するときのルール

- 色は必ず `context.colors.*` を使う。必要な色が無ければハードコードせず、上の「新しい色を追加する手順」で足す。
- **移行期は `themeMode = ThemeMode.dark` 固定。** 勝手に system / light へ変えない
  （未移行のハードコード色と混在して見た目が壊れるため）。
- 旧 `MyColors.*` を見つけたら、対応する `context.colors.*` へ置き換える（マッピングは `docs/design/` を参照）。

## 例外パターン（context が使えない場所）

### const TextStyle
ThemeExtension は実行時解決なので `const` の中に入れられない。
- **対応A（推奨）**: `TextStyle` を `const` にせず、使用箇所で `.copyWith(color: context.colors.text)` を当てる
- **対応B**: どうしても `const` が必要な箇所は `AppColors` の static const 逃げ道クラス（ダーク値）を使う。
  ただしモード切替に追従しない点に注意

### CustomPainter
Painter は `context` を持たない。色は Widget 側（context あり）から constructor で渡す。
```dart
CustomPaint(
  painter: ChartPainter(
    separator: context.colors.separator,
    income: context.colors.income,
  ),
)
```
Painter 内部に `Color(0x...)` を直書きしない。

## 禁止事項

- `app_colors.dart` の手編集（生成物）
- `tokens.json` 以外での色値定義
- `context.colors` で表現できる色のハードコード
- 移行が未完了のうちに `themeMode` を system にすること