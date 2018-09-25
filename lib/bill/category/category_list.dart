import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill/sql/category.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class CategoryListPage extends StatefulWidget {
  CategoryListPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _CategoryListPageState createState() => new _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<Category> mList = new List();
  var _billProvider = CategoryProvider();
  var textEditingController = TextEditingController();
  var path;

  void _addCategory() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("新增分类"),
            content: TextField(
              controller: textEditingController,
              decoration: InputDecoration(hintText: "请输入分类名"),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _billProvider.insert(
                        new Category(title: textEditingController.text));
                    getList();
                  },
                  child: Text("确定"))
            ],
          ).build(context);
        });
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

          _billProvider.open().then((db) {
            _billProvider.getCategories().then((List<Category> data) {
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
        onPressed: _addCategory,
        tooltip: 'add category',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget generateItem(int index) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent, //点击事件透传
        onTap: () async {
          Navigator.pop(context, mList[index]);
        },
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              Text(mList[index].title),
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    await _showEditCategoryDialog(index);
                  })
            ],
          ),
        ));
  }

  Future _showEditCategoryDialog(int index) async {
    textEditingController.text = mList[index].title;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("修改分类"),
            content: TextField(
              controller: textEditingController,
              decoration: InputDecoration(hintText: "请输入分类名"),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              FlatButton(
                  onPressed: () async {
                    await _editCategory(context, index);
                  },
                  child: Text("修改"))
            ],
          ).build(context);
        });
  }

  Future _editCategory(BuildContext context, int index) async {
    Navigator.pop(context);
    await _billProvider
        .update(mList[index]..title = textEditingController.text);
    getList();
  }

  void getList() async {
    _billProvider.open().then((db) {
      _billProvider.getCategories().then((List<Category> data) {
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
