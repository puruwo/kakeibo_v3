extension IntToDateTimeExtension on int {
  DateTime get datetimeFromInt {
    final str = (this).toString();
    DateTime dateTime = DateTime.parse(
        '${str.substring(0, 4)}-${str.substring(4, 6)}-${str.substring(6, 8)}');
    return dateTime;
  }
}

