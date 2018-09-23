import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill/sql/bill.dart';
import 'package:flutter_bill/view/picture_selector.dart';
import 'package:path/path.dart';
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

  @override
  void initState() {
    super.initState();
    initDb();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title ?? widget.title),
      ),
      body: new ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                Text("票据标题"),
                Text(_bill.title ?? _bill.title)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                Text("备注"),
                Text(_bill.remark ?? _bill.remark)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                Text("联系人"),
                Text(_bill.contact ?? _bill.contact)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                Text("联系方式"),
                Text(_bill.phone ?? _bill.phone)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                Text("分类"),
                Text(_bill.categoryId ?? _bill.categoryId)
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.expand(height: 250.0),
            child: PictureSelector(
              preview: true,
              images: _bill.images.isEmpty
                  ? new List()
                  : _bill.images.split(",").map((String image) {
                      return new File(image);
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void initDb() async {
    Sqflite.setDebugModeOn(true);
    getDatabasesPath().then((dbPath) {
      return billProvider.open(join(dbPath, "db.db")).then((db) {
        return billProvider.getBill(widget.billId).then((Bill bill) {
          setState(() {
            _bill = bill;
          });
        });
      });
    });
  }
}
