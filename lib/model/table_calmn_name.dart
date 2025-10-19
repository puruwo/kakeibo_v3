class SqfExpense {
  static const tableName = 'expense';

  static const id = '_id';
  static const expenseSmallCategoryId = 'expense_small_category_id';
  static const date = 'date';
  static const price = 'price';
  static const memo = 'memo';
  static const incomeSourceBigCategory = 'income_source_big_category';
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
}

class SqfFixedCost {
  static const tableName = 'fixed_cost';

  static const id = '_id';
  static const name = 'name';
  static const variable = 'variable';
  static const price = 'price';
  static const estimatedPrice = 'estimated_price';
  static const fixedCostCategoryId = 'fixed_cost_category_id';
  static const intervalNumber = 'interval_number';
  static const intervalUnit = 'interval_unit';
  static const firstPaymentDate = 'fiirst_payment_date';
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

class SqfFixedCostExpense {
  static const tableName = 'fixed_cost_expense';

  static const id = '_id';
  static const fixedCostId = 'fixed_cost_id';
  static const fixedCostCategoryId = 'fixed_cost_category_id';
  static const date = 'date';
  static const price = 'price';
  static const name = 'name';
  static const confirmedCostType = 'confirmed_cost_type';
  static const isConfirmed = 'is_confirmed';
}

class SqfFixedCostCategory {
  static const tableName = 'fixed_cost_category';

  static const id = '_id';
  static const name = 'name';
  static const colorCode = 'color_code';
  static const resourcePath = 'resource_path';
  static const displayOrder = 'display_order';
  static const isDisplayed = 'is_displayed';
}
