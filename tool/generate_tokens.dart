// design-tokens/tokens.json から Flutter の ThemeExtension（AppColors）を生成する。
//
// 実行: dart run tool/generate_tokens.dart
//   省略可能な引数: --input <path> --output <path>
//
// 処理:
//  1. エイリアス {primitive.xxx.yyy}（および {xxx.yyy}）を primitive セットの実値へ解決
//  2. 色変換: tokens.json は #RRGGBBAA（アルファ末尾）→ Flutter Color は 0xAARRGGBB（アルファ先頭）
//  3. トークン名 kebab-case → Dart camelCase（on-primary → onPrimary 等）
//
// 出力: lib/theme/app_colors.dart
//   - class AppColors extends ThemeExtension<AppColors>（light/dark の全 color.* を final フィールド化）
//   - static const AppColors light / dark
//   - copyWith / lerp を全フィールド分実装
//   - extension AppColorsX on BuildContext { AppColors get colors => ...; }

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  // ---- 引数 ----
  var inputPath = 'design-tokens/tokens.json';
  var outputPath = 'lib/theme/app_colors.dart';
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == '--input') inputPath = args[i + 1];
    if (args[i] == '--output') outputPath = args[i + 1];
  }

  // ---- 入力読み込み ----
  final file = File(inputPath);
  if (!file.existsSync()) {
    stderr.writeln('❌ 入力が見つかりません: $inputPath');
    exit(1);
  }
  final root = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  // ---- primitive セットを「ドット区切りパス -> HEX」で平坦化 ----
  final primitives = <String, String>{};
  final primitiveSet = root['primitive'];
  if (primitiveSet is Map<String, dynamic>) {
    _flattenColors(primitiveSet, '', primitives);
  }

  // ---- エイリアス解決（{primitive.brand.teal} / {brand.teal} 両対応） ----
  String resolveValue(String value, String tokenName) {
    final m = RegExp(r'^\{(.+)\}$').firstMatch(value.trim());
    if (m == null) return value; // リテラル
    var ref = m.group(1)!;
    if (ref.startsWith('primitive.')) ref = ref.substring('primitive.'.length);
    final resolved = primitives[ref];
    if (resolved == null) {
      stderr.writeln('❌ エイリアス未解決: `$tokenName` = {$ref}（primitive に存在しない）');
      exit(1);
    }
    return resolved;
  }

  // ---- light / dark の color.* を取り出す（フィールド名と値マップ） ----
  // 返り値: フィールド名（camel）-> Color リテラル文字列（const なし。const コンストラクタ内で使う）
  Map<String, String> buildMode(String setName) {
    final set = root[setName];
    if (set is! Map<String, dynamic>) {
      stderr.writeln('❌ セットが見つかりません: $setName');
      exit(1);
    }
    final flat = <String, String>{};
    _flattenColors(set, '', flat);
    final result = <String, String>{};
    flat.forEach((path, rawValue) {
      final leaf = path.startsWith('color.') ? path.substring('color.'.length) : path;
      final field = _camel(leaf);
      result[field] = _toColorLiteral(resolveValue(rawValue, path), path);
    });
    return result;
  }

  final light = buildMode('light');
  final dark = buildMode('dark');

  // ---- 自己チェック: light/dark のフィールド集合一致 ----
  if (!_setEquals(light.keys.toSet(), dark.keys.toSet())) {
    stderr.writeln('❌ light/dark のトークン名が不一致');
    stderr.writeln('   light only: ${light.keys.toSet().difference(dark.keys.toSet())}');
    stderr.writeln('   dark only : ${dark.keys.toSet().difference(light.keys.toSet())}');
    exit(1);
  }

  // フィールド順は light の出現順を正とする
  final fields = light.keys.toList();

  // ---- Dart コード生成 ----
  final buf = StringBuffer();
  buf.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buf.writeln('// Source    : $inputPath');
  buf.writeln('// Generator : tool/generate_tokens.dart');
  buf.writeln('//');
  buf.writeln('// セマンティック色トークンの ThemeExtension。');
  buf.writeln('// primitive は生成時にインライン解決済み（公開フィールドには含めない）。');
  buf.writeln('// あわせて const TextStyle 用の static const 色クラス AppColorsLight / AppColorsDark も出力する。');
  buf.writeln('// ※ MaterialApp への接続・既存 MyColors の置き換えは別STEPで対応。');
  buf.writeln('');
  buf.writeln("import 'package:flutter/material.dart';");
  buf.writeln('');
  buf.writeln('@immutable');
  buf.writeln('class AppColors extends ThemeExtension<AppColors> {');

  // コンストラクタ
  buf.writeln('  const AppColors({');
  for (final f in fields) {
    buf.writeln('    required this.$f,');
  }
  buf.writeln('  });');
  buf.writeln('');

  // フィールド
  for (final f in fields) {
    buf.writeln('  final Color $f;');
  }
  buf.writeln('');

  // light インスタンス
  buf.writeln('  static const AppColors light = AppColors(');
  for (final f in fields) {
    buf.writeln('    $f: ${light[f]},');
  }
  buf.writeln('  );');
  buf.writeln('');

  // dark インスタンス
  buf.writeln('  static const AppColors dark = AppColors(');
  for (final f in fields) {
    buf.writeln('    $f: ${dark[f]},');
  }
  buf.writeln('  );');
  buf.writeln('');

  // copyWith
  buf.writeln('  @override');
  buf.writeln('  AppColors copyWith({');
  for (final f in fields) {
    buf.writeln('    Color? $f,');
  }
  buf.writeln('  }) {');
  buf.writeln('    return AppColors(');
  for (final f in fields) {
    buf.writeln('      $f: $f ?? this.$f,');
  }
  buf.writeln('    );');
  buf.writeln('  }');
  buf.writeln('');

  // lerp
  buf.writeln('  @override');
  buf.writeln('  AppColors lerp(ThemeExtension<AppColors>? other, double t) {');
  buf.writeln('    if (other is! AppColors) return this;');
  buf.writeln('    return AppColors(');
  for (final f in fields) {
    buf.writeln('      $f: Color.lerp($f, other.$f, t)!,');
  }
  buf.writeln('    );');
  buf.writeln('  }');
  buf.writeln('}');
  buf.writeln('');

  // BuildContext 拡張
  buf.writeln('extension AppColorsX on BuildContext {');
  buf.writeln('  // 移行期: 新規 ThemeData を生成する Theme 配下など、AppColors 未登録の');
  buf.writeln('  // subtree でも null クラッシュしないよう、未取得時はダーク既定値へフォールバックする。');
  buf.writeln('  // （当面 themeMode.dark 固定のため dark を既定とする）');
  buf.writeln('  AppColors get colors =>');
  buf.writeln('      Theme.of(this).extension<AppColors>() ?? AppColors.dark;');
  buf.writeln('}');
  buf.writeln('');

  // ---- 移行期用: const TextStyle に入れられる static const 色クラス ----
  // ThemeExtension はランタイム解決のため const 文脈（const TextStyle）に使えない。
  // styles 配下の const TextStyle 用に light/dark の実値を static const で保持する。
  _writeStaticColorClass(buf, 'AppColorsLight', fields, light);
  buf.writeln('');
  _writeStaticColorClass(buf, 'AppColorsDark', fields, dark);

  // ---- 書き出し ----
  final outFile = File(outputPath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(buf.toString());

  // ---- サマリー ----
  stdout.writeln('✅ 生成完了: $outputPath');
  stdout.writeln('   primitive: ${primitives.length}個（内部解決・非公開）');
  stdout.writeln('   semantic : ${fields.length}フィールド（light/dark 各${fields.length}）');
  stdout.writeln('   static   : AppColorsLight / AppColorsDark（各${fields.length} static const）');

  // ---- category パレット生成（lib/theme/category_palette.dart） ----
  final categorySet = root['category'];
  if (categorySet is Map<String, dynamic>) {
    _generateCategoryPalette(categorySet, inputPath);
  }
}

