import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path_provider/path_provider.dart';
import 'package:wheresmymoney_old_nav/Models/Currency.dart';
import 'package:wheresmymoney_old_nav/Singleton/Global.dart';
import '../Models/Transaction.dart';
import '../Models/Account.dart';

class DatabaseHandler {

  static final _databaseName = "WheresMyMoney.db";
  static final _databaseVersion = 1;

  static final currenciesTable = 'currencies';

  static final currencyId = 'id';
  static final currencyName = 'name';
  static final currencyTag = 'tag';
  static final currencyLinkRatio = 'linkRatio';
  static final currencyPointPosition = 'pointPosition';
  static final currencyLinkTag = 'linkTag';

  static final accountsTable = 'accounts';

  static final accountId = 'id';
  static final accountName = 'name';
  static final accountType = 'type';
  static final accountCurrencyTag = 'tagC';

  static final transactionsTable = 'transactions';

  static final transactionId = 'id';
  static final transactionType = 'type';//0-setting, 1-income, 2-expense
  static final transactionAmount = 'amount';
  static final transactionDateTime = 'datetime';
  static final transactionAccountId = 'idA';

  // make this a singleton class
  DatabaseHandler._privateConstructor();
  static final DatabaseHandler instance = DatabaseHandler._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $currenciesTable(
            $currencyName TEXT PRIMARY KEY NOT NULL,
            $currencyTag TEXT NOT NULL,
            $currencyLinkRatio TEXT NOT NULL,
            $currencyPointPosition INTEGER NOT NULL,
            $currencyLinkTag TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $accountsTable(
            $accountId INTEGER PRIMARY KEY AUTOINCREMENT,
            $accountName TEXT NOT NULL,
            $accountType TEXT NOT NULL,
            $accountCurrencyTag TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $transactionsTable(
            $transactionId INTEGER PRIMARY KEY AUTOINCREMENT,
            $transactionType INTEGER NOT NULL,
            $transactionAmount TEXT NOT NULL,
            $transactionDateTime TEXT NOT NULL,
            $transactionAccountId INTEGER NOT NULL
          )
          ''');
  }

  void insertCurrency(Currency currencyToInsert) async {
    Map<String, dynamic> row = {
      currencyName  : currencyToInsert.name,
      currencyTag  : currencyToInsert.tag,
      currencyLinkRatio  : currencyToInsert.linkRatio.toString(),
      currencyPointPosition  : currencyToInsert.pointPosition,
      currencyLinkTag  : currencyToInsert.link.tag,
    };
    await insert(currenciesTable, row);
  }

  Future<List<Currency>> readAllCurrencies() async{
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM $currenciesTable');
    if(result.toList().isEmpty){
      return null;
    }
    else{
      List<Currency> toReturn = List<Currency>();
      //creation
      for(int i=0; i<result.length; i++){
        String name = result[i].values.toList().elementAt(0);
        String tag = result[i].values.toList().elementAt(1);
        Decimal linkRatio = Decimal.parse(result[i].values.toList().elementAt(2));
        int pointPosition = result[i].values.toList().elementAt(3);
        Currency currency = Currency(null, linkRatio, tag, name, pointPosition);
        toReturn.add(currency);
      }
      //linking
      for(int i=0; i<result.length; i++){
        for(int j=0; j<result.length; j++){
          if(toReturn.elementAt(j).tag == result[i].values.toList().elementAt(4)){
            toReturn.elementAt(i).link = toReturn.elementAt(j);
          }
        }
      }
      return toReturn;
    }
  }

  Future<int> readCurrenciesAmount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $currenciesTable'));
  }

  Future<int> deleteCurrency(String tag) async {
    Database db = await instance.database;
    return await db.delete(currenciesTable, where: '$currencyTag = ?', whereArgs: [tag]);
  }

  Future<int> updateCurrency(Currency currencyToUpdate) async {
    Map<String, dynamic> row = {
      currencyName  : currencyToUpdate.name,
      currencyTag  : currencyToUpdate.tag,
      currencyLinkRatio  : currencyToUpdate.linkRatio.toString(),
      currencyPointPosition  : currencyToUpdate.pointPosition,
      currencyLinkTag  : currencyToUpdate.link.tag,
    };
    Database db = await instance.database;
    return await db.update(currenciesTable, row, where: '$currencyTag = ?', whereArgs: [currencyToUpdate.tag]);
  }

  void insertAccount(Account accountToInsert) async {
    Map<String, dynamic> row = {
      accountName  : accountToInsert.name,
      accountType  : accountToInsert.type,
      accountCurrencyTag  : accountToInsert.currency.tag,
    };
    accountToInsert.IdA = await insert(accountsTable, row);
  }

  Currency getAccountCurrency(Map<String, dynamic> result){
    Currency accountCurrency;
    for(int j=0; j<Global.instance.currenciesList.length; j++){
      if(Global.instance.currenciesList[j].tag == result.values.toList().elementAt(3)){
        accountCurrency = Global.instance.currenciesList[j];
      }
    }
    if(accountCurrency==null){
      accountCurrency = Global.instance.rootCurrency;
    }
    return accountCurrency;
  }


  Future<List<Account>> readAllAccounts() async{
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM $accountsTable');
    List<Account> toReturn = [];
    //creation
    for(int i=0; i<result.length; i++){
      int id = result[i].values.toList().elementAt(0);
      String name = result[i].values.toList().elementAt(1);
      String type = result[i].values.toList().elementAt(2);
      Currency accountCurrency;

      accountCurrency = getAccountCurrency(result[i]);
      Account account = Account(name, accountCurrency, type);
      account.IdA = id;
      toReturn.add(account);
    }
    return toReturn;
  }

  Future<int> deleteAccount(int id) async {
    Database db = await instance.database;
    return await db.delete(accountsTable, where: '$accountId = ?', whereArgs: [id]);
  }

  void insertTransaction(Transaction transactionToInsert) async {
    Map<String, dynamic> row = {
      transactionType  : transactionToInsert.getType(),
      transactionAmount  : transactionToInsert.amount.toString(),
      transactionDateTime  : transactionToInsert.dateTime.toIso8601String(),
      transactionAccountId  : transactionToInsert.transactionAccount.IdA,
    };
    transactionToInsert.IdT = await insert(transactionsTable, row);
  }

  Future<List<Transaction>> readAllTransactions() async{
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM $transactionsTable');
    List<Transaction> toReturn = [];
    //clearing transaction lists from accounts
    for(int j=0; j<Global.instance.accountsList.length; j++){
      Global.instance.accountsList.elementAt(j).transactionsList = [];
    }
    //creation
    for(int i=0; i<result.length; i++){
      int IdT = result[i].values.toList().elementAt(0);
      int type = result[i].values.toList().elementAt(1);
      BigInt amount = BigInt.parse(result[i].values.toList().elementAt(2));
      DateTime dateTime = DateTime.parse(result[i].values.toList().elementAt(3));
      int IdA = result[i].values.toList().elementAt(4);
      Account transactionAccount;

      for(int j=0; j<Global.instance.accountsList.length; j++){
        if(IdA == Global.instance.accountsList.elementAt(j).IdA){
          transactionAccount = Global.instance.accountsList.elementAt(j);
        }
      }

      if(transactionAccount!=null){
        switch(type){
          case 0:
            Setting settingToAdd = Setting(IdT, amount, transactionAccount);
            toReturn.add(settingToAdd);
            settingToAdd.dateTime = dateTime;
            break;
          case 1:
            Income incomeToAdd = Income(IdT, amount, transactionAccount);
            toReturn.add(incomeToAdd);
            incomeToAdd.dateTime = dateTime;
            break;
          case 2:
            Expense expenseToAdd = Expense(IdT, amount, transactionAccount);
            toReturn.add(expenseToAdd);
            expenseToAdd.dateTime = dateTime;
            break;
        }
      }
    }
    return toReturn;
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await instance.database;
    return await db.delete(transactionsTable, where: '$transactionId = ?', whereArgs: [id]);
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount(String table) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }
}