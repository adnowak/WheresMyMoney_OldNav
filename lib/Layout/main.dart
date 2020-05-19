import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';
import '../Models/Account.dart';
import 'AccountRelatedPages.dart';
import '../Models/Currency.dart';
import 'CurrencyRelatedPages.dart';
import '../Singleton/Global.dart';

BuildContext appContext;

void main() async{
  runApp(MyApp());
  await Global.instance.initiateGlobal();
  Navigator.pushReplacement(
      appContext,
      PageRouteBuilder(pageBuilder: (context, animation1, animation2) => HomePage()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Where`s My Money!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Where`s My Money!'),
      routes: <String, WidgetBuilder>{
        'accounts': (context)=>AccountsPage(),
        'currencies': (context)=>CurrenciesPage(),
        'settings': (context)=>SettingsPage(),
        'pickAccountCurrency': (context)=>PickAccountCurrencyPage(),
        'pickCurrencyLinkPage': (context)=>PickCurrencyLinkPage(),
        'account': (context)=>AccountPage(),
        'currency': (context)=>CurrencyPage(),
        'transaction': (context)=>TransactionPage(),
        'income': (context)=>IncomePage(),
        'editBalance': (context)=>EditBalancePage(),
        'expense': (context)=>ExpensePage(),
        'pickAccountType': (context)=>PickAccountTypePage(),
        'pickAccountName': (context)=>PickAccountNamePage(),
        'pickCurrencyName': (context)=>PickCurrencyNamePage(),
        'pickCurrencyTag': (context)=>PickCurrencyTagPage(),
        'pickCurrencyLinkRatio': (context)=>PickCurrencyLinkRatioPage(),
        'pickCurrencyPointPosition': (context)=>PickCurrencyPointPositionPage(),
      }
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class SettingsPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _listViewData = [
    "Light theme",
    "Dark theme",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(

        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 27,
                  child: ListView(
                    padding: EdgeInsets.all(10.0),
                    children: _listViewData
                        .map((data) => ListTile(
                      leading: Icon(Icons.invert_colors),
                      title: Text(data),
                      onTap: (){
                        Toast.show("This functionality isn`t yet available", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                        },
                    ))
                        .toList(),
                  ),
                ),
              ],
            )
        )
    );
  }
}

// ignore: must_be_immutable
class AccountsPage extends StatelessWidget {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Account> _listViewData = Global.instance.accountsList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 27,
              child: ListView(
                padding: EdgeInsets.all(10.0),
                children: _listViewData.map((account) => Slidable(
                  actionPane: SlidableStrechActionPane(),
                  actionExtentRatio: 0.25,
                  child: ListTile(
                    leading: account.getIcon(),
                    title: Text(account.getData()),
                    onTap: (){
                      Navigator.pushNamed(context, 'account');
                      Global.instance.recentAccount = account;
                    },
                  ),
                  actions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        if(Global.instance.deleteAccount(account)){
                          Toast.show("Deleted succesfully", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                          Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(pageBuilder: (context, animation1, animation2) => AccountsPage()));
                        }
                        else{
                          Toast.show("Can`t delete ${account.name}", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                        }
                      },
                    ),
                  ],
                )
                ).toList(),
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
                        'Add',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      color: Colors.blue,
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.blueAccent,
                      onPressed: (){Navigator.pushNamed(context, 'pickAccountType');},
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

class CurrenciesPage extends StatelessWidget {
  final List<Currency> _listViewData = Global.instance.currenciesList;
  @override
  Widget build(BuildContext context) {
    Global.instance.readAllFromDatabase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currencies'),
      ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 24,
                  child: ListView(
                    padding: EdgeInsets.all(10.0),
                    children: _listViewData
                        .map((currency) => Slidable(
                      actionPane: SlidableStrechActionPane(),
                      actionExtentRatio: 0.25,
                      child: ListTile(
                        leading: currency.tag == Global.instance.mainCurrency.tag ? IconButton(
                          icon: new Icon(Icons.favorite),
                          onPressed: () {
                            Global.instance.setMainCurrency(currency);
                            Toast.show("Main currency: ${Global.instance.mainCurrency.tag}", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                            Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(pageBuilder: (context, animation1, animation2) => CurrenciesPage()));
                          },
                        ) : IconButton(
                          icon: new Icon(Icons.favorite_border),
                          onPressed: () {
                            Global.instance.setMainCurrency(currency);
                            Toast.show("Main currency: ${Global.instance.mainCurrency.tag}", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                            Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(pageBuilder: (context, animation1, animation2) => CurrenciesPage()));
                          },
                        ) ,
                        title: Text(currency.tag),
                        onTap: (){
                          Navigator.pushNamed(context, 'currency');
                          Global.instance.recentCurrency = currency;
                        },
                      ),
                      actions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            if(Global.instance.deleteCurrency(currency)){
                              Toast.show("Deleted succesfully", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                              Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(pageBuilder: (context, animation1, animation2) => CurrenciesPage()));
                            }
                            else{
                              Toast.show("Can`t delete ${currency.name}", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                            }
                          },
                        ),
                      ],
                    ),
                  ).toList()),
                ),
                Expanded(
                    flex: 6,
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
                              'Update',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.black,
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.blueAccent,
                            onPressed: (){
                              Toast.show("Updating currencies", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                              Global.instance.makeCurrencyRatesRequest();
                            },
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
                              'Add',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.black,
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.blueAccent,
                            onPressed: (){Navigator.pushNamed(context, 'pickCurrencyLinkPage');},
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

class TransactionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${Global.instance.recentTransaction.toString()}"),
      ),
    );
  }
}

