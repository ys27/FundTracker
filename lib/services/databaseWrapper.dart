import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/config.dart';
import 'package:fund_tracker/shared/constants.dart';

class DatabaseWrapper {
  final String uid;
  FireDBService _fireDBService;
  LocalDBService _localDBService;

  DatabaseWrapper(this.uid) {
    this._fireDBService = FireDBService(this.uid);
    this._localDBService = LocalDBService();
  }

  // Transactions
  Stream<List<Transaction>> getTransactions() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getTransactions()
        : _localDBService.getTransactions(uid);
  }

  Future addTransaction(Transaction tx) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addTransaction(tx)
        : _localDBService.addTransaction(tx);
  }

  Future updateTransaction(Transaction tx) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.updateTransaction(tx)
        : _localDBService.updateTransaction(tx);
  }

  Future deleteTransaction(Transaction tx) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.deleteTransaction(tx)
        : _localDBService.deleteTransaction(tx);
  }

  // Categories
  Stream<List<Category>> getCategories() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getCategories()
        : _localDBService.getCategories(uid);
  }

  void addDefaultCategories() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addDefaultCategories()
        : _localDBService.addDefaultCategories(uid);
  }

  void setCategory(Category category) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.setCategory(category)
        : _localDBService.setCategory(category);
  }

  void removeAllCategories() async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.removeAllCategories()
        : _localDBService.removeAllCategories(uid);
  }

  // User Info
  Stream<User> findUser() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.findUser()
        : _localDBService.findUser(uid);
  }

  Future addUser(User user) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addUser(user)
        : _localDBService.addUser(user);
  }

  // Periods
  Stream<List<Period>> getPeriods() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getPeriods()
        : _localDBService.getPeriods(uid);
  }

  Stream<Period> getDefaultPeriod() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getDefaultPeriod()
        : _localDBService.getDefaultPeriod(uid);
  }

  Future addPeriod(Period period) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addPeriod(period)
        : _localDBService.addPeriod(period);
  }

  Future updatePeriod(Period period) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.updatePeriod(period)
        : _localDBService.updatePeriod(period);
  }

  Future deletePeriod(Period period) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.deletePeriod(period)
        : _localDBService.deletePeriod(period);
  }
}
