import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bill/bill/add_bill.dart';
import 'package:flutter_bill/bill/detail_bill.dart';
import 'package:flutter_bill/sql/bill.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'dart:math';

Future<void> main() async {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: '票据管理'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Bill> mList = new List();
  var _billProvider = BillProvider();
  var path;

  void _incrementCounter() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddBillPage(
                  title: "添加票据",
                )));
    if (result ?? result) {
      getList();
    }
  }

  void initDb() async {
    Sqflite.setDebugModeOn(true);
    var dbPath = await getDatabasesPath();
    path = join(dbPath, "db.db");
    getList();
  }

  @override
  void initState() {
    super.initState();
    initDb();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new RefreshIndicator(
        onRefresh: () async {
          mList.clear();

          _billProvider.open(path).then((db) {
            _billProvider.getBills().then((List<Bill> data) {
              setState(() {
                mList = data;
              });
              return data;
            });
          });
        },
        child: new ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: max(1, mList.length),
            itemBuilder: (BuildContext context, int index) {
              if (mList.isNotEmpty) {
                return generateItem(index);
              } else {
                return emptyView();
              }
            }),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget generateItem(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, //点击事件透传
      onTap: () async {
        var result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailBillPage(
                    title: "票据详情", billId: mList[index].billId)));
        if (result ?? result) {
          getList();
        }
      },
      child: Container(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(mList[index].title),
                          padding: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Text(mList[index].categoryId)
                      ],
                    ),
                  ),
                  Image.file(
                    File(mList[index]
                        .images
                        .substring(0, mList[index].images.indexOf(","))),
                    width: 40.0,
                    fit: BoxFit.cover,
                    height: 40.0,
                  )
                ],
              ),
              new Divider(),
            ],
          )),
    );
  }

  void getList() async {
    _billProvider.open(path).then((db) {
      _billProvider.getBills().then((List<Bill> data) {
        setState(() {
          mList = data;
        });
      });
    });
  }
}

Widget emptyView() {
  return new Container(
    padding: const EdgeInsets.all(8.0),
    child: Text("暂无数据"),
  );
}
