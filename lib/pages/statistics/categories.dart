import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/indicator.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/components.dart';

class Categories extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final Preferences prefs;

  Categories({this.transactions, this.categories, this.prefs});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int touchedIndex = -1;
  bool onlyExpenses;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _categoricalData;
    List<PieChartSectionData> sectionData = [];

    onlyExpenses = onlyExpenses ?? widget.prefs.isOnlyExpenses;

    final List<Transaction> txExpenses =
        widget.transactions.where((tx) => tx.isExpense).toList();

    if (widget.transactions.length > 0) {
      final List<Map<String, dynamic>> _transactionsInCategories = onlyExpenses
          ? divideTransactionsIntoCategories(txExpenses, widget.categories)
          : divideTransactionsIntoCategories(
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
                title: category['percentage'] > 0.04
                    ? String.fromCharCode(category['icon'])
                    : '',
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontFamily: 'MaterialDesignIconFont',
                  package: 'community_material_icon',
                ),
                titlePositionPercentageOffset: 0.7,
              ),
            );
          })
          .values
          .toList();
    }

    return Column(children: <Widget>[
      StatTitle(title: 'Categories'),
      if (sectionData.length > 0) ...[
        SizedBox(height: 10.0),
        SwitchListTile(
          title: Text('Only expenses'),
          value: onlyExpenses,
          onChanged: (val) {
            setState(() => onlyExpenses = val);
          },
        ),
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
                touchedIndex = (pieTouchResponse.touchInput is FlLongPressEnd ||
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
                        '${category['name']} - \$${category['amount'].toStringAsFixed(2)} (${(category['percentage'] * 100).toStringAsFixed(0)}%)',
                    isSquare: false,
                    size: touchedIndex == index ? 18 : 16,
                    textColor:
                        touchedIndex == index ? Colors.black : Colors.grey,
                    handleTap: () => setState(() => touchedIndex = index),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ] else ...[
        SizedBox(height: 35.0),
        Center(
          child: Text(
              'No ${onlyExpenses ? 'expenses' : 'negative balance'} in current period.'),
        ),
      ]
    ]);
  }
}
