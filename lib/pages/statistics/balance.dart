import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';

class Balance extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Transaction> prevTransactions;
  final bool showPeriodStats;
  final int daysLeft;

  Balance(this.transactions, this.prevTransactions, this.showPeriodStats,
      this.daysLeft);

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> balancesList = [
      {
        'amount': widget.transactions
            .where((tx) => !tx.isExpense)
            .fold(0.0, (a, b) => a + b.amount),
      },
      {
        'amount': widget.transactions
            .where((tx) => tx.isExpense)
            .fold(0.0, (a, b) => a + b.amount),
      },
    ];
    final List<Map<String, dynamic>> prevBalancesList = [
      {
        'amount': widget.prevTransactions
            .where((tx) => !tx.isExpense)
            .fold(0.0, (a, b) => a + b.amount),
      },
      {
        'amount': widget.prevTransactions
            .where((tx) => tx.isExpense)
            .fold(0.0, (a, b) => a + b.amount),
      },
    ];
    final double balance =
        balancesList[0]['amount'] - balancesList[1]['amount'];
    final double prevBalance =
        prevBalancesList[0]['amount'] - prevBalancesList[1]['amount'];

    final List<Map<String, dynamic>> relativePercentages =
        getRelativePercentages(balancesList);

    return Column(
      children: <Widget>[
        statTitle(
          title: 'Balance',
          alignment: MainAxisAlignment.spaceBetween,
          appendWidget: widget.showPeriodStats
              ? Text(
                  getPrevStr(balance, prevBalance),
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
              : null,
        ),
        Center(
          child: Text(
            getAmountStr(balance),
            style: TextStyle(fontSize: 25.0),
          ),
        ),
        widget.showPeriodStats
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[Text('${widget.daysLeft} days remaining')],
              )
            : SizedBox(height: 23.0),
        SizedBox(height: 10.0),
        BarTile(
          title: 'Income',
          amount: balancesList[0]['amount'],
          midLine: widget.showPeriodStats
              ? getPrevStr(
                  balancesList[0]['amount'], prevBalancesList[0]['amount'])
              : null,
          percentage: relativePercentages[0]['percentage'],
          color: Colors.green[800],
        ),
        BarTile(
          title: 'Expenses',
          amount: balancesList[1]['amount'],
          midLine: widget.showPeriodStats
              ? getPrevStr(
                  balancesList[1]['amount'], prevBalancesList[1]['amount'])
              : null,
          percentage: relativePercentages[1]['percentage'],
          color: Colors.red[800],
        ),
      ],
    );
  }
}

String getPrevStr(double current, double previous) {
  double percentage = 100 * current / previous;
  if (percentage.isNaN) {
    return 'No available data this period';
  }
  String percentageStr = percentage < 0
      ? percentage.toStringAsFixed(2)
      : '+${percentage.toStringAsFixed(2)}';
  return '$percentageStr% (vs prev. ${getAmountStr(previous)})';
}
