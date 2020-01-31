import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';

class Categorical extends StatefulWidget {
  final List<Transaction> transactions;

  Categorical(this.transactions);

  @override
  _CategoricalState createState() => _CategoricalState();
}

class _CategoricalState extends State<Categorical> {
  List<Map<String, dynamic>> _individualPercentages;
  @override
  Widget build(BuildContext context) {
    if (widget.transactions.length > 0) {
      _individualPercentages = getIndividualPercentages(
        getTotalValues(
          divideTransactionsIntoCategories(widget.transactions),
        ),
      );
    }

    return Column(
      children: <Widget>[StatTitle(title: 'Categories')] +
          ((widget.transactions.length > 0)
              ? _individualPercentages
                  .map((categorical) => [
                        SizedBox(height: 10.0),
                        BarTile(
                          title: categorical['category'],
                          amount: categorical['amount'],
                          percentage: categorical['percentage'],
                          color: categoriesRegistry.firstWhere((category) =>
                              category['name'] ==
                              categorical['category'])['color'],
                        ),
                      ])
                  .expand((x) => x)
                  .toList()
              : <Widget>[
                  SizedBox(height: 35.0),
                  Center(
                    child: Text('No transactions found in current period.'),
                  )
                ]),
    );
  }
}