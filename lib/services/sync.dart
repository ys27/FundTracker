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

  Future syncToCloud() async {
    await _fireDBService.deleteAllTransactions();
    _localDBService.getTransactions(uid).first.then(
        (transactions) => _fireDBService.addAllTransactions(transactions));
    await _fireDBService.deleteAllCategories();
    _localDBService
        .getCategories(uid)
        .first
        .then((categories) => _fireDBService.addAllCategories(categories));
    await _fireDBService.deleteAllPeriods();
    _localDBService
        .getPeriods(uid)
        .first
        .then((periods) => _fireDBService.addAllPeriods(periods));
    await _fireDBService.deletePreferences();
    _localDBService
        .getPreferences(uid)
        .first
        .then((preferences) => _fireDBService.addPreferences(preferences));
  }

  Future syncToLocal() async {
    if (await _localDBService.findUser(uid) == null) {
      _fireDBService.findUser().then((user) => _localDBService.addUser(user));
    }
    _localDBService.getTransactions(uid).first.then((localTransactions) {
      if (localTransactions.length == 0) {
        _fireDBService.getTransactions().first.then((cloudTransactions) =>
            _localDBService.addAllTransactions(cloudTransactions));
      }
    });
    _localDBService.getCategories(uid).first.then((localCategories) {
      if (localCategories.length == 0) {
        _fireDBService.getCategories().first.then((cloudCategories) =>
            _localDBService.addAllCategories(cloudCategories));
      }
    });
    _localDBService.getPeriods(uid).first.then((localPeriods) {
      if (localPeriods.length == 0) {
        _fireDBService.getPeriods().first.then(
            (cloudPeriods) => _localDBService.addAllPeriods(cloudPeriods));
      }
    });
    _localDBService.getPreferences(uid).first.then((localPreferences) {
      if (localPreferences == null) {
        _fireDBService.getPreferences().first.then((cloudPreferences) =>
            _localDBService.addPreferences(cloudPreferences));
      }
    });
  }
}
