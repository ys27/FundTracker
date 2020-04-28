import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/shared/library.dart';

// expenses per period
// income per period
// averages of those
// averages per category per period
class Periodic extends StatelessWidget {
  final List<Map<String, dynamic>> dividedTransactions;

  Periodic({this.dividedTransactions});

  @override
  Widget build(BuildContext context) {
    if (dividedTransactions.length > 0) {
      List<Map<String, double>> amountPerPeriod = [];
      List<BarChartGroupData> groupData = dividedTransactions
          .asMap()
          .map((index, period) {
            double periodIncome = filterAndGetTotalAmounts(
              period['transactions'],
              filterOnlyExpenses: false,
            );
            double periodExpenses = filterAndGetTotalAmounts(
              period['transactions'],
              filterOnlyExpenses: true,
            );
            amountPerPeriod.add({
              'income': periodIncome,
              'expenses': periodExpenses,
            });
            return MapEntry(
              index,
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    y: periodIncome,
                    color: Colors.green,
                  ),
                  BarChartRodData(
                    y: periodExpenses,
                    color: Colors.red,
                  ),
                ],
              ),
            );
          })
          .values
          .toList();

      return Column(
        children: <Widget>[
          StatTitle(title: 'Periodic'),
          SizedBox(height: 20.0),
          BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: groupData,
              titlesData: FlTitlesData(
                show: true,
                leftTitles: SideTitles(
                  showTitles: true,
                  margin: 8,
                  getTitles: (value) {
                    if (value % 500 == 0) {
                      int per500 = value ~/ 500;
                      if (per500 == 0) {
                        return '\$0';
                      } else {
                        String grand =
                            (per500 % 2 == 0 ? per500 ~/ 2 : per500 / 2)
                                .toString();
                        return '\$${grand}K';
                      }
                    }
                    return '';
                  },
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                  getTitles: (index) =>
                      index == dividedTransactions.length - 1 ? 'Current' : '',
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Center(child: () {
            double averageIncome = getAverage(
                amountPerPeriod.map((period) => period['income']).toList());
            double averageExpenses = getAverage(
                amountPerPeriod.map((period) => period['expenses']).toList());
            return RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(text: 'Average: '),
                  TextSpan(
                      text: getAmountStr(averageIncome),
                      style: new TextStyle(color: Colors.green)),
                  TextSpan(text: ' / '),
                  TextSpan(
                      text: getAmountStr(averageExpenses),
                      style: new TextStyle(color: Colors.red)),
                ],
              ),
            );
          }()),
        ],
      );
    }
    return Loader();
  }
}
