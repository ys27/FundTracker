import 'package:background_fetch/background_fetch.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';

class BackgroundService {
  final String uid;

  BackgroundService(this.uid);

  static void backgroundFetchHeadlessTask(String taskId) async {
    print('[BackgroundFetch] Headless event received.');
    BackgroundFetch.finish(taskId);
  }

  static Future<void> initBackgroundService(String uid) async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE,
          startOnBoot: true,
          stopOnTerminate: false,
        ), (String taskId) async {
      print('[BackgroundFetch] Event received $taskId');
      DatabaseWrapper(uid)
          .getRecurringTransactions()
          .first
          .then((recurringTransactions) {
        for (RecurringTransaction recurringTransaction
            in recurringTransactions) {
          if (recurringTransaction.nextDate
                  .difference(DateTime.now())
                  .inMinutes <
              20) {
            DatabaseWrapper(uid)
                .addTransactions([recurringTransaction.toTransaction()]);
            DatabaseWrapper(uid)
                .incrementRecurringTransactionsNextDate([recurringTransaction]);
          }
        }
      });
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  }
}
