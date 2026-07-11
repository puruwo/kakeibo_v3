import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:share_plus/share_plus.dart';

final dataManagementUsecaseProvider =
    Provider<DataManagementUsecase>(DataManagementUsecase.new);

class DataManagementUsecase {
  DataManagementUsecase(this._ref);
  final Ref _ref;

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get _updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// データベースファイルを共有シートで書き出す（バックアップ）
  Future<void> exportDatabaseFile() async {
    final path = await DatabaseHelper.instance.getDatabasePath();

    //エラーチェック
    if (!File(path).existsSync()) {
      throw const AppException('データベースファイルが見つかりません');
    }

    logger.i('データベースファイルを書き出します: $path');
    await Share.shareXFiles([XFile(path)], text: '家計簿データベースのバックアップです');
  }

  /// すべてのデータを削除して初期状態に戻す
  Future<void> deleteAllData() async {
    await DatabaseHelper.instance.deleteDatabaseFile();
    logger.i('すべてのデータを削除しました');

    // 各画面を再取得させる（次回DBアクセス時にonCreateから再初期化される）
    _updateDBCountNotifier.incrementState();
  }
}
