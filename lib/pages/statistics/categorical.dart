import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/indicator.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';

class Categorical extends StatefulWidget {
  final List<Transaction> transactions;

  Categorical(this.transactions);

  @override
  _CategoricalState createState() => _CategoricalState();
}

class _CategoricalState extends State<Categorical> {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _categoricalData;
    List<PieChartSectionData> sectionData;

    if (widget.transactions.length > 0) {
      final List<Map<String, dynamic>> _transactionsInCategories =
          divideTransactionsIntoCategories(widget.transactions);
      final List<Map<String, dynamic>> _categoriesWithTotalAmounts =
          appendTotalCategorialAmounts(_transactionsInCategories);
      final List<Map<String, dynamic>> _categoriesWithPercentages =
          appendIndividualPercentages(_categoriesWithTotalAmounts);
      _categoricalData = combineSmallPercentages(_categoriesWithPercentages);
      _categoricalData
          .sort((a, b) => b['percentage'].compareTo(a['percentage']));

      sectionData = _categoricalData
          .asMap()
          .map((index, category) {
            return MapEntry(
              index,
              PieChartSectionData(
                value: category['percentage'] * 100,
                color: category['color']
                    .withOpacity(touchedIndex == index ? 1.0 : 0.7),
                radius: 145,
                title: '\$${category['amount'].toStringAsFixed(2)}',
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                titlePositionPercentageOffset: 0.8,
              ),
            );
          })
          .values
          .toList();
    }

    return Column(
      children: <Widget>[
            statTitle('Categories'),
          ] +
          ((widget.transactions.length > 0)
              ? <Widget>[
                  SizedBox(height: 20.0),
                  PieChart(
                    PieChartData(
                      sections: sectionData,
                      sectionsSpace: 1,
                      borderData: FlBorderData(
                        show: false,
                      ),
                      pieTouchData: PieTouchData(
                        touchCallback: (pieTouchResponse) => setState(() {
                          touchedIndex =
                              (pieTouchResponse.touchInput is FlLongPressEnd ||
                                      pieTouchResponse.touchInput is FlPanEnd)
                                  ? touchedIndex
                                  : pieTouchResponse.touchedSectionIndex;
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _categoricalData
                        .asMap()
                        .map(
                          (index, category) => MapEntry(
                            index,
                            Indicator(
                              color: category['color'],
                              text:
                                  '${category['category']} - ${(category['percentage'] * 100).toStringAsFixed(0)}%',
                              isSquare: false,
                              size: touchedIndex == index ? 18 : 16,
                              textColor: touchedIndex == index
                                  ? Colors.black
                                  : Colors.grey,
                              handleTap: () =>
                                  setState(() => touchedIndex = index),
                            ),
                          ),
                        )
                        .values
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
