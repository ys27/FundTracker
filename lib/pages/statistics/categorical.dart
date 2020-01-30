import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';

class Categorical extends StatefulWidget {
  final List<Transaction> transactions;

  Categorical(this.transactions);

  @override
  _CategoricalState createState() => _CategoricalState();
}

class _CategoricalState extends State<Categorical> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _individualPercentages =
        getIndividualPercentages(
      getTotalValues(
        divideTransactionsIntoCategories(widget.transactions),
      ),
    );

    return Column(
      children: <Widget>[
            Text(
              'Categories',
              style: TextStyle(fontSize: 20.0),
            ),
          ] +
          _individualPercentages
              .map((categorical) => [
                    SizedBox(height: 10.0),
                    BarTile(
                      title: categorical['category'],
                      amount: categorical['amount'],
                      percentage: categorical['percentage'],
                      color: categoriesRegistry.firstWhere((category) =>
                          category['name'] == categorical['category'])['color'],
                    ),
                  ])
              .expand((x) => x)
              .toList(),
    );
  }
}
