import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reordering_category_list.g.dart';

/// 並び替え中のカテゴリーアイテム
/// IDで管理し、リアルタイムスワップに対応
class ReorderingCategoryItem {
  final int id;
  final String colorCode;
  final String categoryName;
  final String resourcePath;
  final int originalSortKey;

  const ReorderingCategoryItem({
    required this.id,
    required this.colorCode,
    required this.categoryName,
    required this.resourcePath,
    required this.originalSortKey,
  });

  /// ICategoryEntityから変換
  factory ReorderingCategoryItem.fromEntity(ICategoryEntity entity) {
    return ReorderingCategoryItem(
      id: entity.id,
      colorCode: entity.colorCode,
      categoryName: entity.categoryName,
      resourcePath: entity.resourcePath,
      originalSortKey: entity.sortKey,
    );
  }
}

/// 並び替え画面の状態
class ReorderingState {
  final List<ReorderingCategoryItem> items;
  final TransactionMode transactionMode;
  final bool hasChanges;

  const ReorderingState({
    required this.items,
    required this.transactionMode,
    this.hasChanges = false,
  });

  ReorderingState copyWith({
    List<ReorderingCategoryItem>? items,
    TransactionMode? transactionMode,
    bool? hasChanges,
  }) {
    return ReorderingState(
      items: items ?? this.items,
      transactionMode: transactionMode ?? this.transactionMode,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}

/// カテゴリー並び替え用の状態管理プロバイダー
@Riverpod(keepAlive: false)
class ReorderingCategoryListNotifier extends _$ReorderingCategoryListNotifier {
  @override
  ReorderingState build() {
    return const ReorderingState(
      items: [],
      transactionMode: TransactionMode.expense,
    );
  }

  /// 初期データを設定
  void setData(List<ICategoryEntity> categories, TransactionMode mode) {
    final items =
        categories.map((e) => ReorderingCategoryItem.fromEntity(e)).toList();
    state = ReorderingState(
      items: items,
      transactionMode: mode,
      hasChanges: false,
    );
  }

  /// IDを指定してアイテムを挿入（ドラッグ元から削除→ドロップ位置に挿入）
  ///
  /// 挿入方式：fromIdのアイテムを現在位置から削除し、
  /// toIdのアイテムがある位置に挿入する。
  /// これにより後続のアイテムが繰り上げ/繰り下げされる。
  void insertById(int fromId, int toId) {
    if (fromId == toId) return;

    final fromIndex = state.items.indexWhere((e) => e.id == fromId);
    final toIndex = state.items.indexWhere((e) => e.id == toId);

    if (fromIndex < 0 || toIndex < 0) return;

    final updatedList = [...state.items];

    // ドラッグ元からアイテムを削除
    final item = updatedList.removeAt(fromIndex);

    // ドロップ位置に挿入
    // removeAtで位置がずれるので、toIndexを再計算する必要がある
    // fromIndex < toIndex の場合、削除によりtoIndexが1つ減る
    final insertIndex = fromIndex < toIndex ? toIndex : toIndex;
    updatedList.insert(insertIndex, item);

    state = state.copyWith(items: updatedList, hasChanges: true);
  }

  /// インデックスを指定して並び替え（ReorderableListView互換）
  void reorder(int oldIndex, int newIndex) {
    final updatedList = [...state.items];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    state = state.copyWith(items: updatedList, hasChanges: true);
  }

  /// 現在の並び順を取得（保存時に使用）
  /// キー: カテゴリーID, 値: 新しい表示順
  Map<int, int> getNewDisplayOrders() {
    final result = <int, int>{};
    for (int i = 0; i < state.items.length; i++) {
      result[state.items[i].id] = i;
    }
    return result;
  }
}
