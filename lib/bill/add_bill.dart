import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill/view/picture_selector.dart';

class AddBillPage extends StatefulWidget {
  final String title;

  AddBillPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _AddBillPageState();
  }
}

class _AddBillPageState extends State<AddBillPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("添加票据"),
      ),
      body: new ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: TextField(
              maxLengthEnforced: false,
              maxLength: 50,
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
              decoration: new InputDecoration(
                labelText: "备注",
                hintText: "输入备注",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: buildContactTextField(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: TextField(
              maxLength: 12,
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
            child: PictureSelector(),
          ),
          Container(
            margin: EdgeInsets.all(15.0),
            child: RaisedButton(onPressed: () {}, child: new Text("上传票据")),
          ),
        ],
      ),
    );
  }

  TextField buildContactTextField() {
    return TextField(
      maxLength: 15,
      maxLengthEnforced: false, //是否显示错误信息
      decoration: new InputDecoration(labelText: "联系人", hintText: "输入联系人"),
    );
  }
}
