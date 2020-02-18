import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
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

  Future addTransactions(List<Transaction> transactions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addTransactions(transactions)
        : await _localDBService.addTransactions(transactions);
  }

  Future updateTransactions(List<Transaction> transactions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updateTransactions(transactions)
        : await _localDBService.updateTransactions(transactions);
  }

  Future deleteTransactions(List<Transaction> transactions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteTransactions(transactions)
        : await _localDBService.deleteTransactions(transactions);
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

  Future addCategories(List<Category> categories) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addCategories(categories)
        : _localDBService.addCategories(categories);
  }

  Future updateCategories(List<Category> categories) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updateCategories(categories)
        : await _localDBService.updateCategories(categories);
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
  Future<User> findUser() {
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

  Future addPeriods(List<Period> periods) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addPeriods(periods)
        : await _localDBService.addPeriods(periods);
  }

  Future updatePeriods(List<Period> periods) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updatePeriods(periods)
        : await _localDBService.updatePeriods(periods);
  }

  Future deletePeriods(List<Period> periods) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deletePeriods(periods)
        : await _localDBService.deletePeriods(periods);
  }

  // Recurring Transactions
  Stream<List<RecurringTransaction>> getRecurringTransactions() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getRecurringTransactions()
        : _localDBService.getRecurringTransactions(uid);
  }

  Future addRecurringTransactions(
    List<RecurringTransaction> recurringTransactions,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addRecurringTransactions(recurringTransactions)
        : await _localDBService.addRecurringTransactions(recurringTransactions);
  }

  Future updateRecurringTransactions(
    List<RecurringTransaction> recurringTransactions,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService
            .updateRecurringTransactions(recurringTransactions)
        : await _localDBService
            .updateRecurringTransactions(recurringTransactions);
  }

  Future deleteRecurringTransactions(
    List<RecurringTransaction> recurringTransactions,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService
            .deleteRecurringTransactions(recurringTransactions)
        : await _localDBService
            .deleteRecurringTransactions(recurringTransactions);
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
