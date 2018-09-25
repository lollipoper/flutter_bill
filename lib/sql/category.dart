import 'dart:async';

import 'package:flutter_bill/sql/bill.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

final String tableBillCategory = "Category";
final String columnId = "id";
final String columnTitle = "title";

class Category {
  String categoryId;
  String title;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
    };
    if (categoryId != null) {
      map[columnId] = categoryId;
    }
    return map;
  }

  Category({this.title});

  Category.fromMap(Map<String, dynamic> map) {
    categoryId = map[columnId];
    title = map[columnTitle];
  }
}

class CategoryProvider {
  Database db;

  static Future createTable(Database db) async {
    String sql = '''create table $tableBillCategory(
            $columnId        text primary key, 
            $columnTitle     text not null)''';
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

  Future<List<Category>> getCategories() async {
    List<Map> rawQuery = await db.rawQuery("Select * from $tableBillCategory");
    List<Category> list = new List();
    rawQuery.forEach((Map map) {
      var bill = Category.fromMap(map);
      list.add(bill);
    });
    return list;
  }

  Future insert(Category category) async {
    category.categoryId = DateTime.now().millisecond.toString();
    return db.insert(tableBillCategory, category.toMap());
  }

  Future<Category> getCategory(String categoryId) async {
    List<Map> map = await db.query(tableBillCategory,
        columns: [columnId, columnTitle],
        where: "$columnId =  ?",
        whereArgs: [categoryId]);
    if (map.length > 0) {
      return new Category.fromMap(map.first);
    } else {
      return null;
    }
  }

  Future<int> delete(String categoryId) async {
    return db.delete(tableBillCategory,
        where: "$columnId = ?", whereArgs: [categoryId]);
  }

  Future<int> update(Category category) async {
    return await db.update(tableBillCategory, category.toMap(),
        where: "$columnId = ?", whereArgs: [category.categoryId]);
  }

  Future close() async => db.close();
}
