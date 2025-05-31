import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'month_basis_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final monthBasisRepositoryProvider = Provider<MonthBasisRepository>(
  (_) => throw UnimplementedError("MonthBasisRepositoryの実装がされていません。"),
);


abstract interface class MonthBasisRepository {

  /// ユーザ設定を取得する
  Future<MonthBasisEntity> fetch();
}
