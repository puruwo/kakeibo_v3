import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'year_basis_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final yearBasisRepositoryProvider = Provider<YearBasisRepository>(
  (_) => throw UnimplementedError("YearBasisRepositoryの実装がされていません。"),
);


abstract interface class YearBasisRepository {

  /// ユーザ設定を取得する
  Future<YearBasisEntity> fetch();
}
