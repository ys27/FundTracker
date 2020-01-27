import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionTile.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TransactionsList extends StatefulWidget {
  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  List<Map<String, dynamic>> _dividedTransactions = [];

  @override
  Widget build(BuildContext context) {
    List<Transaction> _transactions = Provider.of<List<Transaction>>(context);
    final Period _currentPeriod = Provider.of<Period>(context);
    final Preferences _prefs = Provider.of<Preferences>(context);

    if (_transactions != null &&
        _transactions.length > 0 &&
        _currentPeriod != null &&
        _prefs != null) {
      _dividedTransactions =
          filterTransactionsByLimit(_transactions, _prefs, _currentPeriod);
    }

    if (_transactions == null) {
      return Loader();
    } else if (_transactions.length == 0) {
      return Center(
        child:
            Text('No transactions available. Add one using the button below.'),
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          Map<String, dynamic> periodMap = _dividedTransactions[index];
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Colors.grey,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                _currentPeriod.name == 'Default Monthly'
                    ? '${Months[periodMap['startDate'].month.toString()]} ${periodMap['startDate'].year}'
                    : '${getDate(periodMap['startDate'])} - ${getDate(periodMap['endDate'])}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            content: Column(
              children: periodMap['transactions']
                  .map<Widget>(
                    (tx) => TransactionTile(transaction: tx),
                  )
                  .toList(),
            ),
          );
        },
        itemCount: _dividedTransactions.length,
      );
    }
  }
}

List<Map<String, dynamic>> divideTransactionsIntoPeriods(
    List<Transaction> transactions, Period period) {
  List<Map<String, dynamic>> periodsList = [];

  DateTime iteratingPeriodStartDate =
      findFirstPeriodDate(transactions.last, period);

  while (iteratingPeriodStartDate.isBefore(transactions.first.date)) {
    int numDaysInPeriod =
        findNumDaysInPeriod(period.setStartDate(iteratingPeriodStartDate));
    DateTime iteratingNextPeriodStartDate =
        iteratingPeriodStartDate.add(Duration(days: numDaysInPeriod));
    iteratingNextPeriodStartDate = DateTime.utc(
      iteratingNextPeriodStartDate.year,
      iteratingNextPeriodStartDate.month,
      iteratingNextPeriodStartDate.day,
    );

    periodsList.insert(
      0,
      {
        'startDate': iteratingPeriodStartDate,
        'endDate':
            iteratingNextPeriodStartDate.subtract(Duration(microseconds: 1)),
        'transactions': transactions
            .where((tx) =>
                tx.date.isAfter(iteratingPeriodStartDate) &&
                tx.date.isBefore(iteratingNextPeriodStartDate))
            .toList(),
      },
    );

    iteratingPeriodStartDate = iteratingNextPeriodStartDate;
  }
  return periodsList;
}

List<Map<String, dynamic>> filterTransactionsByLimit(
    List<Transaction> transactions, Preferences prefs, Period currentPeriod) {
  if (prefs.isLimitDaysEnabled) {
    transactions = transactions
        .where((tx) => tx.date
            .isAfter(DateTime.now().subtract(Duration(days: prefs.limitDays))))
        .toList();
  } else if (prefs.isLimitByDateEnabled) {
    transactions =
        transactions.where((tx) => tx.date.isAfter(prefs.limitByDate)).toList();
  }
  List<Map<String, dynamic>> dividedTransactions =
      divideTransactionsIntoPeriods(transactions, currentPeriod);

  if (prefs.isLimitPeriodsEnabled) {
    DateTime now = DateTime.now();
    int currentDatePeriodIndex = dividedTransactions.indexWhere(
        (map) => map['startDate'].isBefore(now) && map['endDate'].isAfter(now));
    dividedTransactions = dividedTransactions.sublist(
        0, currentDatePeriodIndex + prefs.limitPeriods);
  }

  return dividedTransactions;
}
