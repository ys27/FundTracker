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
        : '\$${formatAmount(balance / daysLeft)} / day';

    return Column(
      children: <Widget>[
        StatTitle(title: 'Balance'),
        Center(
          child: Text(getAmountStr(balance), style: TextStyle(fontSize: 25.0)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('$daysLeft day(s) left in period'),
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