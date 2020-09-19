import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/components.dart';

class TopExpenses extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final ScrollController scrollController;

  TopExpenses({
    this.transactions,
    this.categories,
    this.scrollController,
  });

  @override
  _TopExpensesState createState() => _TopExpensesState();
}

class _TopExpensesState extends State<TopExpenses> {
  int _showCount = 5;
  List<Map<String, dynamic>> _sortedTransactions;
  List<Widget> _columnContent;

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.length > 0) {
      _sortedTransactions = sortByAmountDescending(widget.transactions)
          .map((tx) => {
                'payee': tx.payee,
                'cid': tx.cid,
                'amount': tx.amount,
              })
          .toList();
      _columnContent = <Widget>[
        ...sublist(_sortedTransactions, 0, _showCount)
            .map((tx) => <Widget>[
                  SizedBox(height: 10.0),
                  BarTile(
                    title: tx['payee'],
                    subtitle: getCategory(widget.categories, tx['cid']).name,
                    amount: tx['amount'],
                  ),
                ])
            .expand((x) => x)
            .toList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton(
              child: Text('Collapse'),
              onPressed: () => setState(() => _showCount = 5),
            ),
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
      ];
    } else {
      _columnContent = <Widget>[
        SizedBox(height: 35.0),
        Center(
          child: Text('No expenses found in current period.'),
        )
      ];
    }

    return Column(
      children: <Widget>[
        StatTitle(title: 'Top Expenses'),
        ..._columnContent,
      ],
    );
  }
}

List<Transaction> sortByAmountDescending(List<Transaction> transactions) {
  transactions.sort((a, b) => b.amount.compareTo(a.amount));
  return transactions;
}
