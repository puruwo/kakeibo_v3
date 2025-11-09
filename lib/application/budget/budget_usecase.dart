import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/budget/budget_provider.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';

final budgetUsecaseProvider = Provider<BudgetUsecase>(BudgetUsecase.new);

class BudgetUsecase {
  BudgetUsecase(this._ref);

  final Ref _ref;

  BudgetRepository get _budgetRepositoryProvider =>
      _ref.read(budgetRepositoryProvider);

  ExpenseBigCategoryRepository get _bigCategoryRepository =>
      _ref.read(expensebigCategoryRepositoryProvider);

  void _invalidateBudgetRepositoryProvider() => _ref.invalidate(budgetProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get _updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// [fetchAll] メソッドは、全てのエクスポートの情報を取得する
  Future<List<BudgetEditValue>> fetchAll(
      {required MonthValue monthValue}) async {
    // 大カテゴリーの一覧情報を取得する
    final expenseBigCategoryList = await _bigCategoryRepository.fetchAll();

    // 取得した支出データから、それぞれカテゴリーなどの情報を取得し、タイルのデータを作成する
    List<BudgetEditValue> tileList = [];

    // 各valueの情報を取得する
    for (var bigCategory in expenseBigCategoryList) {
      // SqfBudgetから大カテゴリーを指定して予算データを取得する
      final budgetEntity =
          await _budgetRepositoryProvider.fetchMonthlyByBigCategory(
              month: monthValue, expenseBigCategoryId: bigCategory.id);
      final lastMonthBudgetEntity =
          await _budgetRepositoryProvider.fetchMonthlyByBigCategory(
              month: monthValue.beforMonth,
              expenseBigCategoryId: bigCategory.id);

      final budgetEditValue = BudgetEditValue(
        id: budgetEntity.id,
        // 予算が設定されているかどうかbudgetEntityのidで判断
        budgetStatus: budgetEntity.id != -1
            ? BudgetStatus.registerd
            : BudgetStatus.notRegisterd,
        expenseBigCategoryId: budgetEntity.expenseBigCategoryId,
        month: budgetEntity.month,
        price: budgetEntity.price,
        lastMonthBudgetPrice: lastMonthBudgetEntity.price,
        expenseBigCategoryName: bigCategory.bigCategoryName,
        colorCode: bigCategory.colorCode,
        resourcePath: bigCategory.resourcePath,
        displayOrder: bigCategory.displayOrder,
      );

      // 0の場合は予算を表示しない
      if (bigCategory.isDisplayed == 1) {
        tileList.add(budgetEditValue);
      }
    }

    // displayOrderでソートする
    tileList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return tileList;
  }

  // 編集処理
  Future<void> edit(
      {required List<BudgetEditValue> originalValues,
      required List<int> editPrice}) async {
    //エラーチェック
    if (originalValues.length != editPrice.length) {
      // リストの長さが一致しない場合
      throw const AppException('予期せぬエラーが発生しました(E001)');
    }

    for (var i = 0; i < originalValues.length; i++) {
      // 値段に変更があればアップデートする
      if (originalValues[i].price != editPrice[i]) {
        final editEntity = BudgetEntity(
          id: originalValues[i].id,
          expenseBigCategoryId: originalValues[i].expenseBigCategoryId,
          month: originalValues[i].month,
          price: editPrice[i],
        );

        // もともと登録されていればあればupdate、なければadd
        if (originalValues[i].budgetStatus == BudgetStatus.registerd) {
          // SqfBudgetでデータをupdateする
          _budgetRepositoryProvider.update(editEntity);
        } else {
          _budgetRepositoryProvider.insert(editEntity);
        }
      }
    }

    // providerをdisposeしてリフレッシュ
    _invalidateBudgetRepositoryProvider();

    // DBの更新回数をインクリメント
    _updateDBCountNotifier.incrementState();
  }

  // 新規登録処理
  Future<void> add({required BudgetEntity entity}) async {
    _budgetRepositoryProvider.insert(entity);

    // providerをdisposeしてリフレッシュ
    _invalidateBudgetRepositoryProvider();

    // DBの更新回数をインクリメント
    _updateDBCountNotifier.incrementState();
  }
}
