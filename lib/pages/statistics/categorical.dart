import 'package:charts_flutter/flutter.dart';
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
    List<Map<String, dynamic>> _categoricalData;
    List<Series<Map<String, dynamic>, dynamic>> seriesList;

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

      seriesList = [
        Series(
          id: 'Categories',
          domainFn: (Map<String, dynamic> category, _) => category['category'],
          measureFn: (Map<String, dynamic> category, _) => category['amount'],
          colorFn: (Map<String, dynamic> category, _) =>
              ColorUtil.fromDartColor(categoriesRegistry.singleWhere(
                  (registry) => registry['name'] == category['category'],
                  orElse: () => {
                        'color': Colors.black54,
                      })['color']),
          data: _categoricalData,
          labelAccessorFn: (Map<String, dynamic> category, _) =>
              '\$${category['amount'].toStringAsFixed(2)}',
        )
      ];
    }

    return Column(
      children: <Widget>[
            statTitle('Categories'),
          ] +
          ((transactions.length > 0)
              ? <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.width - 100,
                    child: PieChart(
                      seriesList,
                      animate: true,
                      defaultRenderer: ArcRendererConfig(
                        arcRendererDecorators: [
                          ArcLabelDecorator(
                            labelPosition: ArcLabelPosition.outside,
                          )
                        ],
                      ),
                      behaviors: [
                        DatumLegend(
                          position: BehaviorPosition.bottom,
                          desiredMaxColumns: 2,
                        )
                      ],
                    ),
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
