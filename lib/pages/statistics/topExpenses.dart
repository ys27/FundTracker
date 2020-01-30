import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/shared.dart';

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
      children: <Widget>[StatTitle(title: 'Top Expenses')] +
          _sortedTransactions
              .sublist(0, 5)
              .map((tx) => [
                    SizedBox(height: 10.0),
                    BarTile(
                      title: tx['payee'],
                      subtitle: tx['category'],
                      amount: tx['amount'],
                      percentage: tx['percentage'],
                      color: categoriesRegistry.firstWhere((category) =>
                          category['name'] == tx['category'])['color'],
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
