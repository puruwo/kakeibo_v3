//ほんまはプログラム組みたい
DateTime getReferenceDayOfMonth(int year, int month) {
  Map<int, Map<int, int>> referenceDayMap = {
    2023: {
      1: 25,
      2: 25,
      3: 25,
      4: 25,
      5: 25,
      6: 25,
      7: 25,
      8: 25,
      9: 25,
      10: 25,
      11: 25,
      12: 25
    },
    2024: {
      1: 25,
      2: 25,
      3: 25,
      4: 25,
      5: 25,
      6: 25,
      7: 25,
      8: 25,
      9: 25,
      10: 25,
      11: 25,
      12: 25
    }
  };
  return DateTime(year, month, 25);
}

DateTime getReferenceDay(DateTime dateTime) {
  //現在日の月の基準日を取得
  final thisMonthReferenceDateTime =
      getReferenceDayOfMonth(dateTime.year, dateTime.month);

  //入力した日が、属している基準日よりも前なら
  //一月前の基準日を取得
  if (dateTime.day < thisMonthReferenceDateTime.day) {
    return getReferenceDayOfMonth(
        DateTime(dateTime.year, dateTime.month - 1).year,
        DateTime(dateTime.year, dateTime.month - 1).month);
  }
  //入力した日が、属している基準日よりも後なら
  //属している月の基準日を取得
  else if (thisMonthReferenceDateTime.day <= dateTime.day) {
    return thisMonthReferenceDateTime;
  } else {
    return thisMonthReferenceDateTime;
  }
}

DateTime getNextReferenceDay(DateTime dateTime) {
  //入力したdatetimeの属する基準日を取得
  final referenceDay = getReferenceDay(dateTime);

  //今の基準日の月に加算原産をし次基準日を取得
  final nextReferenceDt = getReferenceDayOfMonth(
      DateTime(referenceDay.year, referenceDay.month + 1).year,
      DateTime(referenceDay.year, referenceDay.month + 1).month);
  return nextReferenceDt;
}

DateTime getPreviousReferenceDay(DateTime dateTime) {
  //入力したdatetimeの属する基準日を取得
  final referenceDay = getReferenceDay(dateTime);

  //今の基準日の月に加算原産をし前基準日を取得
  final previousReferenceDt = getReferenceDayOfMonth(
      DateTime(referenceDay.year, referenceDay.month - 1).year,
      DateTime(referenceDay.year, referenceDay.month - 1).month);
  return previousReferenceDt;
}

String getYYDDLabel(DateTime dt) {
  final referenceDateTime = getReferenceDay(dt);
  final label = '${referenceDateTime.year} 年 ${referenceDateTime.month} 月';
  return label;
}
