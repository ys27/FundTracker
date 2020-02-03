import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionTile.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TransactionsList extends StatefulWidget {
  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  @override
  Widget build(BuildContext context) {
    final List<Transaction> _transactions =
        Provider.of<List<Transaction>>(context);
    final Period _currentPeriod = Provider.of<Period>(context);
    final Preferences _prefs = Provider.of<Preferences>(context);

    List<Map<String, dynamic>> _dividedTransactions = [];

    if (_transactions != null &&
        _transactions.length > 0 &&
        _currentPeriod != null &&
        _prefs != null) {
      List<Transaction> _filteredTransactions =
          filterTransactionsByLimit(_transactions, _prefs);
      _dividedTransactions =
          divideTransactionsIntoPeriods(_filteredTransactions, _currentPeriod);
      if (_prefs.isLimitPeriodsEnabled) {
        _dividedTransactions =
            filterTransactionsByPeriods(_dividedTransactions, _prefs);
      }
      // Remove periods without any txs
      _dividedTransactions = _dividedTransactions
          .where((period) => period['transactions'].length > 0)
          .toList();
    }

    if (_transactions == null) {
      return Loader();
    } else if (_transactions.length == 0) {
      return Center(
        child: Text('Add a transaction using the button below.'),
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          Map<String, dynamic> period = _dividedTransactions[index];
          return StickyHeader(
            header: transactionsPeriodHeader(
              _currentPeriod.name == 'Default Monthly',
              period['startDate'],
              period['endDate'],
            ),
            content: Column(
              children: period['transactions']
                  .map<Widget>((tx) => TransactionTile(transaction: tx))
                  .toList(),
            ),
          );
        },
        itemCount: _dividedTransactions.length,
      );
    }
  }

  Widget transactionsPeriodHeader(
      bool isDefault, DateTime startDate, DateTime endDate) {
    return Container(
      height: 50.0,
      color: Colors.grey,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        isDefault
            ? '${Months[startDate.month.toString()]} ${startDate.year}'
            : '${getDate(startDate)} - ${getDate(endDate)}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
