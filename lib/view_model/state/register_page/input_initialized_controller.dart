import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 入力フィールドが初期化済みかどうかを追跡するプロバイダー
/// pill切り替え時に入力値を保持するために使用
final inputInitializedControllerProvider =
    StateProvider.autoDispose<bool>((ref) => false);
