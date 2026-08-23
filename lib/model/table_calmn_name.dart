class SqfExpense {
  static const tableName = 'expense';

  static const id = '_id';
  static const expenseSmallCategoryId = 'expense_small_category_id';
  static const date = 'date';
  static const price = 'price';
  static const memo = 'memo';
  static const incomeSourceBigCategory = 'income_source_big_category';
  // 固定費マスタ(fixed_cost._id)への参照。NULL=通常支出。v10で追加
  static const fixedCostId = 'fixed_cost_id';
  // 0=未確定 / 1=確定。通常支出は常に1。v10で追加
  static const isConfirmed = 'is_confirmed';
  // 予想額。変動固定費の実績生成時に設定し、確定後も保持する。v10で追加
  static const estimatedPrice = 'estimated_price';

  /// 集計で使う実効金額のSQL共通式（仕様 §7.1）
  ///
  /// 未確定の固定費行は実額(price)を持たないため予想額(estimated_price)で代替する。
  /// 支出の集計SQLは必ずこの式を使い、COALESCEを各所に直書きしない。
  static const effectivePriceExpr = 'COALESCE($price, $estimatedPrice)';

  /// テーブル別名つきの実効金額式（JOINを含むSQL用）
  static String effectivePriceExprOf(String alias) =>
      'COALESCE($alias.$price, $alias.$estimatedPrice)';
}

class SqfIncome {
  static const tableName = 'income';

  static const id = '_id';
  static const incomeSmallCategoryId = 'income_small_category_id';
  static const date = 'date';
  static const price = 'price';
  static const memo = 'memo';
}

class SqfBudget {
  static const tableName = 'budget';

  static const id = '_id';
  static const expenseBigCategoryId = 'expense_big_category_id';
  static const month = 'month';
  static const price = 'price';
}

class SqfExpenseSmallCategory {
  static const tableName = 'expense_small_category';

  static const id = '_id';
  static const bigCategoryKey = 'big_category_key';
  static const name = 'name';
  static const smallCategoryOrderKey = 'small_category_order_key';
  static const displayedOrderInBig = 'displayed_order_in_big';
  static const defaultDisplayed = 'default_displayed';
}

class SqfExpenseBigCategory {
  static const tableName = 'expense_big_category';

  static const id = '_id';
  static const name = 'name';
  static const colorCode = 'color_code';
  static const resourcePath = 'resource_path';
  static const displayOrder = 'display_order';
  static const isDisplayed = 'is_displayed';
}

class SqfIncomeSmallCategory {
  static const tableName = 'income_small_category';

  static const id = '_id';
  static const bigCategoryKey = 'big_category_key';
  static const name = 'name';
  static const smallCategoryOrderKey = 'small_category_order_key';
  static const displayedOrderInBig = 'displayed_order_in_big';
  static const defaultDisplayed = 'default_displayed';
}

class SqfIncomeBigCategory {
  static const tableName = 'income_big_category';

  static const id = '_id';
  static const name = 'name';
  static const colorCode = 'color_code';
  static const resourcePath = 'resource_path';
  // 会計種別（1=生活収支, 2=特別枠）。v9で追加
  static const accountType = 'account_type';
}

class SqfFixedCost {
  static const tableName = 'fixed_cost';

  static const id = '_id';
  static const name = 'name';
  static const variable = 'variable';
  static const price = 'price';
  static const estimatedPrice = 'estimated_price';
  // 予想額を手動で設定したか（0=自動算出／1=手動）。v10で追加。仕様 §6.9
  static const estimatedPriceIsManual = 'estimated_price_is_manual';
  // 支出小カテゴリー(expense_small_category._id)への参照。v10で追加
  static const expenseSmallCategoryId = 'expense_small_category_id';
  static const intervalNumber = 'interval_number';
  static const intervalUnit = 'interval_unit';
  static const firstPaymentDate = 'first_payment_date';
  static const recentPaymentDate = 'recent_payment_date';
  static const nextPaymentDate = 'next_payment_date';
  static const deleteFlag = 'delete_flag';
}

class SqfBatchHistory {
  static const tableName = 'batch_history';

  static const id = '_id';
  static const startDate = 'start_date';
  static const endDate = 'end_date';
  static const status = 'status';
}

