import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/statistics/indicator.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';

class Categorical extends StatelessWidget {
  final List<Transaction> transactions;

  Categorical(this.transactions);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _categoricalData;
    List<PieChartSectionData> sectionData;

    if (transactions.length > 0) {
      final List<Map<String, dynamic>> _transactionsInCategories =
          divideTransactionsIntoCategories(transactions);
      final List<Map<String, dynamic>> _categoriesWithTotalAmounts =
          appendTotalCategorialAmounts(_transactionsInCategories);
      final List<Map<String, dynamic>> _categoriesWithPercentages =
          getIndividualPercentages(_categoriesWithTotalAmounts);
      _categoricalData = combineSmallPercentages(_categoriesWithPercentages);
      // _categoricalData
      //     .sort((a, b) => b['percentage'].compareTo(a['percentage']));

      sectionData = _categoricalData
          .map(
            (category) => PieChartSectionData(
              value: category['percentage'] * 100,
              color: category['color'],
              radius: 145,
              title: '\$${category['amount'].toStringAsFixed(2)}',
              titleStyle: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              titlePositionPercentageOffset: 0.8,
            ),
          )
          .toList();
    }

    return Column(
      children: <Widget>[
            statTitle('Categories'),
          ] +
          ((transactions.length > 0)
              ? <Widget>[
                  PieChart(
                    PieChartData(
                      sections: sectionData,
                      sectionsSpace: 1,
                      borderData: FlBorderData(
                        show: false,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _categoricalData
                        .map(
                          (category) => Indicator(
                            color: category['color'],
                            text: category['category'],
                            isSquare: false,
                            size: 16,
                            textColor: Colors.grey,
                          ),
                        )
                        .toList(),
                  ),
                ]
              : <Widget>[
                  SizedBox(height: 35.0),
                  Center(
                    child: Text('No transactions found in current period.'),
                  )
                ]),
    );
  }
}
