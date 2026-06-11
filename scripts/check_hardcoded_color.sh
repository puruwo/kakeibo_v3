#!/usr/bin/env bash
# ハードコード色 検出スクリプト（移行中の品質ゲート）
#
# 検出対象:
#   - Color(0x...) のリテラル色
#   - Material の Colors.<名前>（MyColors.* は単語境界で除外）
# 許可リスト（検出しない）:
#   - Colors.transparent
# 対象外ファイル:
#   - lib/theme/app_colors.dart      （生成物）
#   - lib/constant/colors.dart       （移行中の旧 MyColors 定義）
#   - lib/ 配下以外 / .dart 以外
#
# 使い方:
#   scripts/check_hardcoded_color.sh [--quiet] [file ...]
#     - 引数あり: そのファイル群だけを検査（hook から変更ファイルを渡す用途）
#     - 引数なし: lib/ 配下の全 .dart を検査（手動の現状把握用）
#     - --quiet : 検出が無いときは何も出力しない（hook 用。クリーン編集で無音にする）
#
# 終了コード: 常に 0（移行中のため警告のみ。ビルドや編集はブロックしない）

set -u

quiet=0
if [ "${1:-}" = "--quiet" ]; then
  quiet=1
  shift
fi

total=0
findings=""

# 1ファイルを検査し、検出を findings に追記・total を加算する
check_file() {
  local f="$1"

  # .dart 以外はスキップ
  case "$f" in
    *.dart) ;;
    *) return ;;
  esac

  # lib/ 配下以外はスキップ
  case "$f" in
    */lib/*|lib/*) ;;
    *) return ;;
  esac

  # 対象外ファイル（生成物・旧定義）はスキップ
  case "$f" in
    */lib/theme/app_colors.dart|lib/theme/app_colors.dart) return ;;
    */lib/constant/colors.dart|lib/constant/colors.dart) return ;;
  esac

  # 実在しなければスキップ（削除直後など）
  [ -f "$f" ] || return

  local ln rest token name content

  # --- Color(0x...) ---
  while IFS=: read -r ln rest; do
    [ -n "$ln" ] || continue
    content=$(sed -n "${ln}p" "$f" | sed -E 's/^[[:space:]]*//')
    findings+="  ${f}:${ln}: ${content}"$'\n'
    total=$((total + 1))
  done < <(grep -noE 'Color\(0x[0-9A-Fa-f]+' "$f")

  # --- Material Colors.<名前>（MyColors. は単語境界で除外、transparent は許可） ---
  while IFS=: read -r ln rest; do
    [ -n "$ln" ] || continue
    token=$(printf '%s' "$rest" | sed -E 's/.*(Colors\.[A-Za-z][A-Za-z0-9_]*).*/\1/')
    name=${token#Colors.}
    [ "$name" = "transparent" ] && continue
    content=$(sed -n "${ln}p" "$f" | sed -E 's/^[[:space:]]*//')
    findings+="  ${f}:${ln}: ${content}"$'\n'
    total=$((total + 1))
  done < <(grep -noE '(^|[^A-Za-z0-9_])Colors\.[A-Za-z][A-Za-z0-9_]*' "$f")
}

if [ "$#" -gt 0 ]; then
  # hook 等から渡された変更ファイルのみ検査
  for f in "$@"; do
    check_file "$f"
  done
else
  # 手動実行: lib/ 配下を全走査
  while IFS= read -r f; do
    check_file "$f"
  done < <(find lib -type f -name '*.dart' | sort)
fi

# --quiet かつ 0件なら完全に無音
if [ "$quiet" -eq 1 ] && [ "$total" -eq 0 ]; then
  exit 0
fi

echo "🎨 ハードコード色チェック（警告のみ・非ブロック）"
if [ "$total" -gt 0 ]; then
  printf '%s' "$findings"
  echo "⚠️  ハードコード色を ${total} 件検出（context.colors / AppColors への移行候補）"
else
  echo "✅ ハードコード色は検出されませんでした"
fi

# 移行中のため常に 0（ブロックしない）
exit 0
