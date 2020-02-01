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
    _localDBService.getTransactions(uid).listen(
        (transactions) => _fireDBService.addAllTransactions(transactions));
    await _fireDBService.deleteAllCategories();
    _localDBService
        .getCategories(uid)
        .listen((categories) => _fireDBService.addAllCategories(categories));
    await _fireDBService.deleteAllPeriods();
    _localDBService
        .getPeriods(uid)
        .listen((periods) => _fireDBService.addAllPeriods(periods));
    await _fireDBService.deletePreferences();
    _localDBService
        .getPreferences(uid)
        .listen((preferences) => _fireDBService.addPreferences(preferences));
  }

  void syncToLocal() {
    _localDBService.findUser(uid).listen((localUser) {
      if (localUser == null) {
        _fireDBService
            .findUser()
            .listen((user) => _localDBService.addUser(user));
      }
    });
    _localDBService.getTransactions(uid).listen((localTransactions) {
      if (localTransactions.length == 0) {
        _fireDBService.getTransactions().listen((cloudTransactions) =>
            _localDBService.addAllTransactions(cloudTransactions));
      }
    });
    _localDBService.getCategories(uid).listen((localCategories) {
      if (localCategories.length == 0) {
        _fireDBService.getCategories().listen((cloudCategories) =>
            _localDBService.addAllCategories(cloudCategories));
      }
    });
    _localDBService.getPeriods(uid).listen((localPeriods) {
      if (localPeriods.length == 0) {
        _fireDBService.getPeriods().listen(
            (cloudPeriods) => _localDBService.addAllPeriods(cloudPeriods));
      }
    });
    _localDBService.getPreferences(uid).listen((localPreferences) {
      if (localPreferences == null) {
        _fireDBService.getPreferences().listen((cloudPreferences) =>
            _localDBService.addPreferences(cloudPreferences));
      }
    });
  }
}
