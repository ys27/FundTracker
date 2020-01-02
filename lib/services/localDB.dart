import 'dart:io';

import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path_provider/path_provider.dart';

class LocalDBService {
  static LocalDBService _localDBService;
  static Database _localDB;

  LocalDBService._createInstance();

  factory LocalDBService() {
    if (_localDBService == null) {
      _localDBService = LocalDBService._createInstance();
    }

    return _localDBService;
  }

  Future<Database> get database async {
    if (_localDB == null) {
      _localDB = await initializeDBs();
    }

    return _localDB;
  }

  Future<List<Map<String, dynamic>>> getTable(String tableName) async {
    Database db = await this.database;
    String orderBy = '';
    switch (tableName) {
      case 'categories':
        orderBy = 'orderIndex ASC';
        break;
      case 'transactions':
        orderBy = 'datetime(date) DESC';
        break;
      default:
        orderBy = '';
        break;
    }
    return await db.query(tableName, orderBy: orderBy);
  }

  Future<int> insert(String tableName, dynamic item) async {
    Database db = await this.database;
    return await db.insert(tableName, item.toMap());
  }

  Future<int> update(String tableName, dynamic item, String whereColumn,
      dynamic whereArg) async {
    Database db = await this.database;
    return await db.update(tableName, item.toMap(),
        where: '$whereColumn = ?', whereArgs: [whereArg]);
  }

  Future<int> delete(
      String tableName, String whereColumn, dynamic whereArg) async {
    Database db = await this.database;
    return await db
        .delete(tableName, where: '$whereColumn = ?', whereArgs: [whereArg]);
  }

  String getTypeInDB(dynamic column) {
    if (column is String) {
      print('String');
      return 'TEXT';
    } else if (column is int) {
      print('int');
      return 'INTEGER';
    } else if (column is bool) {
      print('bool');
      return 'INTEGER'; // 1 - true, 0 - false
    } else if (column is DateTime) {
      print('DateTime');
      return 'TEXT';
    } else if (column is double) {
      print('double');
      return 'REAL';
    } else {
      return 'TEXT';
    }
  }

  Future<Database> initializeDBs() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'local.db';

    return await openDatabase(path, version: 1, onCreate: _createDBs);
  }

  void _createDBs(Database db, int version) {
    Map<String, dynamic> tables = {
      'categories': Category.empty(),
      'transactions': Transaction.empty(),
      'users': User.empty(),
    };
    tables.forEach((tableName, model) async {
      String columnsQuery = '';
      for (MapEntry<String, dynamic> column in model.toMap().entries) {
        columnsQuery += '${column.key} ${getTypeInDB(column.value)}';
        if (column.key.endsWith('id')) {
          columnsQuery += ' PRIMARY KEY';
        }
        columnsQuery += ', ';
      }
      print(columnsQuery);
      await db.execute('CREATE TABLE $tableName(${columnsQuery}uid TEXT)');
    });
  }
}
