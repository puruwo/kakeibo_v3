abstract class ICategoryEntity{
  int get id;
  String get categoryName;
  String get colorCode;
  String get resourcePath;

  // 表示用のソートキー
  int get sortKey;

  // 所属する大カテゴリーのID（全カテゴリーの一覧で大カテゴリーごとに束ねる。KP-032）
  int get bigCategoryKey;

  // 大カテゴリー内の表示順（KP-032）
  int get displaydOrderInBig;

  // 記録画面に直接表示するか（1=表示 / 0=表示しない。KP-032）
  int get defaultDisplayed;
}
