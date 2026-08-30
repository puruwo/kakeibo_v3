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
#     - 数字が主役の内容（PriceGetter / DateFormat / 件 / %）に noto 系の疑いがある style（3行以内の同居・ヒューリスティック）
#   [役割スタイル定義] lib/constant/styles/（app_type_scale.dart 以外）
#     - fontSize: / fontWeight: / MyFontStyle. / TextStyle( の直書き（値は AppTypeScale の段を参照する）
# 対象外: lib/ 配下以外、.dart 以外、*.g.dart / *.freezed.dart、lib/constant/font_style.dart、lib/constant/styles/app_type_scale.dart
#
# 使い方:
#   scripts/check_text_style.sh [--quiet] [file ...]
#     - 引数あり: そのファイル群だけを検査（hook から変更ファイルを渡す用途）
#     - 引数なし: lib/ 配下の全 .dart を検査（手動の現状把握用）
#     - --quiet : 検出が無いときは何も出力しない（hook 用）
#
# 終了コード: 常に 0（警告のみ。ビルドや編集はブロックしない）

set -u

quiet=0
if [ "${1:-}" = "--quiet" ]; then
  quiet=1
  shift
fi

total=0
findings=""

add_finding() {
  # $1=file $2=line $3=メッセージ
  local content
  content=$(sed -n "${2}p" "$1" | sed -E 's/^[[:space:]]*//')
  findings+="  ${1}:${2}: [$3] ${content}"$'\n'
  total=$((total + 1))
}

# grep の結果（行番号:内容）を add_finding に流す
report_grep() {
  # $1=file $2=メッセージ $3=拡張正規表現（コメント行は対象外）
  local f="$1" msg="$2" re="$3" ln rest
  while IFS=: read -r ln rest; do
    [ -n "$ln" ] || continue
    add_finding "$f" "$ln" "$msg"
  done < <(grep -nE "$re" "$f" | grep -vE '^[0-9]+:[[:space:]]*//')
}

check_call_site() {
  local f="$1"
  report_grep "$f" "TextStyle 直書き" '(^|[^A-Za-z0-9_.])TextStyle\('
  report_grep "$f" "MyFontStyle 直接参照" '(^|[^A-Za-z0-9_])MyFontStyle\.'
  report_grep "$f" "AppTypeScale 直接参照（役割スタイル定義専用）" '(^|[^A-Za-z0-9_])AppTypeScale\.'
  report_grep "$f" "寸法・ウェイト・ファミリーの上書き（copyWith は color のみ）" '(^|[^A-Za-z0-9_])(fontSize|fontWeight|fontFamily|letterSpacing):'
  report_grep "$f" "copyWith での height 上書き" 'copyWith\(.*[^A-Za-z0-9_]height:'
  report_grep "$f" "style 無しの Text" "(^|[^A-Za-z0-9_.])Text\([[:space:]]*'[^']*'[[:space:]]*\)"

  # 数字が主役の内容に noto 系スタイルの疑い（style 行の直前2行以内に数値生成がある Text）。
  # sfUi 系の役割名（Price / Numeric / Caption / Input / Hero / Value / Date / Step / Section）と
  # 文を描く役割名（Note / supporting / dialog / Message）は除外する
  while IFS=: read -r ln rest; do
    [ -n "$ln" ] || continue
    add_finding "$f" "$ln" "数字が主役の内容に noto 系スタイルの疑い（sfUi 系の <役割>Numeric を検討）"
  done < <(awk '
    function is_numeric(s) { return (s ~ /PriceGetter\(|DateFormat\(|件'"'"'|%'"'"'/) }
    function is_noto_style(s) {
      if (s !~ /style: *AppTextStyles\.[A-Za-z]+/) return 0
      match(s, /AppTextStyles\.[A-Za-z]+/)
      name = substr(s, RSTART + 14, RLENGTH - 14)
      if (name ~ /Price|Numeric|Caption|Input|Hero|Value|Date|Step|Section|Note|supporting|dialog|Message/) return 0
      return 1
    }
    {
      line[NR] = $0
      if (is_noto_style($0)) {
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

  case "$f" in
    *.g.dart|*.freezed.dart) return ;;
    *.dart) ;;
    *) return ;;
  esac
  case "$f" in
    */lib/*|lib/*) ;;
    *) return ;;
  esac
  case "$f" in
    */lib/constant/font_style.dart|lib/constant/font_style.dart) return ;;
    */lib/constant/styles/app_type_scale.dart|lib/constant/styles/app_type_scale.dart) return ;;
  esac
  [ -f "$f" ] || return

  case "$f" in
    */lib/constant/styles/*|lib/constant/styles/*) check_style_definition "$f" ;;
    *) check_call_site "$f" ;;
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
