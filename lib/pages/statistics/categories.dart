import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/indicator.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';

class Categories extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Category> categories;

  Categories(this.transactions, this.categories);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _categoricalData;
    List<PieChartSectionData> sectionData;

    if (widget.transactions.length > 0) {
      final List<Map<String, dynamic>> _transactionsInCategories =
          divideTransactionsIntoCategories(
              widget.transactions, widget.categories);
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
                color: category['iconColor'],
                radius: touchedIndex == index ? 145 : 140,
                title: '\$${category['amount'].toStringAsFixed(2)}',
                titleStyle: TextStyle(
                  color: category['percentage'] < 0.05 || touchedIndex == index
                      ? Colors.black
                      : Colors.white,
                  fontSize: 16,
                ),
                titlePositionPercentageOffset:
                    category['percentage'] < 0.05 || touchedIndex == index
                        ? 1.2
                        : (index % 2 == 0 ? 0.825 : 0.675),
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
                  SizedBox(height: 35.0),
                  PieChart(
                    PieChartData(
                      sections: sectionData,
                      sectionsSpace: 1,
                      borderData: FlBorderData(
                        show: false,
                      ),
                      pieTouchData: PieTouchData(
                        touchCallback: (pieTouchResponse) => setState(() {
                          touchedIndex = (pieTouchResponse.touchInput
                                      is FlLongPressEnd ||
                                  pieTouchResponse.touchInput is FlPanEnd ||
                                  pieTouchResponse.touchedSectionIndex == null)
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
                              color: category['iconColor'],
                              text:
                                  '${category['name']} - ${(category['percentage'] * 100).toStringAsFixed(0)}%',
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
                    child: Text('No expenses found in current period.'),
                  )
                ]),
    );
  }
}
