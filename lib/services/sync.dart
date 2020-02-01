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

  Future syncAll() async {
    //for all - delete all from cloud and add all from local
    await _fireDBService.deleteAllTransactions();
    await _fireDBService.deleteAllPreferences();
    await _fireDBService.deleteAllPeriods();
    await _fireDBService.deleteAllCategories();
  }
}
