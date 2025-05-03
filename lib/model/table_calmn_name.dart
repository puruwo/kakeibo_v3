class SqfExpense {
  static const tableName = 'expense';

  static const id = '_id';
  static const date = 'date';
  static const price = 'price';
  static const paymentCategoryId = 'payment_category_id';
  static const memo = 'memo';
  
}

class SqfIncome {
  final String _tableName = 'TBL002';

  final String _id = '_id';
  final String _date = 'date';
  final String _price = 'price';
  final String _incomeCategoryId = 'income_category_id';
  final String _memo = 'memo';

  String get tableName => _tableName;
  String get id => _id;
  String get date => _date;
  String get price => _price;
  String get incomeCategoryId => _incomeCategoryId;
  String get memo => _memo;
}

class SqfBudget {
  final String _tableName = 'TBL003';

  final String _id = '_id';
  final String _date = 'date';
  final String _bigCategoryId = 'big_category_id';
  final String _price = 'price';

  String get tableName => _tableName;
  String get id => _id;
  String get date => _date;
  String get bigCategoryId => _bigCategoryId;
  String get price => _price;
}

class TBL201RecordKey {
  final String _tableName = 'TBL201';

  final String _id = '_id';
  final String _smallCategoryOrderKey = 'small_category_order_key';
  final String _bigCategoryKey = 'big_category_key';
  final String _displayedOrderInBig = 'displayed_order_in_big';
  final String _categoryName = 'category_name';
  final String _defaultDisplayed = 'default_displayed';

  String get tableName => _tableName;
  String get id => _id;
  String get smallCategoryOrderKey => _smallCategoryOrderKey;
  String get bigCategoryKey => _bigCategoryKey;
  String get displayedOrderInBig => _displayedOrderInBig;
  String get categoryName => _categoryName;
  String get defaultDisplayed => _defaultDisplayed;
}

class SqfExpenseBigCategory {
  final String _tableName = 'TBL202';

  final String _id = '_id';
  final String _colorCode = 'color_code';
  final String _bigCategoryName = 'big_category_name';
  final String _resourcePath = 'resource_path';
  final String _displayOrder = 'display_order';
  final String _isDisplayed = 'is_displayed';

  String get tableName => _tableName;
  String get id => _id;
  String get colorCode => _colorCode;
  String get bigCategoryName => _bigCategoryName;
  String get resourcePath => _resourcePath;
  String get displayOrder => _displayOrder;
  String get isDisplayed => _isDisplayed;
}

class TBL211RecordKey {
  final String _tableName = 'TBL211';

  final String _id = '_id';
  final String _smallCategoryOrderKey = 'small_category_order_key';
  final String _bigCategoryKey = 'big_category_key';
  final String _displayedOrderInBig = 'displayed_order_in_big';
  final String _categoryName = 'category_name';
  final String _defaultDisplayed = 'default_displayed';

  String get tableName => _tableName;
  String get id => _id;
  String get smallCategoryOrderKey => _smallCategoryOrderKey;
  String get bigCategoryKey => _bigCategoryKey;
  String get displayedOrderInBig => _displayedOrderInBig;
  String get categoryName => _categoryName;
  String get defaultDisplayed => _defaultDisplayed;
}

class TBL212RecordKey {
  final String _tableName = 'TBL212';

  final String _id = '_id';
  final String _colorCode = 'color_code';
  final String _bigCategoryName = 'big_category_name';
  final String _resourcePath = 'resource_path';
  final String _displayOrder = 'display_order';
  final String _isDisplayed = 'is_displayed';

  String get tableName => _tableName;
  String get id => _id;
  String get colorCode => _colorCode;
  String get bigCategoryName => _bigCategoryName;
  String get resourcePath => _resourcePath;
  String get displayOrder => _displayOrder;
  String get isDisplayed => _isDisplayed;
}


