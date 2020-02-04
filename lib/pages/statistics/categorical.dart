import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';

class Categorical extends StatelessWidget {
  final List<Transaction> transactions;

  Categorical(this.transactions);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _individualPercentages;

    if (transactions.length > 0) {
      _individualPercentages = getIndividualPercentages(
        appendTotalCategorialAmounts(
          divideTransactionsIntoCategories(transactions),
        ),
      );
      _individualPercentages
          .sort((a, b) => b['percentage'].compareTo(a['percentage']));
    }

    return Column(
      children: <Widget>[statTitle('Categories')] +
          ((transactions.length > 0)
              ? _individualPercentages
                  .map((categorical) => [
                        SizedBox(height: 10.0),
                        BarTile(
                          title: categorical['category'],
                          amount: categorical['amount'],
                          percentage: categorical['percentage'],
                          color: categoriesRegistry.singleWhere((category) =>
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
