import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:random_color/random_color.dart';

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
              .map((category) => [
                    SizedBox(height: 10.0),
                    BarTile(
                      title: category['category'],
                      amount: category['amount'],
                      percentage: category['percentage'],
                      color: RandomColor()
                          .randomColor(colorSaturation: ColorSaturation.random),
                    ),
                  ])
              .expand((x) => x)
              .toList(),
    );
  }
}

List<Map<String, dynamic>> getTotalValues(
    List<Map<String, dynamic>> dividedTransactions) {
  return dividedTransactions
      .map((map) => {
            'category': map['category'],
            'amount': map['transactions'].fold(0.0, (a, b) => a + b.amount),
          })
      .toList();
}

List<Map<String, dynamic>> getIndividualPercentages(
    List<Map<String, dynamic>> values) {
  double sum = values.first['amount'];
  values.forEach((e) {
    sum += e['amount'];
  });
  return values
      .map((v) => {
            ...v,
            'percentage': v['amount'] / sum,
          })
      .toList();
}
