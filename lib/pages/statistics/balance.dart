import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';

class Balance extends StatefulWidget {
  final List<Transaction> transactions;

  Balance(this.transactions);

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  @override
  Widget build(BuildContext context) {
    final List<double> amounts = [
      widget.transactions
          .where((tx) => !tx.isExpense)
          .fold(0.0, (a, b) => a + b.amount),
      widget.transactions
          .where((tx) => tx.isExpense)
          .fold(0.0, (a, b) => a + b.amount),
    ];
    final double balance = amounts[0] - amounts[1];
    final String balanceStr = balance < 0
        ? '-\$${abs(balance).toStringAsFixed(2)}'
        : '\$${balance.toStringAsFixed(2)}';
    final List<double> relativePercentages = getRelativePercentages(amounts);

    return Column(
      children: <Widget>[
        Text(
          'Balance: $balanceStr',
          style: TextStyle(fontSize: 20.0),
        ),
        SizedBox(height: 10.0),
        BarTile(
          title: 'Income',
          amount: amounts[0],
          percentage: relativePercentages[0],
          color: Colors.green[800],
        ),
        SizedBox(height: 10.0),
        BarTile(
          title: 'Expenses',
          amount: amounts[1],
          percentage: relativePercentages[1],
          color: Colors.red[800],
        ),
      ],
    );
  }
}

List<double> getRelativePercentages(List<double> values) {
  double max = values.first;
  values.forEach((e) {
    if (e > max) max = e;
  });
  return values.map((v) => v / max).toList();
}
