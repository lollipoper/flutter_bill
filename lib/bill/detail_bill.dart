import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill/bill/update_bill.dart';
import 'package:flutter_bill/sql/bill.dart';
import 'package:flutter_bill/sql/category.dart';
import 'package:flutter_bill/view/picture_selector.dart';
import 'package:sqflite/sqflite.dart';

class DetailBillPage extends StatefulWidget {
  final String title;
  final String billId;

  DetailBillPage({Key key, this.title, this.billId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _DetailBillPageState();
  }
}

class _DetailBillPageState extends State<DetailBillPage> {
  Bill _bill = new Bill();
  var billProvider = BillProvider();
  BuildContext context;

  @override
  void initState() {
    super.initState();
    getBillDetail();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title ?? widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.mode_edit),
            tooltip: "edit bill",
            onPressed: _modifyBill,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: "delete bill",
            onPressed: _deleteBill,
          )
        ],
      ),
      body: new ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: new Row(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Text(_bill.title ?? "暂无")),
                Container(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.0, color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text(
                    _bill.categoryName ?? "其它",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.event_note,
                      color: Theme.of(context).primaryColor),
                  padding: const EdgeInsets.only(right: 15.0),
                ),
                Text(_bill.remark ?? "暂无")
              ],
            ),
          ),
          Divider(
            height: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.perm_contact_calendar,
                    color: Theme.of(context).primaryColor,
                  ),
                  padding: const EdgeInsets.only(right: 15.0),
                ),
                Text(_bill.contact ?? "暂无")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                Container(
                  child:
                      Icon(Icons.phone, color: Theme.of(context).primaryColor),
                  padding: const EdgeInsets.only(right: 15.0),
                ),
                Text(_bill.phone ?? "暂无")
              ],
            ),
          ),
          Divider(
            height: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("票据文件"),
          ),
          PictureSelector(
            preview: true,
            images: _bill.images.isEmpty
                ? new List()
                : _bill.images.split(",").map((String image) {
                    return new File(image);
                  }).toList(),
          ),
        ],
      ),
    );
  }

  // ignore: missing_return
  void _deleteBill() {
    print("delete bill");
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text("删除票据"),
            content: Text("确定删除票据，删除后数据将丢失！"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              FlatButton(
                  onPressed: () =>
                      billProvider.delete(widget.billId).then((int) {
                        if (int > 0) Navigator.pop(context, true);
                      }).whenComplete(() {
                        Navigator.pop(context);
                      }),
                  child: Text("确定")),
            ],
          );
        });
  }

  void getBillDetail() async {
    Sqflite.setDebugModeOn(true);
    billProvider.open().then((db) {
      return billProvider.getBill(widget.billId).then((Bill bill) {
        var category = CategoryProvider();
        category.open().then((db) {
          return category
              .getCategory(bill.categoryId)
              .then((Category category) {
            bill.categoryName = category.title;
            setState(() {
              setState(() {
                _bill = bill;
              });
            });
          });
        });
        setState(() {
          _bill = bill;
        });
      });
    });
  }

  void _modifyBill() async {
    print("edit bill");
    Bill result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EditBillPage(
                  title: "编辑票据",
                  bill: _bill,
                )));
    if (result != null) {
      setState(() {
        _bill = result;
      });
    }
  }
}
