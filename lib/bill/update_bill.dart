import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill/bill/category/category_list.dart';
import 'package:flutter_bill/sql/bill.dart';
import 'package:flutter_bill/sql/category.dart';
import 'package:flutter_bill/view/picture_selector.dart';
import 'package:sqflite/sqflite.dart';

class EditBillPage extends StatefulWidget {
  final String title;
  final Bill bill;

  EditBillPage({Key key, this.title, this.bill}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _EditBillPageState();
  }
}

class _EditBillPageState extends State<EditBillPage> {
  Category _selectedCategory;
  CategoryProvider provider;
  var titleEditController = TextEditingController();
  var remarkController = TextEditingController();
  var contactController = TextEditingController();
  var phoneController = TextEditingController();
  var pictureSelector = PictureSelector(
    images: new List(),
  );
  var context;
  var billProvider = BillProvider();

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      titleEditController = TextEditingController(text: widget.bill.title);
      remarkController = TextEditingController(text: widget.bill.remark);
      contactController = TextEditingController(text: widget.bill.contact);
      phoneController = TextEditingController(text: widget.bill.phone);
      pictureSelector = PictureSelector(
        images: widget.bill.images.split(",").map((String image) {
          return new File(image);
        }).toList(),
        preview: false,
      );
      provider = CategoryProvider();
      provider.open().then((db) {
        provider.getCategory(widget.bill.categoryId).then((Category category) {
          setState(() {
            _selectedCategory = category;
          });
        });
      });
    }
    _selectedCategory = Category();
    initDb();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: _selectCategory,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: Text("选择分类")),
                  Text(_selectedCategory.title ?? "请选择"),
                  Icon(Icons.keyboard_arrow_right)
                ],
              ),
            ),
          ),
          Divider(),
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
          Divider(),
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
          Divider(),
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
          Divider(),
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
          Divider(),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, left: 15.0, right: 15.0, bottom: 10.0),
            child: Text("票据文件"),
          ),
          pictureSelector,
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
    await billProvider.open();
  }

  void _uploadBill() async {
    if (widget.bill != null) {
      widget.bill.title = titleEditController.text;
      widget.bill.remark = remarkController.text;
      widget.bill.contact = contactController.text;
      widget.bill.phone = phoneController.text;
      widget.bill.images = pictureSelector.getSelectedImages();
      widget.bill.categoryId = _selectedCategory.categoryId;
      widget.bill.categoryName = _selectedCategory.title;
      var update = await billProvider.update(widget.bill);
      if (update != null) {
        print("修改票据成功~");
        Navigator.pop(context, widget.bill);
      }
    } else {
      var bill = new Bill();
      bill.title = titleEditController.text;
      bill.remark = remarkController.text;
      bill.contact = contactController.text;
      bill.phone = phoneController.text;
      bill.images = pictureSelector.getSelectedImages();
      bill.categoryId = _selectedCategory.categoryId;
      var insert = await billProvider.insert(bill);
      if (insert != null) {
        print("上传票据成功~");
        Navigator.pop(context, true);
      }
    }
  }

  void _selectCategory() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => CategoryListPage(
                  title: "选择分类",
                )));
    setState(() {
      _selectedCategory = result ?? Category();
    });
  }
}