class IncomePage extends StatelessWidget {
  final myController = TextEditingController();
  final List<String> suggestionsList = ["9.99","19.99", "100.00", "1000.00", "2000.00", "5000.00"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New income"),
      ),
        body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Container(
              margin: EdgeInsets.all(30.0),
              child:TextField(
                controller: myController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'New income amount'
                ),
              ),
            )
        ),
        Expanded(
          flex: 22,
          child: ListView(
            padding: EdgeInsets.all(10.0),
            children: suggestionsList
                .map((suggestion) => ListTile(
              leading: Icon(Icons.add_circle),
              title: Text("$suggestion ${Global.instance.recentAccount.currency.tag}"),
              onTap: (){
                Global.instance.addIncome(suggestion);
                Toast.show("Income added", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                Navigator.of(context).pop();
              },
            ))
                .toList(),
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
                      if(Global.instance.addIncome("${myController.text}")) {
                        Toast.show("Income added", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                        Navigator.of(context).pop();
                      }
                      else{
                        Toast.show("Please enter a valid amount", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
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

class EditBalancePage extends StatelessWidget {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit balance"),
      ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    flex: 27,
                    child: Container(
                      margin: EdgeInsets.all(30.0),
                      child:TextField(
                        controller: myController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'New balance'
                        ),
                      ),
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
                              if(Global.instance.addSetting("${myController.text}")) {
                                Toast.show("Balance edited", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                Navigator.of(context).pop();
                              }
                              else{
                                Toast.show("Please enter a valid amount", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
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

class ExpensePage extends StatelessWidget {
  final myController = TextEditingController();
  final List<String> suggestionsList = ["1.99","2.99","4.99","9.99","19.99", "29.99", "49.99", "99.99", "199.99"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New expense"),
      ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    flex: 5,
                    child: Container(
                      margin: EdgeInsets.all(30.0),
                      child:TextField(
                        controller: myController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'New expense amount'
                        ),
                      ),
                    )
                ),
                Expanded(
                  flex: 22,
                  child: ListView(
                    padding: EdgeInsets.all(10.0),
                    children: suggestionsList
                        .map((suggestion) => ListTile(
                      leading: Icon(Icons.remove_circle),
                      title: Text("$suggestion ${Global.instance.recentAccount.currency.tag}"),
                      onTap: (){
                        Global.instance.addExpense(suggestion);
                        Toast.show("Expense added", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                        Navigator.of(context).pop();
                      },
                    ))
                        .toList(),
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
                              if(Global.instance.addExpense("${myController.text}")) {
                                Toast.show("Expense added", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                Navigator.of(context).pop();
                              }
                              else{
                                Toast.show("Please enter a valid amount", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
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

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    appContext = context;
    if(Global.instance.initiated){
      return Scaffold(
        appBar: AppBar(
          title: Text("Where`s My Money!"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Your balance:',
                      style: Theme.of(context).textTheme.display1,
                    ),
                    Text(
                      '${Global.instance.getBalanceToDisplay()}',
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ],
                ),
              ),
              Expanded(
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
                            'Accounts',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          color: Colors.blue,
                          textColor: Colors.white,
                          disabledColor: Colors.grey,
                          disabledTextColor: Colors.black,
                          padding: EdgeInsets.all(8.0),
                          splashColor: Colors.blueAccent,
                          onPressed: (){Navigator.pushNamed(context, 'accounts');},
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
                            'Currencies',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          color: Colors.blue,
                          textColor: Colors.white,
                          disabledColor: Colors.grey,
                          disabledTextColor: Colors.black,
                          padding: EdgeInsets.all(8.0),
                          splashColor: Colors.blueAccent,
                          onPressed: (){Navigator.pushNamed(context, 'currencies');},
                        ),
                      ),
                    ],
                  )
              )
            ],
          ),
        ),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(

        ),
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
              )
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Container(
                )
            ),
          ],
        )
      );
    }
  }
}