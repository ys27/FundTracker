import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
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
    final List<Transaction> _transactions =
        Provider.of<List<Transaction>>(context);
    final Period _currentPeriod = Provider.of<Period>(context);

    if (_transactions != null &&
        _transactions.length > 0 &&
        _currentPeriod != null) {
      _dividedTransactions =
          divideTransactionsIntoPeriods(_transactions, _currentPeriod);
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
          print(periodMap['startDate']);
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Theme.of(context).accentColor,
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
                    (tx) => TransactionTile(
                      transaction: tx,
                    ),
                  )
                  .toList(),
            ),
          );
        },
        itemCount: _dividedTransactions.length,
      );
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
          iteratingPeriodStartDate.add(new Duration(days: numDaysInPeriod));
      iteratingNextPeriodStartDate = DateTime.utc(
          iteratingNextPeriodStartDate.year,
          iteratingNextPeriodStartDate.month,
          iteratingNextPeriodStartDate.day);

      periodsList.insert(0, {
        'startDate': iteratingPeriodStartDate,
        'endDate': iteratingNextPeriodStartDate
            .subtract(new Duration(microseconds: 1)),
        'transactions': transactions
            .where((tx) =>
                tx.date.isAfter(iteratingPeriodStartDate) &&
                tx.date.isBefore(iteratingNextPeriodStartDate))
            .toList(),
      });

      iteratingPeriodStartDate = iteratingNextPeriodStartDate;
    }
    return periodsList;
  }
}
