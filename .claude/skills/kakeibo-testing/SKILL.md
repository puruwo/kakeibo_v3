---
name: kakeibo-testing
description: >
  kakeiboのテスト構築ルール（ポインタ版）。
  正本はユーザーグローバルの ~/.claude/skills/kakeibo-testing/SKILL.md。
  テストを書くとき・Fakeを触るとき・「テストを書いて/直して」と依頼されたときは
  正本を必ず読んで従うこと。
---

# kakeibo テスト構築ガイド（ポインタ）

**正本はユーザーグローバル**:

```
~/.claude/skills/kakeibo-testing/SKILL.md
```

> [!info] 経緯（2026-08-11）
> 当初は本ファイル（リポジトリ版）が正でグローバル側がポインタだったが、
> ユーザー判断でテスト関連Skillを `~/.claude` へ統合し、関係を反転した。

このリポジトリでテストを書く・直す・Fakeを触るときは、必ず正本に従う。要旨のみ:

- 対象3層: ロジックUT（`test/util` 等）／DB結合（`test/db_integration`・本物SQL検証）／
  Widget結合（`test/widget`）。E2E・ゴールデンテストは対象外
- 基盤は `test/helper/`（fake_repositories / test_container / db_test_helper / widget_test_helper）。
  mockito等の新しいモック機構を勝手に導入しない
- 検証3点セット: `dart format`（対象ファイルのみ）→ `flutter analyze` → `flutter test` 全パス
