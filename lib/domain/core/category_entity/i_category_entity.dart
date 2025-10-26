abstract class ICategoryEntity{
  int get id;
  String get categoryName;
  String get colorCode;
  String get resourcePath;

  // 表示用のソートキー
  int get sortKey;
}