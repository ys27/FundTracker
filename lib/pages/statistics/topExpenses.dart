import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/shared.dart';

class TopExpenses extends StatefulWidget {
  final List<Transaction> transactions;
  final ScrollController scrollController;

  TopExpenses(this.transactions, this.scrollController);

  @override
  _TopExpensesState createState() => _TopExpensesState();
}

class _TopExpensesState extends State<TopExpenses> {
  int _showCount = 5;
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
              .sublist(0, min(_showCount, _sortedTransactions.length))
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
              .toList() +
          <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  child: Text('Collapse'),
                  onPressed: () => setState(() => _showCount = 5),
                ),
                // FlatButton(
                //   child: Text('Show less...'),
                //   onPressed: () => setState(() => _showCount -= 5),
                // ),
                FlatButton(
                  child: Text('Show more'),
                  onPressed: () {
                    setState(() => _showCount += 5);
                    widget.scrollController.animateTo(
                      99999,
                      duration: Duration(seconds: 3),
                      curve: Curves.easeInOutQuint,
                    );
                  },
                )
              ],
            )
          ],
    );
  }
}

List<Transaction> sortByAmountDescending(List<Transaction> transactions) {
  transactions.sort((a, b) => b.amount.compareTo(a.amount));
  return transactions;
}