/// category セットから lib/theme/category_palette.dart を生成する。
/// UI用 Color と DB保存用6桁HEX(alpha無し)を併記し、スウォッチ List も出力する。
void _generateCategoryPalette(Map<String, dynamic> category, String inputPath) {
  const outputPath = 'lib/theme/category_palette.dart';

  // グループ（expense/income）から色値(8桁HEX)を出現順で取り出す
  List<String> readGroup(String key) {
    final group = category[key];
    if (group is! Map<String, dynamic>) {
      stderr.writeln('❌ category.$key が見つかりません');
      exit(1);
    }
    final out = <String>[];
    group.forEach((k, v) {
      if (v is Map<String, dynamic> && v['type'] == 'color') {
        out.add(v['value'].toString());
      }
    });
    return out;
  }

  final expense = readGroup('expense');
  final income = readGroup('income');
  final fixedLeaf = category['fixed'];
  if (fixedLeaf is! Map<String, dynamic> || fixedLeaf['type'] != 'color') {
    stderr.writeln('❌ category.fixed が見つかりません');
    exit(1);
  }
  final fixedHex = fixedLeaf['value'].toString();

  final buf = StringBuffer();
  buf.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buf.writeln('// Source    : $inputPath (category セット)');
  buf.writeln('// Generator : tool/generate_tokens.dart');
  buf.writeln('//');
  buf.writeln('// カテゴリーパレット（データ色）。UI用 Color と DB保存用6桁HEX(alpha無し)を併記。');
  buf.writeln("// DB側は getColorFromHex が 'FF'+code する既存仕様に合わせ6桁のまま。");
  buf.writeln('// ※ 消費側（dialog/seed/注入）の差し替えは別STEP。');
  buf.writeln('');
  buf.writeln("import 'package:flutter/material.dart';");
  buf.writeln('');
  buf.writeln('class CategoryPalette {');
  buf.writeln('  CategoryPalette._();');
  buf.writeln('');
  buf.writeln('  // 支出カテゴリー（${expense.length}色）');
  for (var i = 0; i < expense.length; i++) {
    buf.writeln('  static const Color expense${i + 1} = ${_toColorLiteral(expense[i], 'category.expense.${i + 1}')};');
  }
  buf.writeln('');
  buf.writeln('  // 収入カテゴリー（${income.length}色）');
  for (var i = 0; i < income.length; i++) {
    buf.writeln('  static const Color income${i + 1} = ${_toColorLiteral(income[i], 'category.income.${i + 1}')};');
  }
  buf.writeln('');
  buf.writeln('  // 固定費カテゴリー');
  buf.writeln('  static const Color fixedCost = ${_toColorLiteral(fixedHex, 'category.fixed')};');
  buf.writeln('');
  buf.writeln('  // --- DB保存用 6桁HEX（alpha無し） ---');
  for (var i = 0; i < expense.length; i++) {
    buf.writeln("  static const String expense${i + 1}Hex = '${_hex6(expense[i])}';");
  }
  for (var i = 0; i < income.length; i++) {
    buf.writeln("  static const String income${i + 1}Hex = '${_hex6(income[i])}';");
  }
  buf.writeln("  static const String fixedCostHex = '${_hex6(fixedHex)}';");
  buf.writeln('');
  buf.writeln('  /// 支出パレットのスウォッチ（表示順）。');
  buf.writeln('  static const List<Color> expenseSwatches = [${List.generate(expense.length, (i) => 'expense${i + 1}').join(', ')}];');
  buf.writeln('');
  buf.writeln('  /// 収入パレットのスウォッチ（表示順）。');
  buf.writeln('  static const List<Color> incomeSwatches = [${List.generate(income.length, (i) => 'income${i + 1}').join(', ')}];');
  buf.writeln('}');

  final outFile = File(outputPath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(buf.toString());

  stdout.writeln('✅ 生成完了: $outputPath');
  stdout.writeln('   category : expense ${expense.length} / income ${income.length} / fixed 1（Color + 6桁HEX）');
}

/// static const Color フィールドのみを持つ色クラスを buf に書き出す。
/// ThemeExtension（AppColors）はランタイム解決のため const TextStyle に使えないため、
/// 移行期のダーク固定運用では const 文脈用にこの静的クラスを使う。
void _writeStaticColorClass(
  StringBuffer buf,
  String className,
  List<String> fields,
  Map<String, String> values,
) {
  final mode = className.endsWith('Dark') ? 'dark' : 'light';
  buf.writeln('/// $className: const TextStyle 用の静的色トークン（$mode 実値）。');
  buf.writeln('class $className {');
  buf.writeln('  $className._();');
  buf.writeln('');
  for (final f in fields) {
    buf.writeln('  static const Color $f = ${values[f]};');
  }
  buf.writeln('}');
}

/// #RRGGBBAA / #RRGGBB から DB用の6桁HEX（RRGGBB・alpha無し・大文字）を取り出す。
String _hex6(String hex) {
  var h = hex.trim();
  if (h.startsWith('#')) h = h.substring(1);
  return h.substring(0, 6).toUpperCase();
}

/// value/type を持つ color リーフを「ドット区切りパス -> value(HEX or alias)」で平坦化。
void _flattenColors(Map<String, dynamic> node, String prefix, Map<String, String> out) {
  node.forEach((key, value) {
    if (key.startsWith(r'$')) return; // $metadata 等は無視
    if (value is Map<String, dynamic>) {
      final isLeaf = value.containsKey('value') && value.containsKey('type');
      if (isLeaf) {
        if (value['type'] == 'color') {
          out['$prefix$key'] = value['value'].toString();
        }
      } else {
        _flattenColors(value, '$prefix$key.', out);
      }
    }
  });
}

/// kebab-case の末端名を camelCase に変換。例: on-primary -> onPrimary, surface-elevated-2 -> surfaceElevated2
String _camel(String kebab) {
  final parts = kebab.split('-');
  final sb = StringBuffer(parts.first);
  for (final p in parts.skip(1)) {
    if (p.isEmpty) continue;
    sb.write(p[0].toUpperCase() + p.substring(1));
  }
  return sb.toString();
}

/// #RRGGBB / #RRGGBBAA を Flutter の Color(0xAARRGGBB) リテラル文字列に変換（アルファを先頭へ）。
String _toColorLiteral(String hex, String tokenName) {
  var h = hex.trim();
  if (h.startsWith('#')) h = h.substring(1);
  if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(h) || (h.length != 6 && h.length != 8)) {
    stderr.writeln('❌ 不正な色値: `$tokenName` = $hex');
    exit(1);
  }
  final rr = h.substring(0, 2);
  final gg = h.substring(2, 4);
  final bb = h.substring(4, 6);
  final aa = h.length == 8 ? h.substring(6, 8) : 'FF';
  final argb = (aa + rr + gg + bb).toUpperCase();
  return 'Color(0x$argb)';
}

bool _setEquals(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);
