import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';
import '../Models/Account.dart';
import '../Models/Currency.dart';
import '../Singleton/Global.dart';
import '../Models/Transaction.dart';

class AccountPage extends StatelessWidget {
  final List<Transaction> _listViewData = Global.instance.recentAccount.transactionsList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${Global.instance.recentAccount.name}"),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Balance:',
                  style: TextStyle(fontSize: 20.0),),
                Text('${Global.instance.recentAccount.currency.toNaturalLanguage(Global.instance.recentAccount.balance)}',
                  style: TextStyle(fontSize: 20.0),),
                Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.all(3.0),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)))
                        ,
                        child: Text(
                          'Income',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                        disabledColor: Colors.grey,
                        disabledTextColor: Colors.black,
                        padding: EdgeInsets.all(8.0),
                        splashColor: Colors.blueAccent,
                        onPressed: (){Navigator.pushNamed(context, 'income');},
                      ),
                    ),
                    Expanded(
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
                        onPressed: (){Navigator.pushNamed(context, 'editBalance');},
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)))
                        ,
                        child: Text(
                          'Expense',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                        disabledColor: Colors.grey,
                        disabledTextColor: Colors.black,
                        padding: EdgeInsets.all(8.0),
                        splashColor: Colors.blueAccent,
                        onPressed: (){Navigator.pushNamed(context, 'expense');},
                      ),
                    ),
                  ],
                  ),
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
                      'Update account',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(8.0),
                    splashColor: Colors.blueAccent,
                    onPressed: (){
                      Toast.show("This functionality isn`t yet available", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(10.0),
                    children: _listViewData.map((transaction) => Slidable(
                      actionPane: SlidableStrechActionPane(),
                      actionExtentRatio: 0.25,
                      child: ListTile(
                        leading: transaction.getType() == 0 ? Icon(Icons.access_time) : transaction.getType() == 1 ? Icon(Icons.add_circle) : Icon(Icons.remove_circle),
                        title: Text(transaction.toString()),
                        onTap: (){
                          Navigator.pushNamed(context, 'transaction');
                          Global.instance.recentTransaction = transaction;
                        },
                      ),
                      actions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            try{
                              Global.instance.deleteTransaction(transaction);
                              Toast.show("Deleted succesfully", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                              Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(pageBuilder: (context, animation1, animation2) => AccountPage()));
                            }
                            on Exception{
                              Toast.show("Can`t delete this transaction", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                            }
                          },
                        ),
                      ],
                    )
                    ).toList(),
                  ),
                ),
              ],
            )
        )
    );
  }
}

class PickAccountTypePage extends StatelessWidget {
  final List<String> _listViewData = [];
  static String chosenType = Account.accountTypes[0];
  @override
  Widget build(BuildContext context) {
    _listViewData.addAll(Account.accountTypes);
    _listViewData.remove(chosenType);
    _listViewData.insert(0, chosenType);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Add account",
            textAlign: TextAlign.justify,
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(30.0),
              height: 30,
              child: Text("Pick your account`s type", style: TextStyle(fontSize: 20.0),),
            ),
            Expanded(
              flex: 20,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                children: _listViewData
                    .map((type) => ListTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Container(

                          )
                      ),
                      Text(type),
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
                  chosenType = Account.accountTypes[index];
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
                        onPressed: (){Navigator.pushNamed(context, 'pickAccountCurrency');},
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

class PickAccountCurrencyPage extends StatelessWidget {
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
            "Add account",
            textAlign: TextAlign.justify,
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(30.0),
              height: 30,
              child: Text("Pick a currency for your account", style: TextStyle(fontSize: 20.0),),
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
                        onPressed: (){Navigator.pushNamed(context, 'pickAccountName');},
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

class PickAccountNamePage extends StatelessWidget{
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("New account"),
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
                                    hintText: 'Enter account`s name'
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
                              'Submit',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.black,
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.blueAccent,
                            onPressed: (){
                              try{
                                Global.instance.addAccount(myController.text, PickAccountCurrencyPage.chosenCurrency, PickAccountTypePage.chosenType);
                                Toast.show("${myController.text}, ${Global.instance.recentCurrency.tag}", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
                              on Exception{
                                Toast.show("Please enter a valid name", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                              }
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