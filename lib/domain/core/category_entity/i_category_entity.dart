abstract class ICategoryEntity{
  int get id;
  int get smallCategoryOrderKey;
  int get bigCategoryKey;
  int get displaydOrderInBig;
  String get smallCategoryName;
  int get defaultDisplayed;

  String get bigCategoryName;
  String get colorCode;
  String get resourcePath;

  // 表示用のソートキー
  int get sortKey;
}