#!/usr/bin/env bash
# テキストスタイル規約 検出スクリプト（警告のみ・非ブロック）
#
# 規約の正本: Vault「Kakeibo テキストスタイルルール」（KP-007）
#   MyFontStyle（family）→ AppTypeScale（段・値の正本）→ 役割スタイル（AppTextStyles 等）→ 呼び出し側
#
# 検出対象:
#   [呼び出し側] lib/constant/styles/ 以外の .dart
#     - TextStyle( の直書き
#     - MyFontStyle. / AppTypeScale. の直接参照（役割スタイル定義専用）
#     - copyWith 等での fontSize: / fontWeight: / fontFamily: / letterSpacing: の指定（上書きは color のみ許可）
#     - copyWith( と同じ行の height: 指定
#     - style 無しの Text('...')（単一行リテラルのみ検出）
#     - 数字が主役の内容（PriceGetter / DateFormat / 件 / %）に noto 系の役割スタイル（3行以内の同居・ヒューリスティック）。
#       noto 系かどうかは lib/constant/styles/ の定義（AppTypeScale.noto… を参照しているか）から実行時に導出する
#   [役割スタイル定義] lib/constant/styles/（app_type_scale.dart 以外）
#     - fontSize: / fontWeight: / MyFontStyle. / TextStyle( の直書き（値は AppTypeScale の段を参照する）
# 対象外: lib/ 配下以外、.dart 以外、*.g.dart / *.freezed.dart、lib/constant/font_style.dart、lib/constant/styles/app_type_scale.dart
#
# 使い方:
#   scripts/check_text_style.sh [--quiet] [file ...]
#     - 引数あり: そのファイル群だけを検査（hook から変更ファイルを渡す用途。絶対パス可）
#     - 引数なし: lib/ 配下の全 .dart を検査（リポジトリルートで実行。手動の現状把握用）
#     - --quiet : 検出が無いときは何も出力しない（hook 用）
#
# 終了コード: 常に 0（警告のみ。ビルドや編集はブロックしない）

set -u

quiet=0
if [ "${1:-}" = "--quiet" ]; then
  quiet=1
  shift
fi

# リポジトリルート（scripts/ の親）。役割スタイル定義の読み込みに使う
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

total=0
findings=""

add_finding() {
  # $1=file $2=line $3=メッセージ $4=行の内容（先頭の空白を落として表示）
  local content="$4"
  content="${content#"${content%%[![:space:]]*}"}"
  findings+="  ${1}:${2}: [$3] ${content}"$'\n'
  total=$((total + 1))
}

# grep の結果（行番号:内容）を add_finding に流す
report_grep() {
  # $1=file $2=メッセージ $3=拡張正規表現（コメント行は対象外）
  local f="$1" msg="$2" re="$3" ln rest
  while IFS=: read -r ln rest; do
    [ -n "$ln" ] || continue
    add_finding "$f" "$ln" "$msg" "$rest"
  done < <(grep -nE "$re" "$f" | grep -vE '^[0-9]+:[[:space:]]*//')
}

# 役割スタイル定義から noto 系スタイル名の集合（a|b|c 形式）を作る。
# doc コメント行を除いた定義ソースを1行に潰し、「TextStyle <名前> … AppTypeScale.noto」の並びから名前を拾う
# （関数形式の定義 `static TextStyle foo(...) { ... AppTypeScale.noto... }` も同じ形で拾える）
noto_style_names() {
  local dir="$repo_root/lib/constant/styles"
  [ -d "$dir" ] || return 0
  sed -E '/^[[:space:]]*\/\/\//d' "$dir"/*.dart \
    | tr -d '\n' \
    | grep -oE 'TextStyle [A-Za-z0-9_]+[^;]*AppTypeScale *\. *noto' \
    | sed -E 's/^TextStyle ([A-Za-z0-9_]+).*/\1/' \
    | sort -u \
    | paste -sd '|' -
}
noto_names=$(noto_style_names)

check_call_site() {
  local f="$1"
  report_grep "$f" "TextStyle 直書き" '(^|[^A-Za-z0-9_.])TextStyle\('
  report_grep "$f" "MyFontStyle 直接参照" '(^|[^A-Za-z0-9_])MyFontStyle\.'
  report_grep "$f" "AppTypeScale 直接参照（役割スタイル定義専用）" '(^|[^A-Za-z0-9_])AppTypeScale\.'
  report_grep "$f" "寸法・ウェイト・ファミリーの上書き（copyWith は color のみ）" '(^|[^A-Za-z0-9_])(fontSize|fontWeight|fontFamily|letterSpacing):'
  report_grep "$f" "copyWith での height 上書き" 'copyWith\(.*[^A-Za-z0-9_]height:'
  report_grep "$f" "style 無しの Text" "(^|[^A-Za-z0-9_.])Text\([[:space:]]*'[^']*'[[:space:]]*\)"

  # 数字が主役の内容に noto 系スタイルの疑い（style 行の直前2行以内に数値生成がある Text）
  [ -n "$noto_names" ] || return 0
  while IFS=: read -r ln rest; do
    [ -n "$ln" ] || continue
    add_finding "$f" "$ln" "数字が主役の内容に noto 系スタイルの疑い（sfUi 系の <役割>Numeric を検討）" "$rest"
  done < <(awk -v noto="$noto_names" '
    BEGIN { noto_re = "style: *(AppTextStyles|GraphTextStyles|RegisterPageStyles|CalendarStyles)\\.(" noto ")([^A-Za-z0-9_]|$)" }
    function is_numeric(s) { return (s ~ /PriceGetter\(|DateFormat\(|件'"'"'|%'"'"'/) }
    {
      line[NR] = $0
      if ($0 ~ noto_re) {
        for (i = NR - 2; i <= NR; i++) if (i > 0 && is_numeric(line[i])) { print NR ":" $0; break }
      }
    }' "$f")
}

check_style_definition() {
  local f="$1"
  report_grep "$f" "役割スタイル定義での寸法・ウェイト直書き（AppTypeScale の段を参照する）" '(^|[^A-Za-z0-9_])(fontSize|fontWeight):'
  report_grep "$f" "役割スタイル定義での MyFontStyle 直接参照" '(^|[^A-Za-z0-9_])MyFontStyle\.'
  report_grep "$f" "役割スタイル定義での TextStyle 直書き" '(^|[^A-Za-z0-9_.])TextStyle\('
}

check_file() {
  local f="$1"
  [ -f "$f" ] || return

  # 先頭に / を補い、相対・絶対どちらのパスも */lib/… の1パターンで判定する
  case "/$f" in
    *.g.dart|*.freezed.dart) return ;;
    */lib/constant/font_style.dart|*/lib/constant/styles/app_type_scale.dart) return ;;
    */lib/constant/styles/*.dart) check_style_definition "$f" ;;
    */lib/*.dart) check_call_site "$f" ;;
  esac
}

if [ "$#" -gt 0 ]; then
  for f in "$@"; do
    check_file "$f"
  done
else
  while IFS= read -r f; do
    check_file "$f"
  done < <(find lib -type f -name '*.dart' | sort)
fi

if [ "$quiet" -eq 1 ] && [ "$total" -eq 0 ]; then
  exit 0
fi

echo "🔤 テキストスタイル規約チェック（警告のみ・非ブロック）"
if [ "$total" -gt 0 ]; then
  printf '%s' "$findings"
  echo "⚠️  規約からの逸脱候補を ${total} 件検出（Vault「Kakeibo テキストスタイルルール」§3〜§7 を参照）"
else
  echo "✅ 逸脱候補は検出されませんでした"
fi

exit 0
