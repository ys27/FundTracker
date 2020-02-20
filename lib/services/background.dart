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

  static Future<void> initBackgroundService() async {
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
      final String uid = taskId.split('::')[0];
      final String rid = taskId.split('::')[1];
      final RecurringTransaction recurringTransaction =
          await DatabaseWrapper(uid).getRecurringTransaction(rid);
      if (recurringTransaction != null) {
        DatabaseWrapper(uid)
            .addTransactions([recurringTransaction.toTransaction()]);
        DatabaseWrapper(uid)
            .incrementRecurringTransactionsNextDate([recurringTransaction]);
        final RecurringTransaction updatedRecurringTransaction =
            await DatabaseWrapper(uid).getRecurringTransaction(rid);
        scheduleRecurringTransaction(updatedRecurringTransaction, uid);
      }
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  }

  static scheduleRecurringTransaction(
    RecurringTransaction recurringTransaction,
    String uid,
  ) {
    int msUntilNextDate =
        getMilliSecondsUntilNextDate(recurringTransaction.nextDate);
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: '$uid::${recurringTransaction.rid}',
      delay: msUntilNextDate,
    ));
  }
}
