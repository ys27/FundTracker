import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:random_color/random_color.dart';

class TopExpenses extends StatefulWidget {
  final List<Transaction> transactions;

  TopExpenses(this.transactions);

  @override
  _TopExpensesState createState() => _TopExpensesState();
}

class _TopExpensesState extends State<TopExpenses> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _sortedTransactions =
        getRelativePercentages(sortByAmountDescending(widget.transactions)
            .map((tx) => {
                  'payee': tx.payee,
                  'category': tx.category,
                  'amount': tx.amount,
                })
            .toList());
    return Column(
      children: <Widget>[
            Text(
              'Top Expenses',
              style: TextStyle(fontSize: 20.0),
            ),
          ] +
          _sortedTransactions
              .sublist(0, 5)
              .map((tx) => [
                    SizedBox(height: 10.0),
                    BarTile(
                      title: tx['payee'],
                      subtitle: tx['category'],
                      amount: tx['amount'],
                      percentage: tx['percentage'],
                      color: RandomColor()
                          .randomColor(colorSaturation: ColorSaturation.random),
                    ),
                  ])
              .expand((x) => x)
              .toList(),
    );
  }
}

List<Transaction> sortByAmountDescending(List<Transaction> transactions) {
  transactions.sort((a, b) => b.amount.compareTo(a.amount));
  return transactions;
}
