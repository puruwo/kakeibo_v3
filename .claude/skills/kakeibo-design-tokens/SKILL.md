---
name: kakeibo-design-tokens
description: kakeiboアプリで色を扱うすべての作業に適用する。新しい色トークンを追加するとき、既存機能のUIを編集・実装するとき、色をハードコードしそうになったとき、ライト/ダーク対応の色を扱うときは必ずこのスキルに従う。「色を追加」「テーマ色」「context.colors」「ハードコード色」「ThemeExtension」「tokens.json」「AppTheme」「ThemeMode」に関わる作業で使用する。design-tokens/tokens.json（単一ソース）→ tool/generate_tokens.dart → AppColors(ThemeExtension) → AppTheme(ThemeData の正本) の流れ、#RRGGBBAA→0xAARRGGBB のアルファ変換規則、役割テキストスタイル / CustomPainter での例外パターンを定義する。
---

# kakeibo デザイントークン運用

## 大原則

- 色の単一ソースは `design-tokens/tokens.json`。**ここ以外に色値を書かない。**
- アプリコードからは `context.colors.<token>` で参照する。`Color(0x...)` や `Colors.*` を直接書かない。
- `lib/theme/app_colors.dart` は**生成物**。手で編集しない（`tool/generate_tokens.dart` が生成する）。

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
- **ライト／ダークは実行時に切り替わる（KP-013）。** 既定はライトで、設定画面の「ダークモード」スイッチで切り替える。
  `lib/main.dart` は `ThemeModeStore`（SharedPreferences）の保存値を起動時に読み込む。テーマモードを固定しない。
- ThemeData の正本は `lib/theme/app_theme.dart`（`AppTheme.light()` / `AppTheme.dark()`）。
  Material 部品の既定色（Scaffold 地・Divider・カーソル・進捗・日付ピッカー等）はここで `AppColors` から与える。
  個別の Widget で `Theme(data: ThemeData(...))` を新規生成しない（`AppColors` 拡張が落ち、`context.colors` が assert で止まる）。
  部分的に上書きしたいときは `Theme.of(context).copyWith(...)` を使う。
- 旧 `MyColors.*` を見つけたら、対応する `context.colors.*` へ置き換える（マッピングは `docs/design/` を参照）。

## 例外パターン（context が使えない場所）

### 役割テキストスタイル
役割スタイル（`AppTextStyles` / `RegisterPageStyles` / `CalendarStyles` / `GraphTextStyles`）は
`AppColors` を受け取るインスタンスで、呼び出し側は `context.textStyles.<名前>`（画面専用は
`context.registerStyles` / `context.calendarStyles` / `context.graphStyles`）で現在のテーマの色が入った
スタイルを受け取る。定義側は `TextStyle get <名前> => AppTypeScale.<段>.copyWith(color: colors.<token>)` と書く。
静的色クラス `AppColorsDark` / `AppColorsLight` は廃止した（KP-013）。const 文脈で色が要る場合は
`const` を外して context から解決する。テストの期待値は `AppColors.light` / `AppColors.dark` か
固定インスタンス `AppTextStyles.light` / `AppTextStyles.dark` を使う。

### CustomPainter
Painter は `context` を持たない。色と TextStyle は Widget 側（context あり）から constructor で渡す。
```dart
CustomPaint(
  painter: ChartPainter(
    separator: context.colors.separator,
    income: context.colors.income,
    labelStyle: context.graphStyles.graphLabel,
  ),
)
```
Painter 内部に `Color(0x...)` を直書きせず、役割スタイルも Painter 内で直接参照しない。

## 禁止事項

- `app_colors.dart` の手編集（生成物）
- `tokens.json` 以外での色値定義
- `context.colors` で表現できる色のハードコード
- `AppColorsDark` / `AppColorsLight` の参照（廃止済み。`scripts/check_hardcoded_color.sh` が検出する）
- `Theme(data: ThemeData(...))` による新規 ThemeData の生成（`AppTheme` 以外で ThemeData を組み立てない）