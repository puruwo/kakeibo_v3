---
name: update-font-usage-csv
description: >
  フォント系の修正（TextStyle追加・変更・削除、FontStyle定義の変更、
  インラインTextStyleの共通化など）を行ったとき、
  lib/docs/font_usage.csvを最新状態に同期するルールを定義する。
  フォントに関わるコードを変更するときは必ずこのSkillに従うこと。
---

# font_usage.csv 更新ルール

## 対象ファイル

`lib/docs/font_usage.csv`

フォントスタイル（TextStyle）に関わるファイルを変更した場合、作業完了前に必ずこのCSVを更新する。

---

## 更新が必要なタイミング

| 操作 | 対応 |
|------|------|
| TextStyleを新規追加 | CSVに1行追加 |
| TextStyleのプロパティを変更（fontSize / fontWeight / color等） | CSVの該当列を更新 |
| TextStyleの定義名を変更 | CSVの `コンポーネント名（Widget名）` を更新 |
| TextStyleの定義ファイルを移動・リネーム | CSVの `ファイルパス` を更新 |
| MyFontStyle使用/未使用を変更 | CSVの `MyFontStyle使用` と `定義方法` を更新 |
| インラインTextStyleを共通スタイルに移行 | CSVの該当行を全列更新（ファイルパス・定義方法・共通化の有無等） |
| TextStyleを削除 | CSVから該当行を削除 |
| スタイル定義ファイル自体を削除 | CSVからそのファイルの全行を削除 |

---

## CSVの列定義

| 列名 | 内容 |
|------|------|
| `ファイルパス` | TextStyleが定義されているファイルパス（例: `lib/constant/styles/app_text_styles.dart`） |
| `画面名（クラス名）` | 所属画面・用途の分類名（例: `共通` / `登録ページ` / `カレンダー`） |
| `コンポーネント名（Widget名）` | TextStyleの変数名またはWidget名（例: `AppTextStyles.pageHeaderText`） |
| `テキスト内容の種類` | テキストの用途分類（`見出し` / `ラベル` / `金額` / `本文` / `ボタン` / `エラー` / `タブ`） |
| `fontFamily` | フォントファミリー（`noto_sans` / `sf_ui` / `未指定(default)`） |
| `fontSize` | フォントサイズの数値（例: `14` / `18`）。未指定の場合は `未指定` |
| `fontWeight` | フォントウェイト（例: `w400` / `w500` / `w600` / `bold`）。未指定の場合は `未指定`。動的な場合は `dynamic(bold/normal)` のように記載 |
| `color` | 使用色（例: `MyColors.white` / `MyColors.label`）。動的な場合は `dynamic(white)` のように記載 |
| `定義方法` | TextStyleの定義方法（`MyFontStyle.notoSans.copyWith()` / `MyFontStyle.sfUi.copyWith()` / `インライン TextStyle()` / `定数参照+copyWith`） |
| `MyFontStyle使用` | MyFontStyleの使用状況（`使用(notoSans)` / `使用(sfUi)` / `使用(notoSans/間接)` / `使用(sfUi/間接)` / `未使用`） |
| `共通化の有無` | 共通スタイルとして定義されているか（`共通化済み` / `インライン` / `copyWithで上書き`） |

---

## 画面名の判断基準

| 画面名 | 対象 |
|--------|------|
| `共通` | `app_text_styles.dart` など複数画面で使われる共通スタイル |
| `登録ページ` | `register_page_styles.dart` や `lib/view/register_page/` 配下 |
| `カレンダー` | `calendar_styles.dart` 配下 |
| `グラフ` | `graph_text_styles.dart` 配下 |
| `カテゴリー編集` | `category_styles.dart` 配下 |
| `予算設定` | `budget_settings_styles.dart` 配下 |
| `年間収入リスト` | `yearly_income_list_styles.dart` 配下 |
| その他 | Widgetクラス名をそのまま記載（例: `FixedCostSummaryHeader`） |

---

## テキスト内容の種類の判断基準

| 種類 | 対象 |
|------|------|
| `見出し` | ページタイトル・セクション見出し・ヘッダーテキスト |
| `ラベル` | 一般的なラベル・説明テキスト・サブテキスト |
| `金額` | 価格・金額表示（数値メイン） |
| `本文` | テキスト入力・本文表示 |
| `ボタン` | ボタン内テキスト |
| `エラー` | エラーメッセージ・空表示メッセージ |
| `タブ` | タブラベル |

---

## 注意事項

- `lib/constant/styles/` 配下のスタイル定義ファイルの変更は必ずCSV更新対象
- `lib/view/` 配下でインラインの `TextStyle()` を追加・変更した場合もCSV更新対象
- `copyWith()` で既存スタイルを上書きしている場合は、上書き後の値をCSVに記載する
- CSVのヘッダー行は変更しない
- 行の並び順はファイルパス順 → 同一ファイル内では定義順とする
