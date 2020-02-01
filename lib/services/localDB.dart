import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/shared/config.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:streamqflite/streamqflite.dart';
import 'package:uuid/uuid.dart';

class LocalDBService {
  static final LocalDBService _localDBService = LocalDBService.internal();
  factory LocalDBService() => _localDBService;
  static StreamDatabase _streamDatabase;
  static Database _localDB;

  Future<StreamDatabase> get db async {
    if (_streamDatabase != null) {
      return _streamDatabase;
    }
    _streamDatabase = StreamDatabase(await initializeDBs());
    return _streamDatabase;
  }

  Future<Database> get database async {
    if (_localDB == null) {
      _localDB = await initializeDBs();
    }

    return _localDB;
  }

  LocalDBService.internal();

  // Transactions
  Stream<List<Transaction>> getTransactions(String uid) async* {
    StreamDatabase db = await this.db;
    yield* db
        .createQuery(
          'transactions',
          where: 'uid = ?',
          whereArgs: [uid],
          orderBy: 'datetime(date) DESC',
        )
        .mapToList((map) => Transaction.fromMap(map));
  }

  // Alternative
  // Stream<List<Transaction>> getTransactions(String uid) async* {
  //   Database db = await this.database;
  //   yield* db
  //       .query(
  //         'transactions',
  //         where: 'uid = ?',
  //         whereArgs: [uid],
  //         orderBy: 'datetime(date) DESC',
  //       )
  //       .asStream()
  //       .map((transactions) =>
  //           transactions.map((map) => Transaction.fromMap(map)).toList());
  // }

  Future addTransaction(Transaction tx) async {
    StreamDatabase db = await this.db;
    await db.insert('transactions', tx.toMap());
  }

  Future addAllTransactions(List<Transaction> transactions) async {
    StreamDatabase db = await this.db;
    transactions.forEach((tx) {
      db.insert('transactions', tx.toMap());
    });
  }

  Future updateTransaction(Transaction tx) async {
    StreamDatabase db = await this.db;
    await db.update(
      'transactions',
      tx.toMap(),
      where: 'tid = ?',
      whereArgs: [tx.tid],
    );
  }

  Future deleteTransaction(Transaction tx) async {
    StreamDatabase db = await this.db;
    await db.delete('transactions', where: 'tid = ?', whereArgs: [tx.tid]);
  }

  Future deleteAllTransactions(String uid) async {
    StreamDatabase db = await this.db;
    await db.delete('transactions', where: 'uid = ?', whereArgs: [uid]);
  }

  // Categories
  Stream<List<Category>> getCategories(String uid) async* {
    StreamDatabase db = await this.db;
    yield* db
        .createQuery(
          'categories',
          where: 'uid = ?',
          whereArgs: [uid],
          orderBy: 'orderIndex ASC',
        )
        .mapToList((map) => Category.fromMap(map));
  }

  Future addDefaultCategories(String uid) async {
    StreamDatabase db = await this.db;
    categoriesRegistry.asMap().forEach((index, category) async {
      await db.insert(
        'categories',
        Category(
          cid: Uuid().v1(),
          name: category['name'],
          icon: category['icon'],
          enabled: true,
          orderIndex: index,
          uid: uid,
        ).toMap(),
      );
    });
  }

  Future addAllCategories(List<Category> categories) async {
    StreamDatabase db = await this.db;
    categories.forEach((category) async {
      await db.insert('categories', category.toMap());
    });
  }

  Future setCategory(Category category) async {
    StreamDatabase db = await this.db;
    await db.update(
      'categories',
      category.toMap(),
      where: 'cid = ?',
      whereArgs: [category.cid],
    );
  }

  Future deleteAllCategories(String uid) async {
    StreamDatabase db = await this.db;
    await db.delete('categories', where: 'uid = ?', whereArgs: [uid]);
  }

