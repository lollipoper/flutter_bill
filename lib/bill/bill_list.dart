import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill/bill/detail_bill.dart';
import 'package:flutter_bill/bill/update_bill.dart';
import 'package:flutter_bill/sql/bill.dart';
import 'package:flutter_bill/sql/category.dart';
import 'package:sqflite/sqflite.dart';

class BillListPage extends StatefulWidget {
  BillListPage({Key key, this.title}) : super(key: key);

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

class _MyHomePageState extends State<BillListPage> {
  List<Bill> mList = new List();
  var _billProvider = BillProvider();
  var _categoryProvider = CategoryProvider();
  var path;

  void _addBill() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditBillPage(
                  title: "添加票据",
                )));
    if (result != null) {
      getList();
    }
  }

  void initDb() async {
    Sqflite.setDebugModeOn(true);
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
          return getList();
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
        onPressed: _addBill,
        tooltip: 'add bill',
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
        if (result ?? false) {
          getList();
        }
      },
      child: Column(
        children: <Widget>[
          Container(
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
                            Text(mList[index].categoryName)
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
                ],
              )),
          Divider()
        ],
      ),
    );
  }

  void getList() async {
    mList.clear();
    _categoryProvider.open().then((db) {
      _categoryProvider.getCategories().then((List<Category> categories) {
        categories.map((Category category) {
          _billProvider.open().then((db) {
            _billProvider
                .getBillsWithLabel(category.categoryId)
                .then((List<Bill> data) {
              setState(() {
                mList.addAll(data.map((Bill bill) {
                  return bill..categoryName = category.title;
                }).toList());
              });
            });
          });
        }).toList();
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
