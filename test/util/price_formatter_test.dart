import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/util/util.dart';

void main() {
  group('formattedPriceGetter', () {
    test('3桁以下はカンマなし', () {
      expect(formattedPriceGetter(0), '0');
      expect(formattedPriceGetter(999), '999');
    });

    test('4桁以上は3桁ごとにカンマ区切り', () {
      expect(formattedPriceGetter(1000), '1,000');
      expect(formattedPriceGetter(1234567), '1,234,567');
    });
  });

  group('formattedPriceGetterAndZeroAsHyphen', () {
    test('0はハイフン表示', () {
      expect(formattedPriceGetterAndZeroAsHyphen(0), '---');
    });

    test('0以外はカンマ区切り', () {
      expect(formattedPriceGetterAndZeroAsHyphen(12000), '12,000');
    });
  });

  group('yenmarkFormattedPriceGetter', () {
    test('円マーク付きカンマ区切り', () {
      expect(yenmarkFormattedPriceGetter(1234567), '¥ 1,234,567');
    });

    test('0円', () {
      expect(yenmarkFormattedPriceGetter(0), '¥ 0');
    });
  });

  group('signedYenmarkFormattedPriceGetter', () {
    test('負の値はマイナス記号付き', () {
      expect(signedYenmarkFormattedPriceGetter(-5400), '¥ -5,400');
    });

    test('showPlusSign=trueで正の値はプラス記号付き', () {
      expect(
        signedYenmarkFormattedPriceGetter(1200, showPlusSign: true),
        '¥ +1,200',
      );
    });

    test('showPlusSign=false（既定）で正の値は符号なし', () {
      expect(signedYenmarkFormattedPriceGetter(1200), '¥ 1,200');
    });

    test('0は符号なし', () {
      expect(signedYenmarkFormattedPriceGetter(0, showPlusSign: true), '¥ 0');
    });
  });
}
