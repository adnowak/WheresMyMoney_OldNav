import 'package:flutter/material.dart';
import 'package:wheresmymoney_old_nav/Global.dart';
import 'package:wheresmymoney_old_nav/Transaction.dart';

import 'Currency.dart';
import 'DatabaseHandler.dart';

class Account
{
  int _IdA;
  String _name;
  Currency _currency;
  BigInt _balance = BigInt.from(0);
  List<Transaction> _transactionsList = List<Transaction>();
  String _type;
  static List<String> accountTypes = ["Wallet","Bank Account","Stock Shares","Cryptocurrency Account","Credit Card","Deposit","Loan","Other Possesion"];

  int get IdA => _IdA;

  String get type => _type;

  List<Transaction> get transactionsList => _transactionsList;

  String get name => _name;

  BigInt get balance => _balance;

  Currency get currency => _currency;

  set IdA(int value) {
    _IdA = value;
  }

  set balance(BigInt value) {
    _balance = value;
  }

  set transactionsList(List<Transaction> value) {
    _transactionsList = value;
  }

  Account(this._name, this._currency, this._type){
    _transactionsList = List<Transaction>();
    this._balance = BigInt.from(0);
  }

  String getData(){
    return "$_name: ${_currency.toNaturalLanguage(_balance)}";
  }

  Icon getIcon(){
    switch(_type){
      case "Wallet":
        return Icon(Icons.account_balance_wallet);
      break;
      case "Bank Account":
        return Icon(Icons.account_balance);
        break;
      case "Stock Shares":
        return Icon(Icons.trending_up);
        break;
      case "Cryptocurrency Account":
        return Icon(Icons.lock_outline);
        break;
      case "Credit Card":
        return Icon(Icons.credit_card);
        break;
      case "Deposit":
        return Icon(Icons.card_travel);
        break;
      case "Loan":
        return Icon(Icons.home);
        break;
      default:
        return Icon(Icons.store);
        break;
    }
  }

  void countBalance(){
    _balance = BigInt.from(0);
    for(int i =0; i<_transactionsList.length; i++){
      _balance = _transactionsList[i].takeIntoAccount(_balance);
    }
  }

  void insertToDatabase(){
    DatabaseHandler.instance.insertAccount(this);
  }

  void deleteAccount(){
    Global.instance.accountsList.remove(this);
    for(int i =0; i<_transactionsList.length; i++){
      _transactionsList[i].deleteTransaction();
    }
    DatabaseHandler.instance.deleteAccount(_IdA);
  }
}