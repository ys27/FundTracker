import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/plannedTransaction.dart';
import 'package:fund_tracker/models/suggestion.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/config.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:uuid/uuid.dart';

class DatabaseWrapper {
  final String uid;
  FireDBService _fireDBService;
  LocalDBService _localDBService;

  DatabaseWrapper(this.uid) {
    this._fireDBService = FireDBService(this.uid);
    this._localDBService = LocalDBService();
  }

  // Transactions
  Future<List<Transaction>> getTransactions() {
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
  Future<List<Category>> getCategories() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getCategories()
        : _localDBService.getCategories(uid);
  }

  Future addDefaultCategories() async {
    List<Category> categories = [];
    categoriesRegistry.asMap().forEach((index, category) async {
      String cid = Uuid().v1();
      categories.add(Category(
        cid: cid,
        name: category['name'],
        icon: category['icon'],
        iconColor: category['color'],
        enabled: true,
        unfiltered: true,
        orderIndex: index,
        uid: uid,
      ));
    });
    await _fireDBService.addCategories(categories);
    await _localDBService.addCategories(categories);
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

  Future deleteCategories(List<Category> categories) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteCategories(categories)
        : await _localDBService.deleteCategories(categories);
  }

  Future deleteAllCategories() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllCategories()
        : await _localDBService.deleteAllCategories(uid);
  }

  // Future resetCategories() async {
  //   DATABASE_TYPE == DatabaseType.Firebase
  //       ? await _fireDBService.deleteAllCategories()
  //       : await _localDBService.deleteAllCategories(uid);

  //   DATABASE_TYPE == DatabaseType.Firebase
  //       ? await _fireDBService.addDefaultCategories()
  //       : await _localDBService.addDefaultCategories(uid);
  // }

  // User Info
  Future<User> getUser() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getUser()
        : _localDBService.getUser(uid);
  }

  Future addUser(User user) async {
    await _fireDBService.addUser(user);
    await _localDBService.addUser(user);
  }

  // Periods
  Future<List<Period>> getPeriods() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getPeriods()
        : _localDBService.getPeriods(uid);
  }

  Future<Period> getDefaultPeriod() {
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

  Future deleteAllPeriods() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllPeriods()
        : await _localDBService.deleteAllPeriods(uid);
  }

  // Planned Transactions
  Future<List<PlannedTransaction>> getPlannedTransactions() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getPlannedTransactions()
        : _localDBService.getPlannedTransactions(uid);
  }

  Future<PlannedTransaction> getPlannedTransaction(String rid) {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getPlannedTransaction(rid)
        : _localDBService.getPlannedTransaction(rid);
  }

  Future addPlannedTransactions(
    List<PlannedTransaction> plannedTxs,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addPlannedTransactions(plannedTxs)
        : await _localDBService.addPlannedTransactions(plannedTxs);
  }

  Future updatePlannedTransactions(
    List<PlannedTransaction> plannedTxs,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updatePlannedTransactions(plannedTxs)
        : await _localDBService.updatePlannedTransactions(plannedTxs);
  }

  Future incrementPlannedTransactionsNextDate(
    List<PlannedTransaction> plannedTxs,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.incrementPlannedTransactionsNextDate(plannedTxs)
        : await _localDBService.incrementPlannedTransactionsNextDate(plannedTxs);
  }

  Future deletePlannedTransactions(
    List<PlannedTransaction> plannedTxs,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deletePlannedTransactions(plannedTxs)
        : await _localDBService.deletePlannedTransactions(plannedTxs);
  }

  Future deleteAllPlannedTransactions() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllPlannedTransactions()
        : await _localDBService.deleteAllPlannedTransactions(uid);
  }

  // Preferences
  Future<Preferences> getPreferences() {
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

// Hidden Suggestions
  Future<List<Suggestion>> getHiddenSuggestions() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getHiddenSuggestions()
        : _localDBService.getHiddenSuggestions(uid);
  }

  Future addHiddenSuggestions(List<Suggestion> suggestions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addHiddenSuggestions(suggestions)
        : await _localDBService.addHiddenSuggestions(suggestions);
  }

  Future deleteHiddenSuggestions(List<Suggestion> suggestions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteHiddenSuggestions(suggestions)
        : await _localDBService.deleteHiddenSuggestions(suggestions);
  }
}
