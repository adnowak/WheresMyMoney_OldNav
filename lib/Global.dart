import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'API.dart';
import 'APIRequest.dart';
import 'DatabaseHandler.dart';
import 'Transaction.dart';
import 'Currency.dart';
import 'Account.dart';

class Global
{
  static final Global _instance = Global._privateConstructor();

  bool _editing;
  String _currenciesAPIKey = "7f1e42734df9c2b398a26e895321ec20";
  final String _mainCurrencyPrefs = "mainCurrency";
  final List<String> _currenciesTagSuggestions = [
    "AED","AFN","ALL","AMD","ANG","AOA","ARS","AUD","AWG","AZN","BAM","BBD","BDT","BGN","BHD","BMD","BND","BOB","BRL","BSD",
    "BTC","BTN","BWP","BYN","BZD","CAD","CHF","CLF","CLP","CNY","CRC","CUC","CUP","CVE","CZK","DJF","DKK","DOP","DZD","EGP",
    "ERN","ETB","FJD","FKP","GBP","GEL","GGP","GHS","GIP","GMD","GTQ","GYD","HKD","HNL","HRK","HTG","HUF","ILS","IMP","INR",
    "ISK","JEP","JMD","JOD","JPY","KES","KGS","KMF","KPW","KWD","KYD","KZT","LKR","LRD","LSL","LTL","LVL","LYD","MAD","MDL",
    "MKD","MNT","MOP","MRO","MUR","MVR","MWK","MXN","MYR","MZN","NAD","NGN","NIO","NOK","NPR","NZD","OMR","PAB","PEN","PGK",
    "PHP","PKR","PLN","QAR","RON","RSD","RUB","SAR","SBD","SCR","SDG","SEK","SGD","SHP","SOS","SRD","SVC","SYP","SZL","THB",
    "TJS","TMT","TND","TOP","TRY","TTD","TWD","UAH","USD","UYU","VEF","VUV","WST","XAF","XAG","XAU","XCD","XDR","XOF","XPF",
    "YER","ZAR","ZMW","ZWL"
  ];
  bool _initialized = false;
  DatabaseHandler _databaseHandler = DatabaseHandler.instance;
  Global._privateConstructor();
  List<Currency> _currenciesList;
  List<Account> _accountsList;
  List<Transaction> _transactionsList;
  Currency _mainCurrency;
  Currency _rootCurrency;
  Currency _recentCurrency;
  Account _recentAccount;
  Transaction _recentTransaction;

  List<String> get currenciesTagSuggestions => _currenciesTagSuggestions;

  bool get editing => _editing;

  bool get initialized => _initialized;

  DatabaseHandler get databaseHandler => _databaseHandler;

  static Global get instance {
    return _instance;
  }

  List<Currency> get currenciesList => _currenciesList;

  List<Account> get accountsList => _accountsList;

  List<Transaction> get transactionsList => _transactionsList;

  Currency get rootCurrency => _rootCurrency;

  Account get recentAccount => _recentAccount;

  Transaction get recentTransaction => _recentTransaction;

  Currency get recentCurrency => _recentCurrency;

  Currency get mainCurrency => _mainCurrency;

  set editing(bool value) {
    _editing = value;
  }

  set recentCurrency(Currency value) {
    _recentCurrency = value;
  }

  set recentTransaction(Transaction value) {
    _recentTransaction = value;
  }

  set recentAccount(Account value) {
    _recentAccount = value;
  }

  set mainCurrency(Currency value) {
    _mainCurrency = value;
  }

  Future initiateGlobal() async{
    Currency euro = Currency(null, Decimal.parse("1.0"), "EUR", "Euro", 2);
    euro.link = euro;

    _recentCurrency = euro;
    _mainCurrency = euro;
    _rootCurrency = euro;

    _transactionsList = [];

    if(await databaseHandler.readCurrenciesAmount() == 0){
      euro.insertToDatabase();
      _currenciesList = [
        euro,
      ];
    }
    else{
      _currenciesList = await databaseHandler.readAllCurrencies();
      _recentCurrency = _currenciesList[0];
      try{
        int mainCurrencyId = await getMainCurrencyPrefs();
        for(int i=0; i<currenciesList.length; i++){
          if(currenciesList[i].IdC == mainCurrencyId){
            _mainCurrency = _currenciesList[i];
            break;
          }
        }
      } on Exception{
        _mainCurrency = _currenciesList[0];
      }
      _rootCurrency = _currenciesList[0];
    }

    _accountsList = await databaseHandler.readAllAccounts();
    await Global.instance.databaseHandler.readAllTransactions();
    _editing = false;

    _initialized = true;
  }

