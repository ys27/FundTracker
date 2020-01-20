import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/preferences/categoriesRegistry.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:streamqflite/streamqflite.dart';
import 'package:uuid/uuid.dart';

class LocalDBService {
  static final LocalDBService _localDBService = new LocalDBService.internal();
  factory LocalDBService() => _localDBService;
  static StreamDatabase _streamDatabase;

  Future<StreamDatabase> get db async {
    if (_streamDatabase != null) {
      return _streamDatabase;
    }
    _streamDatabase = StreamDatabase(await initializeDBs());
    return _streamDatabase;
  }

  LocalDBService.internal();

  // Transactions
  Stream<List<Transaction>> getTransactions(String uid) async* {
    StreamDatabase db = await this.db;
    yield* db
        .createQuery('transactions',
            where: 'uid = ?', whereArgs: [uid], orderBy: 'datetime(date) DESC')
        .mapToList((map) => Transaction.fromMap(map));
  }

  Future<int> addTransaction(Transaction tx) async {
    StreamDatabase db = await this.db;
    return await db.insert('transactions', tx.toMap());
  }

  Future<int> updateTransaction(Transaction tx) async {
    StreamDatabase db = await this.db;
    return await db.update('transactions', tx.toMap(),
        where: 'tid = ?', whereArgs: [tx.tid]);
  }

  Future<int> deleteTransaction(Transaction tx) async {
    StreamDatabase db = await this.db;
    return await db
        .delete('transactions', where: 'tid = ?', whereArgs: [tx.tid]);
  }

  // Categories
  Stream<List<Category>> getCategories(String uid) async* {
    StreamDatabase db = await this.db;
    yield* db
        .createQuery('categories',
            where: 'uid = ?', whereArgs: [uid], orderBy: 'orderIndex ASC')
        .mapToList((map) => Category.fromMap(map));
  }

  void addDefaultCategories(String uid) async {
    StreamDatabase db = await this.db;
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

  void setCategory(Category category) async {
    StreamDatabase db = await this.db;
    await db.update('categories', category.toMap(),
        where: 'cid = ?', whereArgs: [category.cid]);
  }

  Future<int> removeAllCategories(String uid) async {
    StreamDatabase db = await this.db;
    return await db.delete('transactions', where: 'uid = ?', whereArgs: [uid]);
  }

  // User
  Stream<User> findUser(String uid) async* {
    StreamDatabase db = await this.db;
    yield* db.createQuery('users',
        where: 'uid = ?',
        whereArgs: [uid]).mapToOne((map) => User.fromMap(map));
  }

  Future<int> addUser(User user) async {
    StreamDatabase db = await this.db;
    return await db.insert('users', user.toMap());
  }

  // Database-related

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

    return await openDatabase('$directory/test2.db',
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
