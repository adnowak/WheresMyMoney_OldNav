import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wheresmymoney_old_nav/Account.dart';
import 'package:wheresmymoney_old_nav/Currency.dart';
import 'package:wheresmymoney_old_nav/Transaction.dart';

void main() {
  test("Test countBalance()", () {
    Account testedAccount = Account("Test", Currency(null, Decimal.parse("1.0"), "test", "test", 0), "Test");
    Transaction transaction1 = Income(0, BigInt.from(100), testedAccount);
    Transaction transaction2 = Income(0, BigInt.from(100), testedAccount);
    Transaction transaction3 = Income(0, BigInt.from(100), testedAccount);
    Transaction transaction4 = Income(0, BigInt.from(100), testedAccount);
    testedAccount.countBalance();

    expect(testedAccount.balance , BigInt.from(400));
  });

  test("Test getIcon()", () {
    Account testedAccount = Account("Deposit", Currency(null, Decimal.parse("1.0"), "test", "test", 0), "Deposit");

    expect(testedAccount.getIcon() , Icon(Icons.card_travel));
  });
}

