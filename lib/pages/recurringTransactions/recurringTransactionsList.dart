import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:provider/provider.dart';

class RecurringTransactionsList extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  RecurringTransactionsList({this.user, this.openPage});

  @override
  _RecurringTransactionsListState createState() =>
      _RecurringTransactionsListState();
}

class _RecurringTransactionsListState extends State<RecurringTransactionsList> {
  List<RecurringTransaction> _recTxs;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Loader();

    if (_recTxs != null) {
      if (_recTxs.length == 0) {
        _body = Center(
          child: Text('Add a recurring transaction using the button below.'),
        );
      } else {
        _body = Container(
          padding: bodyPadding,
          child: ListView.builder(
            itemCount: _recTxs.length,
            itemBuilder: (context, index) => recurringTransactionCard(
              context,
              _recTxs[index],
              () => retrieveNewData(widget.user.uid),
            ),
          ),
        );
      }
    }

    return Scaffold(
      drawer: MainDrawer(widget.user, widget.openPage),
      appBar: AppBar(title: Text('Recurring Transactions')),
      body: _body,
      floatingActionButton: addFloatingButton(
        context,
        MultiProvider(
          providers: [
            FutureProvider<List<Transaction>>.value(
                value: DatabaseWrapper(widget.user.uid).getTransactions()),
            FutureProvider<List<Category>>.value(
                value: DatabaseWrapper(widget.user.uid).getCategories()),
          ],
          child:
              TransactionForm(getTxOrRecTx: () => RecurringTransaction.empty()),
        ),
        () => retrieveNewData(widget.user.uid),
      ),
    );
  }

  Widget recurringTransactionCard(
    BuildContext context,
    RecurringTransaction recTx,
    Function refreshList,
  ) {
    return Card(
      color: recTx.isExpense ? Colors.red[50] : Colors.green[50],
      child: ListTile(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => MultiProvider(
              providers: [
                FutureProvider<List<Transaction>>.value(
                    value: DatabaseWrapper(widget.user.uid).getTransactions()),
                FutureProvider<List<Category>>.value(
                    value: DatabaseWrapper(widget.user.uid).getCategories()),
              ],
              child: TransactionForm(getTxOrRecTx: () => recTx),
            ),
          );
          refreshList();
        },
        title: Text(
          '${recTx.payee}: ${recTx.isExpense ? '-' : '+'}\$${recTx.amount.toStringAsFixed(2)}',
        ),
        subtitle: Text(
          'Every ${recTx.frequencyValue} ${recTx.frequencyUnit.toString().split('.')[1]}',
        ),
        trailing: Text('Next Date: ${getDateStr(recTx.nextDate)}'),
      ),
    );
  }

  void retrieveNewData(String uid) {
    DatabaseWrapper(uid).getRecurringTransactions().then((recTxs) {
      setState(() => _recTxs = List<RecurringTransaction>.from(recTxs));
    });
  }
}
