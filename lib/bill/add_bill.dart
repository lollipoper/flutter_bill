import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill/sql/bill.dart';
import 'package:flutter_bill/view/picture_selector.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AddBillPage extends StatefulWidget {
  final String title;

  AddBillPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _AddBillPageState();
  }
}

class _AddBillPageState extends State<AddBillPage> {
  var _path;
  var titleEditController = TextEditingController();
  var remarkController = TextEditingController();
  var contactController = TextEditingController();
  var phoneController = TextEditingController();
  var pictureSelector = PictureSelector();

  @override
  void initState() {
    super.initState();
    initDb();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: TextField(
              maxLengthEnforced: false,
              maxLength: 50,
              controller: titleEditController,
              decoration: new InputDecoration(
                labelText: "标题",
                hintText: "输入标题",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: TextField(
              maxLengthEnforced: true,
              maxLength: 500,
              controller: remarkController,
              decoration: new InputDecoration(
                labelText: "备注",
                hintText: "输入备注",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: TextField(
              maxLength: 15,
              maxLengthEnforced: false, //是否显示错误信息
              controller: contactController,
              decoration:
                  new InputDecoration(labelText: "联系人", hintText: "输入联系人"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: TextField(
              maxLength: 12,
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: new InputDecoration(
                labelText: "联系方式",
                hintText: "输入联系方式",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, left: 15.0, right: 15.0, bottom: 10.0),
            child: Text("票据文件夹"),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.expand(height: 300.0),
            child: pictureSelector,
          ),
          Container(
            margin: EdgeInsets.all(15.0),
            child:
                RaisedButton(onPressed: _uploadBill, child: new Text("上传票据")),
          ),
        ],
      ),
    );
  }

  void initDb() async {
    Sqflite.setDebugModeOn(true);
    var dbPath = await getDatabasesPath();
    _path = join(dbPath, "db.db");
  }

  void _uploadBill() async {
    var billProvider = BillProvider();
    await billProvider.open(_path);
    var bill = new Bill();
    bill.title = titleEditController.text;
    bill.remark = remarkController.text;
    bill.contact = contactController.text;
    bill.phone = phoneController.text;
    bill.images = pictureSelector.getSelectedImages();
    var insert = await billProvider.insert(bill);
    if (insert != null) {
      print("上传票据成功~");
    }
  }
}
