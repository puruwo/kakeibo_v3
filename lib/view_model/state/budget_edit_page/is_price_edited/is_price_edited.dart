import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_price_edited.g.dart';

//登録できるかどうか
@Riverpod(keepAlive: true)
class IsPriceEditedNotifier extends _$IsPriceEditedNotifier {
  bool build() {
    // 最初のデータ
    return false;
  }

  void updateState(bool bool) {
    // データを上書き
    state = bool;
  }
}