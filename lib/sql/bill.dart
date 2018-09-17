import 'dart:async';

import 'package:sqflite/sqflite.dart';

final String tableBill = "Bill";
final String columnId = "id";
final String columnTitle = "title";
final String columnRemark = "remark";
final String columnCategory = "category";
final String columnContact = "contact";
final String columnPhone = "phone";
final String columnImages = "images";

class Bill {
  String billId;
  String title;
  String remark;
  String categoryId;
  String contact;
  String phone;
  String images;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnRemark: remark,
      columnContact: contact,
      columnPhone: phone,
      columnImages: images,
      columnCategory: categoryId,
    };
    if (billId != null) {
      map[columnId] = billId;
    }
    return map;
  }

  Bill();

  Bill.fromMap(Map<String, dynamic> map) {
    billId = map[columnId];
    title = map[columnTitle];
    remark = map[columnRemark];
    contact = map[columnContact];
    phone = map[columnPhone];
    images = map[columnImages];
    categoryId = map[columnCategory];
  }
}

class BillProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        String sql = '''create table $tableBill(
            $columnId        text primary key, 
            $columnTitle     text not null,
            $columnRemark    text,
            $columnContact   text,
            $columnPhone     text,
            $columnCategory  text not null,
            $columnImages    text not null)''';
        await db.execute(sql);
      },
    );
  }

  Future insert(Bill bill) async {
    bill.billId = DateTime.now().millisecond.toString();
    bill.categoryId = "12";
    return db.insert(tableBill, bill.toMap());
  }

  Future<Bill> getBill(String billId) async {
    List<Map> map = await db.query(tableBill,
        columns: [
          columnImages,
          columnCategory,
          columnPhone,
          columnContact,
          columnRemark,
          columnId
        ],
        where: "$columnId =  ?",
        whereArgs: [billId]);
    if (map.length > 0) {
      return new Bill.fromMap(map.first);
    } else {
      return null;
    }
  }

  Future<int> delete(String billid) async {
    return db.delete(tableBill, where: "$columnId = ?", whereArgs: [billid]);
  }

  Future<int> update(Bill bill) async {
    return await db.update(tableBill, bill.toMap(),
        where: "$columnId = ?", whereArgs: [bill.billId]);
  }

  Future close() async => db.close();
}
