---
name: figma-from-screenspec
description: >
  画面スペックから Figma に画面を組み立てる手順を定義する。figma-builder subagentが
  Figma画面を生成するとき、「画面スペックからFigmaを作って」と指示されたときは
  必ずこのスキルに従うこと。確立済みのkakeibo DSコンポーネント・Variablesのみを使い、
  新しいデザインを発明しない。
---

# 画面スペック → Figma組み立て

confluence-to-screenspec が出力した画面スペックを、kakeibo デザインシステムの
コンポーネントだけで Figma 画面（叩き台）に変換する手順。

## 大原則

1. **確立済みコンポーネント・トークンのみを使う。** 新しい色・サイズ・角丸・コンポーネントを発明しない
2. **Confluenceに見た目の指定が書かれていても、デザインシステムのルールが優先**（スペックから採るのは要素・データ・状態・遷移のみ）
3. **コンポーネントで表現できない要素があれば、その場で止めてギャップとして報告する**（無理に生で組まない）
4. 生成物は叩き台。**人間レビューを必ず挟む**
5. `use_figma` を呼ぶ前に **figma:figma-use スキルを必ずロード**する

## 対象ファイルと場所（固定値）

| 項目 | 値 |
|---|---|
| FigmaファイルKey | `UhV3dLrJDWKuOdG9ik4uHW` |
| コンポーネント置き場 | 「kakeibo DS」ページ（nodeId `3468:4965`） |
| 画面生成先 | 「Screen Drafts」ページ。フレーム名は `Draft/<画面名>` |
| 画面サイズ | 375 x 812（iPhone 13 mini 基準） |
| 表示モード | フレームに Color コレクションの **Dark** モードを明示適用（`setExplicitVariableModeForCollection`） |

## コンポーネントの探し方

- 名前検索を正とする: `page.findAllWithCriteria({types:['COMPONENT','COMPONENT_SET']})` で `kakeibo/` プレフィックスを列挙
- 一覧と各部品のバリアント・プロパティは `docs/design/component-inventory.md` が正本（nodeID付き）
- 各コンポーネントの description に対応するFlutterコードのパスが書いてある

## 画面スペック要素 → コンポーネント対応表

| スペック上の要素 | 使うコンポーネント | 備考 |
|---|---|---|
| 画面タイトル / ヘッダー | kakeibo/AppBar | Title プロパティ |
| 下部ナビゲーション | kakeibo/BottomNav | 選択タブは画面に応じて差し替え |
| セクション見出し | kakeibo/SectionHeader | Type=Card（画面直下）/ ListCard（カード内）。Show SubLabel でリンク表現 |
| カード / 枠 | kakeibo/Card | スロット制約あり（後述） |
| 履歴・一覧の行 | kakeibo/ListCard | Price=Expense/Income、Title/Subtitle/Price |
| グラフ（種類問わず） | kakeibo/ChartPlaceholder | CustomPaint実装領域の枠。グラフを自作しない |
| ボタン（主要/補助） | kakeibo/Button | Style=Main/Secondary、State |
| 追加・作成アクション | kakeibo/FAB | Circle/Extended |
| タブ切替 | kakeibo/TabItem / TabBar | 3個以上のタブは TabItem を並べる |
| 入力行（日付・メモ・予算） | kakeibo/InputRow | Kind=Date/Memo/Budget |
| 支出/収入/固定費の切替 | kakeibo/TransactionTypePill | Mode=支出/収入/固定費 |
| 金額の大型表示 | kakeibo/PriceDisplay | Amount プロパティ |
| 年月選択 | kakeibo/YearMonthPicker | ドロップダウン静止画。トリガー行はギャップ#1参照 |
| 確認・削除・金額ダイアログ | kakeibo/Dialog | Kind=確認/削除/金額入力 |
| 完了・エラー通知 | kakeibo/Snackbar | Kind=Success/Failure |
| モーダル（下から） | kakeibo/BottomSheet | スロット制約あり |
| 選択マーク | kakeibo/Checkbox | Checked/Unchecked |
| 「変動あり」表示 | kakeibo/Chip | 固定費の変動表示専用 |
| ローディング | kakeibo/Loader | - |
| アイコン背景 | kakeibo/IconCircle | Default/Selected |

**この表に無い要素が出てきたら、組み立てを止めてギャップとして報告する。**
既知のギャップ（PeriodSelector・CategorySumTile・実アイコン等）は
`docs/design/component-inventory.md` の「検証で発見されたギャップ」を参照。

## 組み立て手順

1. **スペックの分解**: 画面スペックの要素を上の対応表でコンポーネントに割り当てる。
   割り当て不能な要素はこの時点でリスト化（→ あれば停止・報告）
2. **骨格**: Screen Drafts ページに `Draft/<画面名>` フレーム（375x812・surface塗り・Darkモード適用）を作成。
   AppBar を上端(0,0)、BottomNav を下端(y=729)に絶対配置、間に縦Auto Layoutの `content`（padding 16）を置く
3. **セクション充填**: content にインスタンスを上から順に追加。`layoutSizingHorizontal='FILL'` を設定し、
   テキストは `setProperties` で差し替える（プロパティキーは `#suffix` 付きのため
   `instance.componentProperties` から前方一致で解決する）
4. **検証**: `frame.screenshot()` で目視確認 → 人間レビューへ

## スロット制約の回避ルール（重要）

kakeibo/Card・Pill・BottomSheet の `content` スロットは**インスタンスに子を追加できない**。

- ✅ 画面側にラッパーフレーム（fills無し）を作り、Cardインスタンスを底に敷いて
  その上に中身（ChartPlaceholder等）を重ねて配置する（実証済みパターン）
- ✅ 中身が確定部品1つなら、そのコンポーネント自体を使う（ListCard は Card を内包済み）
- ❌ インスタンスを **detach しない**（コンポーネント追従が切れる）
- ❌ Cardと同じ見た目のフレームを生の色値で自作しない

## 禁止事項

- 生のhex / 数値での塗り・角丸・サイズ指定（必ず Variables を bind する）
- 旧資産（Componentページの Torok/ 系・BtnM等・「バリアブルコレクション」「iOSDarkMode」「カテゴリー」コレクション）の使用
- スペックに無い要素・画面の追加
- グラフの自前描画（必ず ChartPlaceholder）