  // User
  Future<User> findUser(String uid) async {
    Database db = await this.database;
    return db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    ).then((map) => map.length == 1 ? User.fromMap(map[0]) : null);
  }

  Future addUser(User user) async {
    StreamDatabase db = await this.db;
    await db.insert('users', user.toMap());
  }

  // Periods
  Stream<List<Period>> getPeriods(String uid) async* {
    StreamDatabase db = await this.db;
    yield* db
        .createQuery(
          'periods',
          where: 'uid = ?',
          whereArgs: [uid],
          orderBy: 'isDefault DESC',
        )
        .mapToList((map) => Period.fromMap(map));
  }

  Stream<Period> getDefaultPeriod(String uid) async* {
    StreamDatabase db = await this.db;
    yield* db.createQuery(
      'periods',
      where: 'uid = ? AND isDefault = 1',
      whereArgs: [uid],
    ).mapToOneOrDefault((map) => Period.fromMap(map), Period.monthly());
  }

  Future setRemainingNotDefault(Period period) async {
    StreamDatabase db = await this.db;
    await db.update('periods', {'isDefault': 0});
    await db.update(
      'periods',
      {'isDefault': 1},
      where: 'pid = ?',
      whereArgs: [period.pid],
    );
  }

  Future addPeriod(Period period) async {
    StreamDatabase db = await this.db;
    await db.insert('periods', period.toMap());
  }

  Future addAllPeriods(List<Period> periods) async {
    StreamDatabase db = await this.db;
    periods.forEach((period) async {
      await db.insert('periods', period.toMap());
    });
  }

  Future updatePeriod(Period period) async {
    StreamDatabase db = await this.db;
    await db.update(
      'periods',
      period.toMap(),
      where: 'pid = ?',
      whereArgs: [period.pid],
    );
  }

  Future deletePeriod(Period period) async {
    StreamDatabase db = await this.db;
    await db.delete(
      'periods',
      where: 'pid = ?',
      whereArgs: [period.pid],
    );
  }

  Future deleteAllPeriods(String uid) async {
    StreamDatabase db = await this.db;
    await db.delete('periods', where: 'uid = ?', whereArgs: [uid]);
  }

  // Preferences
  Stream<Preferences> getPreferences(String pid) async* {
    StreamDatabase db = await this.db;
    yield* db.createQuery(
      'preferences',
      where: 'pid = ?',
      whereArgs: [pid],
    ).mapToOneOrDefault((map) => Preferences.fromMap(map), null);
  }

  Future addDefaultPreferences(String pid) async {
    StreamDatabase db = await this.db;
    await db.insert(
      'preferences',
      Preferences.original().setPreference('pid', pid).toMap(),
    );
  }

  Future addPreferences(Preferences prefs) async {
    StreamDatabase db = await this.db;
    await db.insert('preferences', prefs.toMap());
  }

  Future updatePreferences(Preferences prefs) async {
    StreamDatabase db = await this.db;
    await db.update(
      'preferences',
      prefs.toMap(),
      where: 'pid = ?',
      whereArgs: [prefs.pid],
    );
  }

  Future deletePreferences(String pid) async {
    StreamDatabase db = await this.db;
    await db.delete(
      'preferences',
      where: 'pid = ?',
      whereArgs: [pid],
    );
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
    } else if (column is DurationUnit) {
      return 'INTEGER';
    } else {
      return 'TEXT';
    }
  }

  Future<Database> initializeDBs() async {
    String directory = await getDatabasesPath();

    return await openDatabase('$directory/$LOCAL_DATABASE_FILENAME.db',
        version: 1, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  void _createDB(Database db, int version) {
    Map<String, dynamic> tables = {
      'categories': Category.example(),
      'transactions': Transaction.example(),
      'users': User.example(),
      'periods': Period.example(),
      'preferences': Preferences.example(),
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
      db.execute('CREATE TABLE $tableName($columnsQuery)');
    });
  }

  void _upgradeDB(Database db, int oldVersion, int newVersion) {}
}
