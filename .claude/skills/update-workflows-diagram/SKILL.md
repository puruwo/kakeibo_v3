---
name: update-workflows-diagram
description: >
  kakeibo Flutter アプリの Clean Architecture ワークフロー俯瞰図
  (docs/workflows/) を最新状態に保つメンテナンスルール。
  新しいフロー（機能）の追加、UseCase / Repository / DB テーブルの追加・削除・改名、
  レイヤ構造の変更を行ったときは必ずこの Skill に従うこと。
  「ワークフロー図を更新して」「workflows.html を更新して」と言われたときも従う。
---

# workflows 俯瞰図 メンテナンスルール

## 対象ファイル

```
docs/workflows/
├── flows.json       — ノード/グループ/カラム/フローの単一ソース (JSON)
└── workflows.html   — fetch + 埋込 JSON フォールバックで描画する単一HTML
```

外部ライブラリ非依存（素 SVG + バニラ JS）。`python3 -m http.server` でも `file://` 直開きでも動く。

---

## ⚠️ 最重要: 二重ソースの同期

`workflows.html` の中に **`<script type="application/json" id="workflow-data">` として `flows.json` の完全コピーが埋め込まれている**。これは `file://` 直開き時に `fetch` が失敗するため、その場合のフォールバックとして利用される。

**`flows.json` を更新したら必ず HTML 内の埋込 JSON も同じ内容に更新すること。** ズレると `http://` と `file://` で表示が変わって混乱の元になる。

### 同期検証スクリプト（更新後に必ず実行）

```bash
cd docs/workflows && python3 <<'PY'
import re, json
with open('workflows.html', encoding='utf-8') as f: html = f.read()
m = re.search(r'<script type="application/json" id="workflow-data">(.*?)</script>', html, re.S)
embedded = json.loads(m.group(1))
with open('flows.json', encoding='utf-8') as f: disk = json.load(f)
print('SYNCED' if embedded == disk else 'DIVERGED — HTMLの埋込JSONを更新せよ')
PY
```

---

## 更新が必要なタイミング

| 変更内容 | flows.json への対応 |
|---|---|
| 新しいユーザー操作フローを実装した（例: 「サブ通帳機能を追加」） | `flows[]` に新しいエントリを 1 件追加。`steps[]` で View → UseCase → Repository → DB を記述 |
| 新しい UseCase を追加 | `nodes[]` に `uc.xxx` を追加。関連フローの `steps[]` で参照 |
| 新しい Repository を追加 | `nodes[]` に `repo.xxx` を追加 |
| 新しい DB テーブルを追加 | `nodes[]` に `db.xxx` を追加 |
| 新しい View Page を追加 | `nodes[]` に `ui.xxx` を追加 |
| 新しい Domain Service を追加 | `nodes[]` に `svc.xxx` を追加 |
| UseCase/Repository をリネーム or 移動 | `nodes[].title` `subtitle` を更新。`flows[].steps[].note` のパスも追従 |
| UseCase/Repository/テーブルを削除 | `nodes[]` から該当行を削除。**該当ノードを参照する `flows[].steps[]` も削除または書き換え**（バリデーションが落ちる） |
| Clean Architecture のレイヤ構成自体を変更 | `columns[]` と `groups[]` を見直す（重い改修） |

> ❌ **してはいけない**: コードに実体のない「想像のフロー」を追加する。実装ベースで Explore してから書く。

---

## flows.json スキーマ（要約）

```jsonc
{
  "viewBox": { "w": 1500, "h": 900 },
  "columns": [{ "id":"...", "label":"...", "x":140, "divider":290 }],
  "groups":  [{ "id":"view|state|usecase|service|repository|db",
                "label":"...", "stroke":"#xxx", "fill":"#xxx", "sub":"rgba(...)" }],
  "nodes":   [{ "id":"<col>.<name>", "title":"...", "subtitle":"...",
                "group":"<groupId>", "x":..., "y":..., "w":220, "h":56 }],
  "flows":   [{ "id":"fN.xxx", "icon":"🧾", "name":"N. ...",
                "sub":"短い副題", "description":"...",
                "steps":[{ "from":"<nodeId>", "to":"<nodeId>",
                           "passes":"<実際に渡されるエンティティ/メソッド>",
                           "note":"<補足・ファイルパス>" }] }]
}
```

**ID 命名規則（守ること）**:
- ノード ID は `<columnId>.<camelCase>` 形式（例: `ui.register` / `uc.fixedCostExp` / `repo.batchHist`）
- フロー ID は `fN.<camelCase>` 形式で `name` の先頭番号と一致させる

