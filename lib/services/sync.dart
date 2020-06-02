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
        await _fireDBService.getTransactions();
    List<Transaction> localTransactions =
        await _localDBService.getTransactions(uid);
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
        .then((categories) => _fireDBService.addCategories(categories));
  }

  void syncPeriods() async {
    List<Period> cloudPeriods = await _fireDBService.getPeriods();
    List<Period> localPeriods = await _localDBService.getPeriods(uid);

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
        await _fireDBService.getRecurringTransactions();
    List<RecurringTransaction> localRecTxs =
        await _localDBService.getRecurringTransactions(uid);
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
        .then((preferences) => _fireDBService.addPreferences(preferences));
  }

  void syncToCloud() {
    syncTransactions();
    syncCategories();
    syncPeriods();
    syncRecurringTransactions();
    syncPreferences();
  }

  Future syncToLocal() async {
    if (await _localDBService.getUser(uid) == null) {
      final List<Future> getThenAdd = [
        _fireDBService.getUser().then((user) => _localDBService.addUser(user)),
        _fireDBService.getTransactions().then((cloudTransactions) =>
            _localDBService.addTransactions(cloudTransactions)),
        _fireDBService.getCategories().then((cloudCategories) =>
            _localDBService.addCategories(cloudCategories)),
        _fireDBService
            .getPeriods()
            .then((cloudPeriods) => _localDBService.addPeriods(cloudPeriods)),
        _fireDBService.getRecurringTransactions().then(
            (cloudRecurringTransactions) => _localDBService
                .addRecurringTransactions(cloudRecurringTransactions)),
        _fireDBService.getPreferences().then((cloudPreferences) =>
            _localDBService.addPreferences(cloudPreferences)),
      ];
      await Future.wait(getThenAdd);
    }
  }
}
