import 'package:decimal/decimal.dart';
import 'package:wheresmymoney_old_nav/Global.dart';
import 'package:wheresmymoney_old_nav/Transaction.dart';

import 'DatabaseHandler.dart';
class Currency
{
  String _name;
  String _tag;
  Decimal _linkRatio;
  int _pointPosition;
  Currency _link;

  Currency(this._link, this._linkRatio, this._tag, this._name, this._pointPosition);

  int get pointPosition => _pointPosition;

  Currency get link => _link;

  String get name => _name;

  String get tag => _tag;

  Decimal get linkRatio => _linkRatio;

  set link(Currency value) {
    _link = value;
  }

  bool equals(Currency other){
    return tag == other.tag;
  }

  Decimal toRootRatio()
  {
    Currency recentMedium = this;
    Decimal result = Decimal.parse("1");
    while(recentMedium.tag != Global.instance.rootCurrency.tag) {
      result = result*recentMedium._linkRatio;
      recentMedium = recentMedium.link;
    }
    result = result*recentMedium._linkRatio;
    return result;
  }

  Decimal toMainRatio(){
    if(equals(Global.instance.mainCurrency)) {
      return Decimal.parse("1.0");
    }
    else if(Global.instance.mainCurrency.isLinkedTo(this)) {
      Currency recentMedium = Global.instance.mainCurrency;
      Decimal result = Decimal.parse("1.0");
      while(!recentMedium.equals(this)) {
        result = result*recentMedium._linkRatio;
        recentMedium = recentMedium.link;
      }
      return (Decimal.parse("1.0")/result);
    }
    else if(isLinkedTo(Global.instance.mainCurrency)) {
      Currency recentMedium = this;
      Decimal result = Decimal.parse("1.0");
      while(!recentMedium.equals(Global.instance.mainCurrency)) {
        result = result*recentMedium._linkRatio;
        recentMedium = recentMedium.link;
      }
      return result;
    }
    else {
      return toRootRatio()/Global.instance.mainCurrency.toRootRatio();
    }
  }

  BigInt toMainCurrency(BigInt amount){
    return BigInt.parse((Decimal.parse(amount.toString())/toMainRatio()).floor().toString())*Global.instance.mainCurrency.getDivision()~/getDivision();
  }

  bool isLinkedTo(Currency otherCurrency) {
    if(equals(otherCurrency)) {
      return true;
    }
    else if(_tag == Global.instance.rootCurrency.tag) {
      return false;
    }
    else {
      if(_link == null){
        return false;
      }
      return _link.isLinkedTo(otherCurrency);
    }
  }

  String toNaturalLanguage(BigInt amount){
    if(amount<BigInt.from(0)){
      return "-${toNaturalLanguage(amount*BigInt.from(-1))}";
    }

    String result = "";
    String amountString  = amount.toString();
    String recentDigit = "";

    for(int recentPos = 1; recentPos<amountString.length; recentPos++) {
      recentDigit = (amount%BigInt.from(10)).toString();
      amount = amount~/BigInt.from(10);
      if(recentPos == pointPosition) {
        result = ",$recentDigit$result";
      }
      else {
        result = "$recentDigit$result";
      }
    }

    result = "$amount$result";

    if(result.length<pointPosition+2) {
      for(int i = result.length; i<pointPosition; i++) {
        result = "0$result";
      }

      if(pointPosition!=0) {
        result = "0,$result";
      }
    }
    return "$result $tag";
  }

  BigInt getDivision() {
    BigInt div = BigInt.from(1);
    for(int i=0; i<pointPosition; i++)
    {
      div = div*BigInt.from(10);
    }
    return div;
  }

  bool deleteCurrency(){
    for(int i =0; i<Global.instance.accountsList.length; i++){
      if(Global.instance.accountsList[i].currency==this){
        return false;
      }
    }
    for(int i =0; i<Global.instance.baseCurrenciesTags.length; i++){
      if(Global.instance.baseCurrenciesTags[i] == this.tag){
        return false;
      }
    }
    for(int i=0; i<Global.instance.currenciesList.length; i++){
      if(Global.instance.currenciesList[i]!=this&&Global.instance.currenciesList[i].isLinkedTo(this)){
        return false;
      }
    }
    if(this==Global.instance.rootCurrency || this==Global.instance.mainCurrency){
      return false;
    }
    if(this==Global.instance.recentCurrency){
      Global.instance.recentCurrency = Global.instance.mainCurrency;
    }
    Global.instance.currenciesList.remove(this);
    DatabaseHandler.instance.deleteCurrency(this.tag);
    return true;
  }

  bool editCurrency(String newName, String newTag, String newLinkRatio, String newPointPosition, Currency newLink){
    if(newLink==this){
      return false;
    }

    if(this==Global.instance.rootCurrency){
      if(newName!=_name||newTag!=_tag||Decimal.parse(newLinkRatio)!=Decimal.parse("1")||newLink!=this){
        return false;
      }
    }

    if(newName!=null&&newName!=""){
      _name = newName;
    }
    if(newTag!=null&&newTag!=""){
      _tag = newTag;
    }
    if(newPointPosition!=null&&newPointPosition!=""){
      for(int i=0; i<Global.instance.accountsList.length; i++){
        if(Global.instance.accountsList[i].currency==this){
          for(int j=0; j<Global.instance.accountsList[i].transactionsList.length; j++){
            Transaction recentTransactionToEdit = Global.instance.accountsList[i].transactionsList[j];
            recentTransactionToEdit.amount =(recentTransactionToEdit.amount*BigInt.from(10).pow(BigInt.parse(newPointPosition).toInt()))~/BigInt.from(10).pow(BigInt.from(_pointPosition).toInt());
          }
          Global.instance.accountsList[i].countBalance();
        }
      }
      _pointPosition = BigInt.parse(newPointPosition).toInt();
    }

    if(newLinkRatio!=null&&newLinkRatio!=""){
      _linkRatio = Decimal.parse(newLinkRatio);
    }

    if(newLink!=null){
      _link = newLink;
    }
    else{
      _link = Global.instance.rootCurrency;
    }

    DatabaseHandler.instance.updateCurrency(this);
    return true;
  }
}