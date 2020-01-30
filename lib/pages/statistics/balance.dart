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
    final double balance =
        balancesList[0]['amount'] - balancesList[1]['amount'];
    final String balanceStr = balance < 0
        ? '-\$${abs(balance).toStringAsFixed(2)}'
        : '\$${balance.toStringAsFixed(2)}';
    final List<Map<String, dynamic>> relativePercentages =
        getRelativePercentages(balancesList);

    return Column(
      children: <Widget>[
        Text(
          'Balance: $balanceStr',
          style: TextStyle(fontSize: 20.0),
        ),
        SizedBox(height: 10.0),
        BarTile(
          title: 'Income',
          amount: balancesList[0]['amount'],
          percentage: relativePercentages[0]['percentage'],
          color: Colors.green[800],
        ),
        SizedBox(height: 10.0),
        BarTile(
          title: 'Expenses',
          amount: balancesList[1]['amount'],
          percentage: relativePercentages[1]['percentage'],
          color: Colors.red[800],
        ),
      ],
    );
  }
}
