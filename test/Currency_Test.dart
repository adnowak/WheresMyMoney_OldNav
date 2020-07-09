import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wheresmymoney_old_nav/Models/Currency.dart';
import 'package:mockito/mockito.dart';
import 'package:wheresmymoney_old_nav/Singleton/Global.dart';

class GlobalMocked extends Mock implements Global {}

void main(){
  test("Test getDivision()", () {

    Currency testedCurrency1 = Currency(null, Decimal.parse("1.0"), "test", "test", 2);
    Currency testedCurrency2 = Currency(null, Decimal.parse("1.0"), "test", "test", 1);
    Currency testedCurrency3 = Currency(null, Decimal.parse("1.0"), "test", "test", 0);
    Currency testedCurrency4 = Currency(null, Decimal.parse("1.0"), "test", "test", 5);

    expect(testedCurrency1.getDivision() , BigInt.from(100));
    expect(testedCurrency2.getDivision() , BigInt.from(10));
    expect(testedCurrency3.getDivision() , BigInt.from(1));
    expect(testedCurrency4.getDivision() , BigInt.from(100000));
  });

  test("Test toNaturalLanguage()", () {
    Currency testedCurrency1 = Currency(null, Decimal.parse("1.0"), "test", "test", 2);
    Currency testedCurrency2 = Currency(null, Decimal.parse("1.0"), "test", "test", 1);
    Currency testedCurrency3 = Currency(null, Decimal.parse("1.0"), "test", "test", 0);
    Currency testedCurrency4 = Currency(null, Decimal.parse("1.0"), "test", "test", 5);
    BigInt amount1 = BigInt.from(10000);
    BigInt amount2 = BigInt.from(-10000);

    expect(testedCurrency1.toNaturalLanguage(amount1) , "100,00 test");
    expect(testedCurrency2.toNaturalLanguage(amount1) , "1000,0 test");
    expect(testedCurrency3.toNaturalLanguage(amount1) , "10000 test");
    expect(testedCurrency4.toNaturalLanguage(amount1) , "0,10000 test");

    expect(testedCurrency1.toNaturalLanguage(amount2) , "-100,00 test");
    expect(testedCurrency2.toNaturalLanguage(amount2) , "-1000,0 test");
    expect(testedCurrency3.toNaturalLanguage(amount2) , "-10000 test");
    expect(testedCurrency4.toNaturalLanguage(amount2) , "-0,10000 test");
  });


}

List<List<Object>> dataProvider(){
  return [[null, Decimal.parse("1.0"), "test", "test", 2, BigInt.from(100)],
    [null, Decimal.parse("1.0"), "test", "test", 1, BigInt.from(10)],
    [null, Decimal.parse("1.0"), "test", "test", 0, BigInt.from(1)],
    [null, Decimal.parse("1.0"), "test", "test", 5, BigInt.from(100000)]];
}