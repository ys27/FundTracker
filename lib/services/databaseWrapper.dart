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

  void addTransaction(Transaction tx) {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addTransaction(tx)
        : _localDBService.addTransaction(tx);
  }

  void updateTransaction(Transaction tx) {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.updateTransaction(tx)
        : _localDBService.updateTransaction(tx);
  }

  void deleteTransaction(Transaction tx) {
    DATABASE_TYPE == DatabaseType.Firebase
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
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addDefaultCategories()
        : _localDBService.addDefaultCategories(uid);
  }

  void setCategory(Category category) {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.setCategory(category)
        : _localDBService.setCategory(category);
  }

  void removeAllCategories() {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.removeAllCategories()
        : _localDBService.removeAllCategories(uid);
  }

  void resetCategories() {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.removeAllCategories()
        : _localDBService.removeAllCategories(uid);

    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addDefaultCategories()
        : _localDBService.addDefaultCategories(uid);
  }

  // User Info
  Stream<User> findUser() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.findUser()
        : _localDBService.findUser(uid);
  }

  void addUser(User user) {
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

  void setRemainingNotDefault(Period period) {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.setRemainingNotDefault(period)
        : _localDBService.setRemainingNotDefault(period);
  }

  void addPeriod(Period period) {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addPeriod(period)
        : _localDBService.addPeriod(period);
  }

  void updatePeriod(Period period) {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.updatePeriod(period)
        : _localDBService.updatePeriod(period);
  }

  void deletePeriod(Period period) {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.deletePeriod(period)
        : _localDBService.deletePeriod(period);
  }

  // Preferences
  Stream<Preferences> getPreferences() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getPreferences()
        : _localDBService.getPreferences(uid);
  }

  void addDefaultPreferences() {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addDefaultPreferences()
        : _localDBService.addDefaultPreferences(uid);
  }

  void updatePreferences(Preferences prefs) {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.updatePreferences(prefs)
        : _localDBService.updatePreferences(prefs);
  }

  void resetPreferences() {
    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.removePreferences()
        : _localDBService.removePreferences(uid);

    DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addDefaultPreferences()
        : _localDBService.addDefaultPreferences(uid);
  }
}
