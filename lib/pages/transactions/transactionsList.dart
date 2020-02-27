import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionTile.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final Period currentPeriod;
  final Preferences prefs;
  final Function callback;

  TransactionsList(
    this.transactions,
    this.currentPeriod,
    this.prefs,
    this.callback,
  );

  @override
  Widget build(BuildContext context) {
    if (transactions == null || currentPeriod == null || prefs == null) {
      return Loader();
    }
    if (transactions.length == 0) {
      return Center(
        child: Text('Add a transaction using the button below.'),
      );
    } else {
      List<Map<String, dynamic>> _dividedTransactions =
          filterByLimitAndDivideIntoPeriods(
        transactions,
        prefs,
        currentPeriod,
      );

      return ListView.builder(
        itemBuilder: (context, index) {
          Map<String, dynamic> period = _dividedTransactions[index];
          return StickyHeader(
            header: transactionsPeriodHeader(
              currentPeriod.name == 'Default Monthly',
              period['startDate'],
              period['endDate'],
              period['transactions'],
            ),
            content: Column(
              children: period['transactions']
                  .map<Widget>((tx) => TransactionTile(tx, callback))
                  .toList(),
            ),
          );
        },
        itemCount: _dividedTransactions.length,
      );
    }
  }

  Widget transactionsPeriodHeader(
    bool isDefault,
    DateTime startDate,
    DateTime endDate,
    List<Transaction> transactions,
  ) {
    return Container(
      height: 50.0,
      color: Colors.grey,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            isDefault
                ? '${Months[startDate.month.toString()]} ${startDate.year}'
                : '${getDateStr(startDate)} - ${getDateStr(endDate)}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '\u2211 ${transactions.fold(0.0, (a, b) => a + (b.isExpense ? -1 * b.amount : b.amount)).toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
