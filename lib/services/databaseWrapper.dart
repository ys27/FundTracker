import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
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
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addTransaction(tx)
        : await _localDBService.addTransaction(tx);
  }

  Future updateTransaction(Transaction tx) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updateTransaction(tx)
        : await _localDBService.updateTransaction(tx);
  }

  Future deleteTransaction(Transaction tx) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteTransaction(tx)
        : await _localDBService.deleteTransaction(tx);
  }

  Future deleteAllTransactions() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllTransactions()
        : await _localDBService.deleteAllTransactions(uid);
  }

  // Categories
  Stream<List<Category>> getCategories() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getCategories()
        : _localDBService.getCategories(uid);
  }

  Future addDefaultCategories() async {
    await _fireDBService.addDefaultCategories();
    await _localDBService.addDefaultCategories(uid);
  }

  Future setCategory(Category category) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.setCategory(category)
        : await _localDBService.setCategory(category);
  }

  Future deleteAllCategories() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllCategories()
        : await _localDBService.deleteAllCategories(uid);
  }

  Future resetCategories() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllCategories()
        : await _localDBService.deleteAllCategories(uid);

    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addDefaultCategories()
        : await _localDBService.addDefaultCategories(uid);
  }

  // User Info
  Stream<User> findUser() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.findUser()
        : _localDBService.findUser(uid);
  }

  Future addUser(User user) async {
    await _fireDBService.addUser(user);
    await _localDBService.addUser(user);
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

  Future setRemainingNotDefault(Period period) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.setRemainingNotDefault(period)
        : await _localDBService.setRemainingNotDefault(period);
  }

  Future addPeriod(Period period) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addPeriod(period)
        : await _localDBService.addPeriod(period);
  }

  Future updatePeriod(Period period) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updatePeriod(period)
        : await _localDBService.updatePeriod(period);
  }

  Future deletePeriod(Period period) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deletePeriod(period)
        : await _localDBService.deletePeriod(period);
  }

  // Preferences
  Stream<Preferences> getPreferences() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getPreferences()
        : _localDBService.getPreferences(uid);
  }

  Future addDefaultPreferences() async {
    await _fireDBService.addDefaultPreferences();
    await _localDBService.addDefaultPreferences(uid);
  }

  Future updatePreferences(Preferences prefs) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updatePreferences(prefs)
        : await _localDBService.updatePreferences(prefs);
  }

  Future resetPreferences() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deletePreferences()
        : await _localDBService.deletePreferences(uid);

    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addDefaultPreferences()
        : await _localDBService.addDefaultPreferences(uid);
  }
}