  Future<int> getMainCurrencyPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_mainCurrencyPrefs);
  }

  Future<bool> setMainCurrencyPrefs(Currency currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_mainCurrencyPrefs, currency.IdC);
  }

  BigInt getBalance(){
    BigInt balance = BigInt.from(0);
    if(_accountsList!=null){
      for(final account in _accountsList){
        balance += account.currency.toMainCurrency(account.balance);
      }
    }
    return balance;
  }

  String getBalanceToDisplay(){
    return mainCurrency.toNaturalLanguage(getBalance());
  }

  //returns if execution went fine
  bool addIncome(String amountString){
    try{
      BigInt amount = BigInt.parse((Decimal.parse(amountString)*Decimal.parse(recentAccount.currency.getDivision().toString())).toString());
      if(amount<BigInt.from(0))throw Exception();
      Income newIncome = Income(_transactionsList.length, amount, recentAccount);
      _transactionsList.add(newIncome);
      databaseHandler.insertTransaction(newIncome);
      return true;
    }
    on Exception {
      return false;
    }
  }

  //returns if execution went fine
  bool addExpense(String amountString){
    try{
      BigInt amount = BigInt.parse((Decimal.parse(amountString)*Decimal.parse(recentAccount.currency.getDivision().toString())).toString());
      if(amount<BigInt.from(0))throw Exception();
      Expense newExpense = Expense(_transactionsList.length, amount, recentAccount);
      _transactionsList.add(newExpense);
      databaseHandler.insertTransaction(newExpense);
      return true;
    }
    on Exception {
      return false;
    }
  }

  //returns if execution went fine
  bool addSetting(String amountString){
    try{
      BigInt amount = BigInt.parse((Decimal.parse(amountString)*Decimal.parse(recentAccount.currency.getDivision().toString())).toString());
      Setting newSetting = Setting(_transactionsList.length, amount, recentAccount);
      _transactionsList.add(newSetting);
      databaseHandler.insertTransaction(newSetting);
      return true;
    }
    on Exception {
      return false;
    }
  }

  //returns if execution went fine
  bool addAccount(String accountName, Currency accountCurrency, String accountType){
    if(accountName!=null&&accountName!=""){
      Account newAccount = Account(accountName, accountCurrency, accountType);
      _accountsList.add(newAccount);
      newAccount.insertToDatabase();
      return true;
    }
    else{
      return false;
    }
  }

  //returns if execution went fine
  bool addCurrency(String currencyName, String currencyTag, String currencyToLinkRatio, String currencyPointPosition, Currency currencyLink ){
    if(currencyName!=null&&currencyTag!=null&&currencyPointPosition!=null&&currencyToLinkRatio!=null&&"$currencyName$currencyTag$currencyToLinkRatio$currencyPointPosition"!=""){
      try {
        Currency newCurency = Currency(
            currencyLink, Decimal.parse(currencyToLinkRatio), currencyTag,
            currencyName, BigInt.parse(currencyPointPosition).toInt());
        _currenciesList.add(newCurency);
        newCurency.insertToDatabase();
        return true;
      }
      on Exception{
        return false;
      }
    }
    else{
      return false;
    }
  }


    //returns if execution went fine
  bool deleteTransaction(Transaction transactionToDelete){
    try{
      transactionToDelete.deleteTransaction();
      return true;
    }
    on Exception{
      return false;
    }
  }

  //returns if execution went fine
  bool deleteAccount(Account accountToDelete){
    try{
      accountToDelete.deleteAccount();
      return true;
    }
    on Exception{
      return false;
    }
  }

  //returns if execution went fine
  bool deleteCurrency(Currency currencyToDelete){
    try{
      return currencyToDelete.deleteCurrency();
    }
    on Exception{
      return false;
    }
  }

  //returns if execution went fine
  bool editCurrency(Currency currencyToEdit, String newName, String newTag, String newLinkRatio, String newPointPosition, Currency newLink){
    try{
      return currencyToEdit.editCurrency(newName, newTag, newLinkRatio, newPointPosition, newLink);
    }
    on Exception{
      return false;
    }
  }

  void readAllFromDatabase(){
    databaseHandler.readAllCurrencies();
  }

  void makeCurrencyRatesRequest() {
    API currenciesAPI = new API("Currencies",_currenciesAPIKey);
    currenciesAPI.addAPIRequest(RatesRequest());
    currenciesAPI.makeRequest("Rates");
  }
}