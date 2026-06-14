import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// テスト用 path_provider モック。getApplicationDocumentsPath をテンポラリに向ける。
class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _FakePathProvider(this._dir);
  final String _dir;
  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
  @override
  Future<String?> getApplicationSupportPath() async => _dir;
}

/// ffi 経由で実DBを開けるようにする。毎回クリーンなDBにするため既存ファイルを消す。
String initDbHarness() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final dir = Directory('${Directory.current.path}/.dart_tool/golden_db');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);
  PathProviderPlatform.instance = _FakePathProvider(dir.path);
  return dir.path;
}
