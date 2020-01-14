import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'Currency.dart';
import 'Global.dart';

class CurrencyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Global.instance.recentCurrency.name),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    flex: 27,
                    child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text("Tag: ${Global.instance.recentCurrency.tag}",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text("Link tag: ${Global.instance.recentCurrency.link.tag}",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text("${Global.instance.recentCurrency.link.name} ratio: ${Global.instance.recentCurrency.linkRatio}",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text("Division: ${Global.instance.recentCurrency.getDivision()}",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ]
                    )
                ),
                Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.all(3.0),
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)))
                            ,
                            child: Text(
                              'Edit',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.black,
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.blueAccent,
                            onPressed: (){
                              Global.instance.editing = true;
                              Navigator.pushNamed(context, 'pickCurrencyLinkPage');
                              },
                          ),
                        ),
                      ],
                    )
                )
              ],
            )
        )
    );
  }
}

class PickCurrencyLinkPage extends StatelessWidget{
  final List<Currency> _listViewData = [];
  static Currency chosenCurrency = Global.instance.rootCurrency;

  @override
  Widget build(BuildContext context) {
    _listViewData.addAll(Global.instance.currenciesList);
    _listViewData.remove(chosenCurrency);
    _listViewData.insert(0, chosenCurrency);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Add currency",
            textAlign: TextAlign.justify,
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(30.0),
              height: 30,
              child: Text("Pick a link for your currency", style: TextStyle(fontSize: 20.0),),
            ),
            Expanded(
              flex: 20,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                children: _listViewData
                    .map((currency) => ListTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Container(

                          )
                      ),
                      Text(currency.name),
                      Expanded(
                        flex: 1,
                        child: Container(

                        ),
                      )
                    ],
                  ),
                )).toList(),
                itemExtent: 50, //height of each item
                looping: true,
                onSelectedItemChanged: (int index) {
                  chosenCurrency = Global.instance.currenciesList[index];
                },
              ),
            ),
            Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      margin: EdgeInsets.all(3.0),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)))
                        ,
                        child: Text(
                          'Next',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                        disabledColor: Colors.grey,
                        disabledTextColor: Colors.black,
                        padding: EdgeInsets.all(8.0),
                        splashColor: Colors.blueAccent,
                        onPressed: (){
                          Navigator.pushNamed(context, 'pickCurrencyName');
                          },
                      ),
                    ),
                  ],
                )
            )
          ],
        )
    );
  }
}

class PickCurrencyNamePage extends StatelessWidget{
  static String name;
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Currency"),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                            child: Container(
                              margin: EdgeInsets.all(30.0),
                              child:TextField(
                                controller: myController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter currency`s name'
                                ),
                              ),
                            )
                        ),
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.all(3.0),
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)))
                            ,
                            child: Text(
                              'Next',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.black,
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.blueAccent,
                            onPressed: (){
                              PickCurrencyNamePage.name = myController.text;
                              Navigator.pushNamed(context, 'pickCurrencyTag');
                            },
                          ),
                        ),
                      ],
                    )
                )
              ],
            )
        )
    );
  }
}

class PickCurrencyTagPage extends StatelessWidget{
  static List<String> listViewData = List<String>.from(Global.instance.currenciesTagSuggestions);
  static String tag;
  final myController = TextEditingController();
  final tagPicker = MyCupertinoPicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Currency"),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.all(30.0),
                              child:TextField(
                                controller: myController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter currency`s tag'
                                ),
                                onChanged: (String value) async {
                                  tag = value;
                                  listViewData = List<String>.from(Global.instance.currenciesTagSuggestions);
                                  for(int i=0; i<listViewData.length; i++) {
                                    String recentTag = listViewData[i];
                                    if(recentTag.substring(
                                        0, tag.length) != tag.toUpperCase()) {
                                      listViewData.remove(recentTag);
                                      print(listViewData.length);
                                      i--;
                                    }
                                  }
                                  print(listViewData.length);
                                  tagPicker.refresh();
                                },
                              ),
                            )
                        ),
                        Expanded(
                            flex: 18,
                            child: tagPicker,
                        ),
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.all(3.0),
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)))
                            ,
                            child: Text(
                              'Next',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.black,
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.blueAccent,
                            onPressed: (){
                              Navigator.pushNamed(context, 'pickCurrencyLinkRatio');
                            },
                          ),
                        ),
                      ],
                    )
                )
              ],
            )
        )
    );
  }
}

