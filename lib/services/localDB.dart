import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/preferences/categoriesRegistry.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:uuid/uuid.dart';

class LocalDBService {
  static final LocalDBService _localDBService = new LocalDBService.internal();

  factory LocalDBService() => _localDBService;
  static Database _localDB;

  Future<Database> get db async {
    if (_localDB != null) {
      return _localDB;
    }
    _localDB = await initializeDBs();
    return _localDB;
  }

  LocalDBService.internal();

  Future<List<Transaction>> getTransactions(String uid) async {
    Database db = await this.db;
    List<Map<String, dynamic>> resultsMap = await db.query('transactions',
        where: 'uid = ?', whereArgs: [uid], orderBy: 'datetime(date) DESC');
    return resultsMap.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Category>> getCategories(String uid) async {
    Database db = await this.db;
    List<Map<String, dynamic>> resultsMap = await db.query('categories',
        where: 'uid = ?', whereArgs: [uid], orderBy: 'orderIndex ASC');
    return resultsMap.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<User>> findUser(String uid) async {
    Database db = await this.db;
    List<Map<String, dynamic>> resultsMap =
        await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    return resultsMap.map((map) => User.fromMap(map)).toList();
  }

  void addDefaultCategories(String uid) async {
    Database db = await this.db;
    CATEGORIES.asMap().forEach((index, category) async {
      await db.insert('categories', {
        'cid': new Uuid().v1(),
        'name': category['name'],
        'icon': category['icon'],
        'enabled': true,
        'orderIndex': index,
        'uid': uid,
      });
    });
  }

  Future<int> addTransaction(Transaction tx) async {
    Database db = await this.db;
    return await db.insert('transactions', tx.toMap());
  }

  Future<int> addUser(User user) async {
    Database db = await this.db;
    return await db.insert('users', user.toMap());
  }

  void setCategory(Category category) async {
    Database db = await this.db;
    await db.update('categories', category.toMap(),
        where: 'cid = ?', whereArgs: [category.cid]);
  }

  Future<int> updateTransaction(Transaction tx) async {
    Database db = await this.db;
    return await db.update('transactions', tx.toMap(),
        where: 'tid = ?', whereArgs: [tx.tid]);
  }

  Future<int> deleteTransaction(Transaction tx) async {
    Database db = await this.db;
    return await db
        .delete('transactions', where: 'tid = ?', whereArgs: [tx.tid]);
  }

  Future<int> removeAllCategories(String uid) async {
    Database db = await this.db;
    return await db
        .delete('transactions', where: 'uid = ?', whereArgs: [uid]);
  }

  String getTypeInDB(dynamic column) {
    if (column is String) {
      return 'TEXT';
    } else if (column is int) {
      return 'INTEGER';
    } else if (column is bool) {
      return 'INTEGER'; // 1 - true, 0 - false
    } else if (column is DateTime) {
      return 'TEXT';
    } else if (column is double) {
      return 'REAL';
    } else {
      return 'TEXT';
    }
  }

  Future<Database> initializeDBs() async {
    String directory = await getDatabasesPath();

    return await openDatabase('$directory/local.db',
        version: 1, onCreate: _createDBs);
  }

  void _createDBs(Database db, int version) {
    Map<String, dynamic> tables = {
      'categories': Category.example(),
      'transactions': Transaction.example(),
      'users': User.example(),
    };
    tables.forEach((tableName, model) async {
      String columnsQuery = '';
      for (MapEntry<String, dynamic> column in model.toMap().entries) {
        columnsQuery += '${column.key} ${getTypeInDB(column.value)}';
        if (column.key == '${tableName[0].toLowerCase()}id') {
          columnsQuery += ' PRIMARY KEY';
        }
        columnsQuery += ', ';
      }
      columnsQuery = columnsQuery.substring(0, columnsQuery.length - 2);
      await db.execute('CREATE TABLE $tableName($columnsQuery)');
    });
  }
}
