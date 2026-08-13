# CLAUDE.md

このリポジトリで Claude Code が作業するときのガイド。

**Kakeibo v3** — Flutter 製の家計簿アプリ（iOS のみ）。Clean Architecture + Riverpod + SQLite。

---

## 正本の所在（最重要）

**仕様・DBスキーマ・アーキテクチャ・設計判断（ADR）の正本は、このリポジトリではなく
Obsidian Vault `/Users/puruwo/kakeibo_vault/` にある。** このファイルには仕様の複製を置かない
（かつて二重管理でスキーマ・拠出元値の矛盾が発生したため一本化した。経緯は Vault の
「Kakeibo ADR-021 ドキュメントの正本をVaultに一本化する」を参照）。

| 知りたいこと | 読む場所 |
|---|---|
| 何がどこにあるか（全ページの目録） | `kakeibo_vault/Kakeibo index.md` |
| 機能仕様・画面・DBスキーマ・ビジネスロジック | index から該当ページへ（`02_features/` `03_screens/` `04_data/` `05_logic/`） |
| なぜそうなっているか（決定記録・ADR） | `kakeibo_vault/08_decisions/` |
| ブランチ・ワークツリー・dev HEAD の現在地 | `kakeibo_vault/09_sources/Kakeibo ブランチとワークツリーの現在地.md` |
| Vault 自体の運用ルール | `kakeibo_vault/CLAUDE.md` |

作業ルールは `~/.claude/skills/` の kakeibo-* Skill 群が正本:
`kakeibo-workflow`（作業フロー全体）/ `kakeibo-testing`（テスト）/ `kakeibo-style-rules`（スタイル）/
`kakeibo-simulator`（シミュレータ動作確認）/ `flutter-commit-rules`（commit）/
`git-safe-rules`（git 安全ルール）/ `testflight-deploy`（TestFlight 配信）。

---

## Development Commands

### Setup & Dependencies
```bash
# Install dependencies
flutter pub get

# Generate code (Freezed, Riverpod, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous code generation during development
dart run build_runner watch --delete-conflicting-outputs
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run with specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

### Code Quality
```bash
# Run linter
flutter analyze

# Format code
dart format .
```

### Testing
```bash
# 全テスト（ロジックUT / DB結合 / Widget結合 の3層構成。書き方の正本は kakeibo-testing Skill）
flutter test

# 層を絞って実行
flutter test test/db_integration
flutter test test/widget
```

### Build
```bash
# Build iOS（このアプリは iOS のみ）
flutter build ios
```

TestFlight への配信は `testflight-deploy` Skill（deploy スクリプト）経由で行う。

---

## Code Generation Requirements

This project heavily uses code generation. **Always run `build_runner`** after:
- Creating/modifying `@freezed` entities
- Adding/changing `@riverpod` providers
- Modifying `@JsonSerializable` classes

Generated files follow these patterns:
- `*.freezed.dart` - Freezed data classes
- `*.g.dart` - JSON serialization & Riverpod providers
- Never edit generated files manually

---

## Troubleshooting

### "Missing generated files" errors
```bash
dart run build_runner build --delete-conflicting-outputs
```

### UI not updating after data changes
- Ensure `updateDBCountNotifier.incrementState()` is called in use case
- Verify UI is watching `updateDBCountNotifierProvider`

### Database errors
- Check `lib/model/table_calmn_name.dart` for correct table/column names
- Verify schema version matches expectations
- Look for migration issues in `DatabaseHelper.onUpgrade`

### Build errors after pulling changes
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## Design Tokens & Automation Pipeline

詳細は `docs/kakeibo-pipeline-handoff.md` を参照（全体設計・ロードマップ・運用ルールの単一ソース）。

### デザイントークン

- 色の単一ソースは `design-tokens/tokens.json`。アプリからは `context.colors.<token>` を使う。運用ルールは `kakeibo-design-tokens` スキル参照
- `lib/theme/app_colors.dart` / `lib/theme/category_palette.dart` は `tool/generate_tokens.dart` の生成物（手編集禁止）

### パイプライン subagents（`.claude/agents/`）

- `design-auditor` — Figma/コードのデザインドリフト監査（読み取り専用）
- `confluence-reader` — Confluence設計 → 画面スペック構造化（読み取り専用）
- `figma-to-impl` — Figma → Flutter実装設計（読み取り専用・実装しない）
- `flutter-implementer` — 実装設計 → Flutter実装（analyze・コミットまで）
- `figma-builder` — 画面スペック → Figma画面生成（C-2完了まで使用しない）

### パイプライン skills（`.claude/skills/`）

- `confluence-to-screenspec` — 画面スペックの変換手順と出力フォーマット（雛形）
- `figma-to-implplan` — Figma → 実装設計の手順とトークン読み替え規則（雛形）
- `figma-from-screenspec` — 画面スペック → Figma組み立て手順（C-2後に整備）
