import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_icon_path.g.dart';


@riverpod
class SelectedIconPathNotifier extends _$SelectedIconPathNotifier {
  @override
  String build() {
    // 最初のデータ
    const selelctedIconPath = '';
    return selelctedIconPath;
  }

  void updateState(String iconPath) {
    // データを上書き
    state = iconPath;
  } 
}