**ステップ記述粒度**:
- `passes` には実コードで渡される値（エンティティ名・SQL・引数）を書く。「データ」のような曖昧表現はダメ
- `note` には可能ならファイルパス + 行番号を書く（例: `lib/view/register_page/submit_button.dart:149`）

---

## レイアウト・座標の指針

5 カラム構成。同じカラムのノードは縦に並べる。

| column.id | label | x 中心 | x 範囲 (w=220) |
|---|---|---|---|
| `ui` | UI · VIEW PAGES | 140 | 30〜250 |
| `uc` | APPLICATION · USECASE | 470 | 360〜580 |
| `svc` | DOMAIN SERVICE | 770 | 660〜880 |
| `repo` | REPOSITORY | 1050 | 940〜1160 |
| `db` | SQLITE TABLES | 1340 | 1230〜1450 |

- **同カラム内では y 座標を 80px 間隔で増やす**（h=56 + 余白 24px）
- **state バス** (`state.dbCount`) は UI 列右下に float（x=170, y=815, w=320, h=50）
- **新ノードを追加するときは末尾に y を伸ばすか、関連 UseCase 行と揃える** と視線移動が少ない

座標を大きく変えたら必ずブラウザで開いて目視確認すること（バッジ衝突回避は自動だが、ノードが重なる事故は防げない）。

---

## バリデーション（更新後に必ず実行）

```bash
cd docs/workflows && python3 <<'PY'
import json
with open('flows.json', encoding='utf-8') as f: d = json.load(f)
ids = {n['id'] for n in d['nodes']}
groups = {g['id'] for g in d['groups']}
errs = []
for n in d['nodes']:
    if n['group'] not in groups:
        errs.append(f"node {n['id']}: unknown group {n['group']}")
for flow in d['flows']:
    for i, s in enumerate(flow['steps']):
        if s['from'] not in ids: errs.append(f"{flow['id']} step {i+1}: from={s['from']} 未定義")
        if s['to']   not in ids: errs.append(f"{flow['id']} step {i+1}: to={s['to']} 未定義")
print(f"{len(d['nodes'])} nodes / {len(d['flows'])} flows / {sum(len(f['steps']) for f in d['flows'])} steps")
print('OK' if not errs else 'NG:\n  ' + '\n  '.join(errs))
PY
```

エラーがある状態でコミットしないこと。

---

## workflows.html を触るときの注意

HTML 側を編集する機会は少ないが、もし触る場合は以下を**絶対に変えてはいけない**。変えると視覚バグが噛む。

### 必ず守るルール

1. **SVG レイヤ順は `defs → col-layer → edge-layer → node-layer → badge-layer`**
   バッジを最後に append しないとノードにホバーが奪われて番号が反応しなくなる。

2. **往復エッジは `fromId < toId` で `±LANE` を決定的に割当**
   `A→B` と `B→A` を同じ曲線に描くとバッジが必ず一個隠れる。`buildEdgeIndex()` のロジックを壊さないこと。

3. **バッジ衝突判定は二段階**
   pill 楕円距離 + Node bbox ペナルティ + escape ループ。`findBadgePosition()` を簡略化しない。

4. **`.edge-step-pill` クラスにスコープして hit-area には CSS を当てない**
   `rect` タグ単位で hover 色を当てると透明 hit-area まで暗くなる。

5. **SVG `<g>` には `mouseover` / `mouseout` + `relatedTarget` 判定**
   `mouseenter`/`mouseleave` を直付けすると子要素経由で取りこぼす。

6. **anno-flash 再発火は `remove → li.offsetWidth 参照 → add`**
   同じ step を再クリックしたときに強制 reflow を挟まないとアニメが再生されない。

---

## 判断フロー

```
コード変更が完了した
   ↓
変更内容に該当する？
   ├─ View / UseCase / Service / Repository / DB の追加・削除・改名
   ├─ 新機能フロー（ユーザー操作のシナリオ）の追加
   └─ Clean Architecture のレイヤ構造変更
       ↓ Yes
   flows.json を編集
       ↓
   workflows.html 内の埋込 JSON を同じ内容にコピー
       ↓
   同期検証スクリプト + バリデーションスクリプトを実行
       ↓
   ブラウザで開いて目視確認（任意だが推奨）
```

該当しない（純粋なバグ修正・UI 微調整・リファクタなど）場合は更新不要。