class MyCupertinoPicker extends StatefulWidget {
  MyCupertinoPickerState state;

  void refresh(){
    state.refresh();
  }

  @override
  State<StatefulWidget> createState() {
    state = MyCupertinoPickerState();
    return state;
  }

}

class MyCupertinoPickerState extends State<MyCupertinoPicker>{
  List<String> _listViewData = PickCurrencyTagPage.listViewData;

  void refresh(){
    setState(() {
      _listViewData = PickCurrencyTagPage.listViewData;
      print("here: ${_listViewData.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      backgroundColor: Colors.white,
      children: _listViewData
          .map((suggestion) => ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Container(

                )
            ),
            Text(suggestion),
            Expanded(
              flex: 1,
              child: Container(

              ),
            )
          ],
        ),
      )).toList(),
      itemExtent: 50, //height of each item
      looping: true,
      onSelectedItemChanged: (int index) {
        PickCurrencyTagPage.tag = Global.instance.currenciesTagSuggestions[index];
      },
    )
    ;
  }

}

class PickCurrencyLinkRatioPage extends StatelessWidget{
  static String linkRatio;
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Currency"),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                            child: Container(
                              margin: EdgeInsets.all(30.0),
                              child:TextField(
                                controller: myController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter currency`s link ratio'
                                ),
                              ),
                            )
                        ),
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.all(3.0),
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)))
                            ,
                            child: Text(
                              'Next',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.black,
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.blueAccent,
                            onPressed: (){
                              PickCurrencyLinkRatioPage.linkRatio = myController.text;
                              Navigator.pushNamed(context, 'pickCurrencyPointPosition');
                            },
                          ),
                        ),
                      ],
                    )
                )
              ],
            )
        )
    );
  }
}

class PickCurrencyPointPositionPage extends StatelessWidget{
  final List<String> _pointPositions = ["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18"];
  final List<String> _listViewData = ["1","10","100","1000","10000","100000",
    "1000000","10000000","100000000","1000000000","10000000000","100000000000","1000000000000","10000000000000",
    "100000000000000","1000000000000000","10000000000000000","100000000000000000","1000000000000000000"];
  static String chosenOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Currency",
            textAlign: TextAlign.justify,
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(30.0),
              height: 30,
              child: Text("Pick currency`s division", style: TextStyle(fontSize: 20.0),),
            ),
            Expanded(
              flex: 20,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                children: _listViewData
                    .map((option) => ListTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Container(

                          )
                      ),
                      Text(option),
                      Expanded(
                        flex: 1,
                        child: Container(

                        ),
                      )
                    ],
                  ),
                )).toList(),
                itemExtent: 50, //height of each item
                looping: true,
                onSelectedItemChanged: (int index) {
                  chosenOption = _pointPositions[index];
                },
              ),
            ),
            Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      margin: EdgeInsets.all(3.0),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)))
                        ,
                        child: Text(
                          'Next',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                        disabledColor: Colors.grey,
                        disabledTextColor: Colors.black,
                        padding: EdgeInsets.all(8.0),
                        splashColor: Colors.blueAccent,
                        onPressed: (){
                          if(Global.instance.editing){
                            if(Global.instance.editCurrency(Global.instance.recentCurrency, PickCurrencyNamePage.name, PickCurrencyTagPage.tag, PickCurrencyLinkRatioPage.linkRatio, chosenOption, PickCurrencyLinkPage.chosenCurrency)) {
                              Toast.show("Currency edited", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                            }
                            else{
                              Toast.show("Please enter valid data", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                            }
                          }
                          else{
                            if(Global.instance.addCurrency(PickCurrencyNamePage.name, PickCurrencyTagPage.tag, PickCurrencyLinkRatioPage.linkRatio, chosenOption, PickCurrencyLinkPage.chosenCurrency)) {
                              Toast.show("Currency added", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                            }
                            else{
                              Toast.show("Please enter valid data", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                            }
                          }
                          Global.instance.editing = false;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )
            )
          ],
        )
    );
  }
}