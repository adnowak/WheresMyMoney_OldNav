import 'package:decimal/decimal.dart';
import 'package:wheresmymoney_old_nav/Singleton/Global.dart';

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



  set name(String value) {
    _name = value;
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
    return BigInt.parse((
            Decimal.parse(amount.toString())/toMainRatio())
        .floor().toString())
        *Global.instance.mainCurrency.getDivision()
        ~/getDivision();
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
    if(amount<BigInt.from(0))
      return "-${toNaturalLanguage(amount*BigInt.from(-1))}";

    String result = "";
    String recentDigit = "";

    for(int recentPos = 1; recentPos<amount.toString().length; recentPos++) {
      result = concatCommaIfNeeded(recentDigit, amount, recentPos, result);
      amount = amount~/BigInt.from(10);
    }

    result = "$amount$result";
    result = concatZeros(result);
    result = "$result $tag";
    return result;
  }

  String concatCommaIfNeeded(String recentDigit, BigInt amount, int recentPos, String result) {
    recentDigit = (amount%BigInt.from(10)).toString();
    if(recentPos == pointPosition) {
      result = ",$recentDigit$result";
    }
    else {
      result = "$recentDigit$result";
    }
    return result;
  }

  String concatZeros(String result) {
    if(result.length<pointPosition+2) {
      for(int i = result.length; i<pointPosition; i++) {
        result = "0$result";
      }

      if(pointPosition!=0) {
        result = "0,$result";
      }
    }
    return result;
  }

  BigInt getDivision() {
    BigInt div = BigInt.from(1);
    for(int i=0; i<pointPosition; i++)
    {
      div = div*BigInt.from(10);
    }
    return div;
  }

  set tag(String value) {
    _tag = value;
  }

  set linkRatio(Decimal value) {
    _linkRatio = value;
  }

  set pointPosition(int value) {
    _pointPosition = value;
  }
}