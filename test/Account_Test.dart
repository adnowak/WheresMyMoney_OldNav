import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wheresmymoney_old_nav/Models/Account.dart';
import 'package:wheresmymoney_old_nav/Models/Currency.dart';
import 'package:wheresmymoney_old_nav/Models/Transaction.dart';

void main() {
  test("Test countBalance()", () {
    Account testedAccount = Account("Test", Currency(null, Decimal.parse("1.0"), "test", "test", 0), "Test");
    Income(0, BigInt.from(100), testedAccount);
    Income(0, BigInt.from(100), testedAccount);
    Income(0, BigInt.from(100), testedAccount);
    Income(0, BigInt.from(100), testedAccount);
    testedAccount.countBalance();

    expect(testedAccount.balance , BigInt.from(400));
  });

  test("Test getIcon()", () {
    Account testedAccount = Account("Deposit", Currency(null, Decimal.parse("1.0"), "test", "test", 0), "Deposit");

    expect(testedAccount.getIcon().icon , Icon(Icons.card_travel).icon);
  });
}

