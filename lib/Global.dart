import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

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
  String _currenciesAPIKey = "";
  final String _mainCurrencyPrefs = "mainCurrency";
  final List<String> _baseCurrenciesTags = [
    "AED","AFN","ALL","AMD","ANG","AOA","ARS","AUD","AWG","AZN","BAM","BBD","BDT","BGN","BHD","BMD","BND","BOB","BRL","BSD",
    "BTC","BTN","BWP","BYN","BZD","CAD","CHF","CLF","CLP","CNY","CRC","CUC","CUP","CVE","CZK","DJF","DKK","DOP","DZD","EGP",
    "ERN","ETB","FJD","FKP","GBP","GEL","GGP","GHS","GIP","GMD","GTQ","GYD","HKD","HNL","HRK","HTG","HUF","ILS","IMP","INR",
    "ISK","JEP","JMD","JOD","JPY","KES","KGS","KMF","KPW","KWD","KYD","KZT","LKR","LRD","LSL","LTL","LVL","LYD","MAD","MDL",
    "MKD","MNT","MOP","MRO","MUR","MVR","MWK","MXN","MYR","MZN","NAD","NGN","NIO","NOK","NPR","NZD","OMR","PAB","PEN","PGK",
    "PHP","PKR","PLN","QAR","RON","RSD","RUB","SAR","SBD","SCR","SDG","SEK","SGD","SHP","SOS","SRD","SVC","SYP","SZL","THB",
    "TJS","TMT","TND","TOP","TRY","TTD","TWD","UAH","USD","UYU","VEF","VUV","WST","XAF","XAG","XAU","XCD","XDR","XOF","XPF",
    "YER","ZAR","ZMW","ZWL"
  ];
  bool _initiated = false;
  Global._privateConstructor();
  List<Currency> _currenciesList;
  List<Account> _accountsList;
  List<Transaction> _transactionsList;
  Currency _mainCurrency;
  Currency _rootCurrency;
  Currency _recentCurrency;
  Account _recentAccount;
  Transaction _recentTransaction;

  List<String> get baseCurrenciesTags => _baseCurrenciesTags;

  bool get editing => _editing;

  bool get initiated => _initiated;
  
  static Global get instance {
    return _instance;
  }

  List<Currency> get currenciesList =>_currenciesList;

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
    _accountsList = [];
    _transactionsList = [];

    if(await DatabaseHandler.instance.readCurrenciesAmount() == 0){
      _currenciesList = List<Currency>();
      addAllBaseCurrencies();
      await makeCurrencyRatesRequest();
      saveAllBaseCurrencies();
    }
    else{
      _currenciesList = await DatabaseHandler.instance.readAllCurrencies();
      _recentCurrency = _currenciesList[0];
      _mainCurrency = _currenciesList[0];
      _rootCurrency = _currenciesList[0];
    }

    try{
      String mainCurrencyTag = await getMainCurrencyPrefs();
      for(int i=0; i<_currenciesList.length; i++){
        if(_currenciesList[i].tag == mainCurrencyTag){
          _mainCurrency = _currenciesList[i];
          break;
        }
      }
    } on Exception{}

    _accountsList = await DatabaseHandler.instance.readAllAccounts();
    await DatabaseHandler.instance.readAllTransactions();
    _editing = false;

    _initiated = true;
  }

  void addAllBaseCurrencies(){
    Currency euro = Currency(null, Decimal.parse("1.0"), "EUR", "Euro", 2);
    euro.link = euro;
    _currenciesList = List<Currency>();
    _currenciesList.add(euro);
    _recentCurrency = euro;
    _mainCurrency = euro;
    _rootCurrency = euro;

    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "AED", "United Arab Emirates dirham", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "AFN", "Afghan afghani", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ALL", "Albanian lek", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "AMD", "Armenian dram", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ANG", "Netherlands Antillean guilder", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "AOA", "Angolan kwanza", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ARS", "Argentine peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "AUD", "Australian dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "AWG", "Aruban florin", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "AZN", "Azerbaijani manat", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BAM", "Bosnia and Herzegovina convertible mark", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BBD", "Barbadian dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BDT", "Bangladeshi taka", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BGN", "Bulgarian lev", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BHD", "Bahraini dinar", 3));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BIF", "Burundian franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BMD", "Bermudian dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BND", "Brunei dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BOB", "Bolivian boliviano", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BRL", "Brazilian real", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BSD", "Bahamian dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BTC", "Bitcoin", 12));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BTN", "Bhutanese ngultrum", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BWP", "Botswana pula", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BYN", "Belarusian ruble", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "BZD", "Belize dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CAD", "Canadian dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CDF", "Congolese franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CHF", "Swiss franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CLF", "Chilean Unit of Account", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CLP", "Chilean peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CNY", "Chinese yuan", 1));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "COP", "Colombian peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CRC", "Costa Rican colón", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CUC", "Cuban convertible peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CUP", "Cuban peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CVE", "Cape Verdean escudo", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "CZK", "Czech koruna", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "DJF", "Djiboutian franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "DKK", "Danish krone", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "DOP", "Dominican peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "DZD", "Algerian dinar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "EGP", "Egyptian pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ERN", "Eritrean nakfa", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ETB", "Ethiopian birr", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "FJD", "Fijian dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "FKP", "Falkland Islands pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GBP", "British pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GEL", "Georgian lari", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GGP", "Guernsey pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GHS", "Ghanaian cedi", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GIP", "Gibraltar pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GMD", "Gambian dalasi", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GNF", "Guinean franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GTQ", "Guatemalan quetzal", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "GYD", "Guyanese dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "HKD", "Hong Kong dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "HNL", "Honduran lempira", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "HRK", "Croatian kuna", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "HTG", "Haitian gourde", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "HUF", "Hungarian forint", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "IDR", "Indonesian rupiah", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ILS", "Israeli new shekel", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "IMP", "Manx pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "INR", "Indian rupee", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "IQD", "Iraqi dinar", 3));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "IRR", "Iranian rial", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ISK", "Icelandic króna", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "JEP", "Jersey pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "JMD", "Jamaican dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "JOD", "Jordanian dinar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "JPY", "Japanese yen", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KES", "Kenyan shilling", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KGS", "Kyrgyzstani som", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KHR", "Cambodian riel", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KMF", "Comorian franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KPW", "North Korean won", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KRW", "South Korean won", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KWD", "Kuwaiti dinar", 3));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KYD", "Cayman Islands dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "KZT", "Kazakhstani tenge", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "LAK", "Lao kip", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "LBP", "Lebanese pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "LKR", "Sri Lankan rupee", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "LRD", "Liberian dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "LSL", "Lesotho loti", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "LYD", "Libyan dinar", 3));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MAD", "Moroccan dirham", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MDL", "Moldovan leu", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MGA", "Malagasy ariary", 1));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MKD", "Macedonian denar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MMK", "Burmese kyat", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MNT", "Mongolian tögrög", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MOP", "Macanese pataca", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MRO", "Mauritanian ouguiya", 1));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MUR", "Mauritian rupee", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MVR", "Maldivian rufiyaa", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MWK", "Malawian kwacha", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MXN", "Mexican peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MYR", "Malaysian ringgit", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "MZN", "Mozambican metical", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "NAD", "Namibian dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "NGN", "Nigerian naira", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "NIO", "Nicaraguan córdoba", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "NOK", "Norwegian krone", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "NPR", "Nepalese rupee", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "NZD", "New Zealand dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "OMR", "Omani rial", 3));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "PAB", "Panamanian balboa", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "PEN", "Peruvian sol", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "PGK", "Papua New Guinean kina", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "PHP", "Philippine peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "PKR", "Pakistani rupee", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "PLN", "Polish złoty", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "PYG", "Paraguayan guaraní", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "QAR", "Qatari riyal", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "RON", "Romanian leu", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "RSD", "Serbian dinar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "RUB", "Russian ruble", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "RWF", "Rwandan franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SAR", "Saudi riyal", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SBD", "Solomon Islands dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SCR", "Seychellois rupee", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SDG", "Sudanese pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SEK", "Swedish krona", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SGD", "Singapore dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SHP", "Saint Helena pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SLL", "Sierra Leonean leone", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SOS", "Somali shilling", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SRD", "Surinamese dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "STD", "Sao Tomean dobra", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SVC", "Salvadoran colón", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SYP", "Syrian pound", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "SZL", "Swazi lilangeni", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "THB", "Thai baht", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "TJS", "Tajikistani somoni", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "TMT", "Turkmenistan manat", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "TND", "Tunisian dinar", 3));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "TOP", "Tongan paʻanga", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "TRY", "Turkish lira", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "TTD", "Trinidad and Tobago dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "TWD", "New Taiwan dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "TZS", "Tanzanian shilling", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "UAH", "Ukrainian hryvnia", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "UGX", "Ugandan shilling", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "USD", "United States dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "UYU", "Uruguayan peso", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "UZS", "Uzbekistani soʻm", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "VEF", "Venezuelan bolívar soberano", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "VND", "Vietnamese đồng", 1));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "VUV", "Vanuatu vatu", 0));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "WST", "Samoan tālā", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "XAF", "Central African CFA franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "XAG", "Silver ounce", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "XAU", "Gold ounce", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "XCD", "Eastern Caribbean dollar", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "XDR", "Special Drawing Rights", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "XOF", "West African CFA franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "XPF", "CFP franc", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "YER", "Yemeni rial", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ZAR", "South African rand", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ZMK", "Zambian kwacha", 2));
    _currenciesList.add(Currency(_rootCurrency, Decimal.parse("1.0"), "ZWL", "Zimbabwean dollar", 2));
  }

  void saveAllBaseCurrencies(){
    for(Currency currency in  _currenciesList){
      DatabaseHandler.instance.insertCurrency(currency);
    }
  }

  Future<String> getMainCurrencyPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_mainCurrencyPrefs);
  }

  Future<bool> setMainCurrencyPrefs(Currency currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_mainCurrencyPrefs, currency.tag);
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
      if(amountString.contains(",")){
        String full = amountString.split(",")[0];
        String parts = amountString.split(",")[1];
        amountString = "$full.$parts";
      }
      BigInt amount = BigInt.parse((Decimal.parse(amountString)*Decimal.parse(recentAccount.currency.getDivision().toString())).toString());
      if(amount<BigInt.from(0))throw Exception();
      Income newIncome = Income(_transactionsList.length, amount, recentAccount);
      _transactionsList.add(newIncome);
      DatabaseHandler.instance.insertTransaction(newIncome);
      return true;
    }
    on Exception {
      return false;
    }
  }

  //returns if execution went fine
  bool addExpense(String amountString){
    try{
      if(amountString.contains(",")){
        String full = amountString.split(",")[0];
        String parts = amountString.split(",")[1];
        amountString = "$full.$parts";
      }
      BigInt amount = BigInt.parse((Decimal.parse(amountString)*Decimal.parse(recentAccount.currency.getDivision().toString())).toString());
      if(amount<BigInt.from(0))throw Exception();
      Expense newExpense = Expense(_transactionsList.length, amount, recentAccount);
      _transactionsList.add(newExpense);
      DatabaseHandler.instance.insertTransaction(newExpense);
      return true;
    }
    on Exception {
      return false;
    }
  }

  //returns if execution went fine
  bool addSetting(String amountString){
    try{
      if(amountString.contains(",")){
        String full = amountString.split(",")[0];
        String parts = amountString.split(",")[1];
        amountString = "$full.$parts";
      }
      BigInt amount = BigInt.parse((Decimal.parse(amountString)*Decimal.parse(recentAccount.currency.getDivision().toString())).toString());
      Setting newSetting = Setting(_transactionsList.length, amount, recentAccount);
      _transactionsList.add(newSetting);
      DatabaseHandler.instance.insertTransaction(newSetting);
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
        if(currencyToLinkRatio.contains(",")){
          String full = currencyToLinkRatio.split(",")[0];
          String parts = currencyToLinkRatio.split(",")[1];
          currencyToLinkRatio = "$full.$parts";
        }
        Currency newCurency = Currency(
            currencyLink, Decimal.parse(currencyToLinkRatio), currencyTag,
            currencyName, BigInt.parse(currencyPointPosition).toInt());
        _currenciesList.add(newCurency);
        DatabaseHandler.instance.insertCurrency(newCurency);
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
    DatabaseHandler.instance.readAllCurrencies();
  }

  Future makeCurrencyRatesRequest() async{
    API currenciesAPI = new API("Currencies",_currenciesAPIKey);
    currenciesAPI.addAPIRequest(RatesRequest());
    await currenciesAPI.makeRequest("Rates");
  }
}