import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_big_category_appearance_edited.g.dart';

//編集したかどうか
@Riverpod(keepAlive: true)
class IsBigCategoryAppearanceEditedNotifier extends _$IsBigCategoryAppearanceEditedNotifier {
  bool build() {
    // 最初のデータ
    return false;
  }

  void updateState(bool bool) {
    // データを上書き
    state = bool;
    
  }
}