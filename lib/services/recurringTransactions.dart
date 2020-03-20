import 'package:fund_tracker/models/recurringTransaction.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';

class RecurringTransactionsService {
  static checkRecurringTransactions(String uid) async {
    List<RecurringTransaction> recTxs =
        await DatabaseWrapper(uid).getRecurringTransactions();
    DateTime now = DateTime.now();
    for (RecurringTransaction recTx in recTxs) {
      RecurringTransaction iteratingRecTx = recTx;
      while (iteratingRecTx.nextDate.isBefore(now)) {
        DatabaseWrapper(uid).addTransactions([iteratingRecTx.toTransaction()]);
        DatabaseWrapper(uid)
            .incrementRecurringTransactionsNextDate([iteratingRecTx]);
        iteratingRecTx = await DatabaseWrapper(uid)
            .getRecurringTransaction(iteratingRecTx.rid);
      }
    }
  }
}
