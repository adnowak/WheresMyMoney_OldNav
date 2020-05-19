import 'package:wheresmymoney_old_nav/Models/Account.dart';

import '../Singleton/DatabaseHandler.dart';
import '../Singleton/Global.dart';

abstract class Transaction {
  int _IdT;
  BigInt _amount;
  DateTime _dateTime;
  Account transactionAccount;

  BigInt get amount => _amount;

  int get IdT => _IdT;

  DateTime get dateTime => _dateTime;

  set IdT(int value) {
    _IdT = value;
  }

  set dateTime(DateTime value) {
    _dateTime = value;
  }

  set amount(BigInt value) {
    _amount = value;
  }

  BigInt takeIntoAccount(BigInt baseBalance);
  int getType();
}

class Setting implements Transaction {
  @override
  BigInt _amount;

  @override
  Account transactionAccount;

  Setting(this._IdT, this._amount, this.transactionAccount) {
    _dateTime = DateTime.now();
    transactionAccount.transactionsList.add(this);
    transactionAccount.countBalance();
  }

  int get IdT => _IdT;

  String toString(){
    return "Set to: ${transactionAccount.currency.toNaturalLanguage(_amount)}";
  }

  @override
  int _IdT;

  @override
  BigInt get amount => _amount;

  @override
  BigInt takeIntoAccount(BigInt baseBalance) {
    return _amount;
  }

  @override
  set amount(BigInt value) {
    _amount = value;
  }

  @override
  DateTime _dateTime;

  @override
  DateTime get dateTime => _dateTime;

  @override
  int getType() {
    return 0;
  }

  @override
  set IdT(int value) {
    _IdT = value;
  }

  @override
  set dateTime(DateTime value) {
    _dateTime = value;
  }
}

class Income implements Transaction {
  @override
  BigInt _amount;

  @override
  Account transactionAccount;

  Income(this._IdT, this._amount, this.transactionAccount) {
    _dateTime = DateTime.now();
    transactionAccount.transactionsList.add(this);
    transactionAccount.countBalance();
  }

  String toString(){
    return "Income: ${transactionAccount.currency.toNaturalLanguage(_amount)}";
  }

  @override
  int _IdT;

  @override
  int get IdT => null;

  @override
  BigInt get amount => _amount;

  @override
  BigInt takeIntoAccount(BigInt baseBalance) {
    return baseBalance+_amount;
  }

  @override
  set amount(BigInt value) {
    _amount = value;
  }

  @override
  DateTime _dateTime;

  @override
  DateTime get dateTime => _dateTime;

  @override
  int getType() {
    return 1;
  }

  @override
  set IdT(int value) {
    _IdT = value;
  }

  @override
  set dateTime(DateTime value) {
    _dateTime = value;
  }
}

class Expense implements Transaction {
  @override
  BigInt _amount;

  @override
  int _IdT;

  @override
  Account transactionAccount;

  Expense(this._IdT, this._amount, this.transactionAccount) {
    _dateTime = DateTime.now();
    transactionAccount.transactionsList.add(this);
    transactionAccount.countBalance();
  }

  int get IdT => _IdT;

  @override
  BigInt get amount => _amount;

  @override
  DateTime _dateTime;

  @override
  DateTime get dateTime => _dateTime;

  @override
  int getType() {
    return 2;
  }

  @override
  set IdT(int value) {
    _IdT = value;
  }

  @override
  set dateTime(DateTime value) {
    _dateTime = value;
  }

  @override
  set amount(BigInt value) {
    _amount = value;
  }

  @override
  BigInt takeIntoAccount(BigInt baseBalance) {
    return baseBalance-_amount;
  }

  String toString(){
    return "Expense: ${transactionAccount.currency.toNaturalLanguage(_amount)}";
  }
}