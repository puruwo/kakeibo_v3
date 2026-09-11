import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/model/theme_mode_store.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/theme_mode.dart';

final themeModeUsecaseProvider = Provider<ThemeModeUsecase>(
  ThemeModeUsecase.new,
);

/// テーマモードの切替（KP-013）
///
/// 画面に即時反映してから保存する。保存に失敗したら元のモードへ戻して例外を投げる。
class ThemeModeUsecase {
  ThemeModeUsecase(this._ref);
  final Ref _ref;

  /// テーマモードを切り替えて保存する
  Future<void> save(ThemeMode mode) async {
    final notifier = _ref.read(themeModeNotifierProvider.notifier);
    final previous = _ref.read(themeModeNotifierProvider);

    // 先に状態を更新して画面へ即時反映する
    notifier.updateState(mode);

    try {
      await ThemeModeStore().save(mode);
    } catch (e) {
      // 保存できなかった場合は表示も元に戻す（次回起動時の値と食い違わせない）
      notifier.updateState(previous);
      throw const AppException('外観の設定を保存できませんでした');
    }
  }
}
