import 'package:fund_tracker/models/plannedTransaction.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';

class PlannedTransactionsService {
  static Future<void> checkPlannedTransactions(String uid) async {
    List<PlannedTransaction> plannedTxs =
        await DatabaseWrapper(uid).getPlannedTransactions();
    DateTime now = DateTime.now();
    for (PlannedTransaction plannedTx in plannedTxs) {
      PlannedTransaction iteratingRecTx = plannedTx;
      while (iteratingRecTx != null && iteratingRecTx.nextDate.isBefore(now)) {
        DatabaseWrapper(uid).addTransactions([iteratingRecTx.toTransaction()]);
        DatabaseWrapper(uid)
            .incrementPlannedTransactionsNextDate([iteratingRecTx]);
        iteratingRecTx = await DatabaseWrapper(uid)
            .getPlannedTransaction(iteratingRecTx.rid);
      }
    }
  }
}
