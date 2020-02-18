import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
import 'package:fund_tracker/pages/recurringTransactions/recurringTransactionForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:provider/provider.dart';

class RecurringTransactions extends StatelessWidget {
  final FirebaseUser user;

  RecurringTransactions(this.user);

  @override
  Widget build(BuildContext context) {
    final List<RecurringTransaction> _recurringTransactions =
        Provider.of<List<RecurringTransaction>>(context);
    Widget _body = Loader();

    if (_recurringTransactions != null) {
      if (_recurringTransactions.length == 0) {
        _body = Center(
          child: Text('Add a recurring transaction using the button below.'),
        );
      } else {
        _body = Container(
          padding: bodyPadding,
          child: ListView.builder(
            itemCount: _recurringTransactions.length,
            itemBuilder: (context, index) => recurringTransactionCard(
                context, _recurringTransactions[index]),
          ),
        );
      }
    }

    return Scaffold(
      drawer: MainDrawer(user),
      appBar: AppBar(title: Text('Recurring Transactions')),
      body: _body,
      floatingActionButton: addFloatingButton(
        context,
        StreamProvider<List<Category>>(
          create: (_) => DatabaseWrapper(user.uid).getCategories(),
          child: RecurringTransactionForm(RecurringTransaction.empty()),
        ),
        () {},
      ),
    );
  }

  Widget recurringTransactionCard(
    BuildContext context,
    RecurringTransaction recurringTransaction,
  ) {
    return Card(
      color: recurringTransaction.isExpense ? Colors.red[50] : Colors.green[50],
      child: ListTile(
        onTap: () => showDialog(
          context: context,
          builder: (context) => StreamProvider<List<Category>>(
            create: (_) => DatabaseWrapper(user.uid).getCategories(),
            child: RecurringTransactionForm(recurringTransaction),
          ),
        ),
        title: Text(
            '${recurringTransaction.payee}: ${recurringTransaction.isExpense ? '-' : '+'}\$${recurringTransaction.amount.toStringAsFixed(2)}'),
        subtitle: Text(
          'Every ${recurringTransaction.frequencyValue} ${recurringTransaction.frequencyUnit.toString().split('.')[1]}',
        ),
        trailing:
            Text('Next Date: ${getDateStr(recurringTransaction.nextDate)}'),
      ),
    );
  }
}
