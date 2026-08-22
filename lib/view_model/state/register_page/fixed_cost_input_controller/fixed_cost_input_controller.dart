import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fixed_cost_input_controller.g.dart';

/// 登録・編集シートの固定費グループ専用の入力状態
///
/// v10で固定費タブを廃止し支出タブのトグルへ吸収したため、
/// 旧・固定費タブ専用だった state をこのファイルへ統合した（仕様 §8.2）。

/// 「固定費として登録」トグルの状態
///
/// ONのとき基本グループは拠出元のみに縮み、固定費グループに
/// 名称／初回支払日／頻度／支払い額が毎回変わる の4行が展開する（仕様 §6.1）。
@riverpod
class FixedCostRegisterToggleControllerNotifier
    extends _$FixedCostRegisterToggleControllerNotifier {
  @override
  bool build() {
    return false;
  }

  void setData(bool newState) {
    state = newState;
  }
}

/// 「支払い額が毎回変わる」スイッチの状態（旧 PriceTypeSwitchControllerNotifier）
///
/// ONのとき金額は入力させず `---` 表示にし、実績は推定額で扱う。
@riverpod
class FixedCostVariableSwitchControllerNotifier
    extends _$FixedCostVariableSwitchControllerNotifier {
  @override
  bool build() {
    return false;
  }

  void setData(bool newState) {
    state = newState;
  }
}

/// 固定費の「名称」入力欄のコントローラー
///
/// メモ（明細側の情報）とは別に保持する。トグルON時にメモの値を引き継ぐ（仕様 §6.1）。
final enteredFixedCostNameControllerProvider =
    Provider.autoDispose<TextEditingController>(
  (ref) => TextEditingController(text: ''),
);
