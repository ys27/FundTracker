import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/services/localDB.dart';

class SyncService {
  final String uid;
  FireDBService _fireDBService;
  LocalDBService _localDBService;

  SyncService(this.uid) {
    this._fireDBService = FireDBService(this.uid);
    this._localDBService = LocalDBService();
  }

  void syncTransactions() async {
    List<Transaction> cloudTransactions =
        await _fireDBService.getTransactions().first;
    List<Transaction> localTransactions =
        await _localDBService.getTransactions(uid).first;
    List<Transaction> transactionsOnlyInCloud = cloudTransactions
        .where((cloud) =>
            localTransactions.where((local) => local.equalTo(cloud)).length ==
            0)
        .toList();
    List<Transaction> transactionsOnlyInLocal = localTransactions
        .where((local) =>
            cloudTransactions.where((cloud) => cloud.equalTo(local)).length ==
            0)
        .toList();
    _fireDBService.deleteTransactions(transactionsOnlyInCloud);
    _fireDBService.addTransactions(transactionsOnlyInLocal);
  }

  void syncCategories() async {
    await _fireDBService.deleteAllCategories();
    _localDBService
        .getCategories(uid)
        .first
        .then((categories) => _fireDBService.addCategories(categories));
  }

  void syncPeriods() async {
    List<Period> cloudPeriods = await _fireDBService.getPeriods().first;
    List<Period> localPeriods = await _localDBService.getPeriods(uid).first;
    List<Period> periodsOnlyInCloud = cloudPeriods
        .where((cloud) =>
            localPeriods.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<Period> periodsOnlyInLocal = localPeriods
        .where((local) =>
            cloudPeriods.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    _fireDBService.deletePeriods(periodsOnlyInCloud);
    _fireDBService.addPeriods(periodsOnlyInLocal);
  }

  void syncRecurringTransactions() async {
    List<RecurringTransaction> cloudRecTxs =
        await _fireDBService.getRecurringTransactions().first;
    List<RecurringTransaction> localRecTxs =
        await _localDBService.getRecurringTransactions(uid).first;
    List<RecurringTransaction> recTxsOnlyInCloud = cloudRecTxs
        .where((cloud) =>
            localRecTxs.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<RecurringTransaction> recTxsOnlyInLocal = localRecTxs
        .where((local) =>
            cloudRecTxs.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    _fireDBService.deleteRecurringTransactions(recTxsOnlyInCloud);
    _fireDBService.addRecurringTransactions(recTxsOnlyInLocal);
  }

  void syncPreferences() async {
    await _fireDBService.deletePreferences();
    _localDBService
        .getPreferences(uid)
        .first
        .then((preferences) => _fireDBService.addPreferences(preferences));
  }

  void syncToCloud() {
    syncTransactions();
    syncCategories();
    syncPeriods();
    syncPreferences();
  }

  Future syncToLocal() async {
    if (await _localDBService.getUser(uid) == null) {
      _fireDBService.getUser().then((user) => _localDBService.addUser(user));
      _fireDBService.getTransactions().first.then((cloudTransactions) =>
          _localDBService.addTransactions(cloudTransactions));
      _fireDBService.getCategories().first.then(
          (cloudCategories) => _localDBService.addCategories(cloudCategories));
      _fireDBService
          .getPeriods()
          .first
          .then((cloudPeriods) => _localDBService.addPeriods(cloudPeriods));
      _fireDBService.getRecurringTransactions().first.then(
          (cloudRecurringTransactions) => _localDBService
              .addRecurringTransactions(cloudRecurringTransactions));
      _fireDBService.getPreferences().first.then((cloudPreferences) =>
          _localDBService.addPreferences(cloudPreferences));
    }
  }
}
