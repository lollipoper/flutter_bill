import 'dart:async';

import 'package:flutter_bill/sql/category.dart';
import 'package:path/path.dart' show join;
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
  String categoryName;
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

  static Future createTable(Database db) async {
    String sql = '''create table $tableBill(
            $columnId        text primary key, 
            $columnTitle     text not null,
            $columnRemark    text,
            $columnContact   text,
            $columnPhone     text,
            $columnCategory  text,
            $columnImages    text not null)''';
    await db.execute(sql);
  }

  Future open() async {
    var databasesPath = await getDatabasesPath();
    db = await openDatabase(
      join(databasesPath, "db.db"),
      version: 1,
      onCreate: (Database db, int version) async {
        BillProvider.createTable(db);
        CategoryProvider.createTable(db);
      },
    );
  }

  Future<List<Bill>> getBills() async {
    List<Map> rawQuery = await db.rawQuery("Select * from $tableBill");
    List<Bill> list = new List();
    rawQuery.forEach((Map map) {
      var bill = Bill.fromMap(map);
      list.add(bill);
    });
    return list;
  }

  Future<List<Bill>> getBillsWithLabel(String labelId) async {
    List<Map> map = await db.query(tableBill,
        distinct: false,
        columns: [
          columnImages,
          columnCategory,
          columnPhone,
          columnContact,
          columnRemark,
          columnId,
          columnTitle
        ],
        where: "$columnCategory = ?",
        whereArgs: [labelId]);
    List<Bill> list = new List();
    map.forEach((Map map) {
      var bill = Bill.fromMap(map);
      list.add(bill);
    });
    return list;
  }

  Future insert(Bill bill) async {
    bill.billId = DateTime.now().millisecond.toString();
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
          columnId,
          columnTitle
        ],
        where: "$columnId =  ?",
        whereArgs: [billId]);
    if (map.length > 0) {
      return new Bill.fromMap(map.first);
    } else {
      return null;
    }
  }

  Future<int> delete(String billId) async {
    return db.delete(tableBill, where: "$columnId = ?", whereArgs: [billId]);
  }

  Future<int> deleteByLabel(String categoryId) async {
    return db.delete(tableBill,
        where: "$columnCategory= ?", whereArgs: [categoryId]);
  }

  Future<int> update(Bill bill) async {
    return await db.update(tableBill, bill.toMap(),
        where: "$columnId = ?", whereArgs: [bill.billId]);
  }

  Future close() async => db.close();
}
