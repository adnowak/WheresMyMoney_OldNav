import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wheresmymoney_old_nav/Currency.dart';
import 'package:wheresmymoney_old_nav/Global.dart';

import 'API.dart';

abstract class APIRequest{
  String _name;

  String get name => _name;

  void makeRequest(API requestingAPI);
}

class RatesRequest extends APIRequest {
  int _ID;
  String _name;
  String _requestURL;

  static String requestTag;

  RatesRequest() {
    _name = "Rates";
    _requestURL = "http://data.fixer.io/api/latest?access_key=";
  }

  void makeRequest(API requestAPI) async{
    http.Response response = await fetchPost(requestAPI);
    String currenciesData = response.body.split("{")[2].split("}")[0];

    List<String> currenciesDataList = currenciesData.split(",");
    for(String currencyData in currenciesDataList){
      for(Currency currency in Global.instance.currenciesList){
        if(currencyData.split(":")[0] == '"${currency.tag}"'){
          Global.instance.editCurrency(currency, currency.name, currency.tag, currencyData.split(":")[1], currency.pointPosition.toString(), Global.instance.rootCurrency);
        }
      }
    }
  }

  Future<http.Response> fetchPost(API requestAPI) {
    return http.get("$_requestURL${requestAPI.apiKey}");
  }
}
