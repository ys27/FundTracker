import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/components.dart';

class Balance extends StatelessWidget {
  final List<Transaction> transactions;
  final bool showPeriodStats;
  final int daysLeft;

  Balance({this.transactions, this.showPeriodStats, this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> balancesList = {
      'income': filterAndGetTotalAmounts(
        transactions,
        filterOnlyExpenses: false,
      ),
      'expenses': filterAndGetTotalAmounts(
        transactions,
        filterOnlyExpenses: true,
      ),
    };
    final double balance = balancesList['income'] - balancesList['expenses'];
    final Map<String, dynamic> relativePercentages =
        getRelativePercentages(balancesList);
    final String remainingPerDay = balance <= 0
        ? 'No remaining balance'
        : '\$${(balance / daysLeft).toStringAsFixed(2)} / day';

    return Column(
      children: <Widget>[
        StatTitle(title: 'Balance'),
        Center(
          child: Text(getAmountStr(balance), style: TextStyle(fontSize: 25.0)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('$daysLeft day(s) until next period'),
            Text(remainingPerDay),
          ],
        ),
        SizedBox(height: 10.0),
        BarTile(
          title: 'Income',
          amount: balancesList['income'],
          percentage: relativePercentages['income'],
          color: Colors.green[800],
        ),
        BarTile(
          title: 'Expenses',
          amount: balancesList['expenses'],
          percentage: relativePercentages['expenses'],
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
