import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/shared/config.dart';
import 'package:fund_tracker/shared/library.dart';

class Periodic extends StatefulWidget {
  final List<Map<String, dynamic>> dividedTransactions;

  Periodic({this.dividedTransactions});

  @override
  _PeriodicState createState() => _PeriodicState();
}

class _PeriodicState extends State<Periodic> {
  int touchedGroupIndex;
  List<Map<String, dynamic>> _nonEmptyPeriods;

  @override
  void initState() {
    super.initState();
    _nonEmptyPeriods = widget.dividedTransactions
        .where((period) => period['transactions'].length > 0)
        .take(NUM_PERIODIC_STAT_PERIODS)
        .toList()
        .reversed
        .toList();
    touchedGroupIndex = _nonEmptyPeriods.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    if (_nonEmptyPeriods != null) {
      List<Map<String, double>> amountPerPeriod = [];
      List<BarChartGroupData> groupData = _nonEmptyPeriods
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
            double rodWidth = 16;
            return MapEntry(
              index,
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    y: periodIncome,
                    width: rodWidth,
                    colors: [Colors.green],
                  ),
                  BarChartRodData(
                    y: periodExpenses,
                    width: rodWidth,
                    colors: [Colors.red],
                  ),
                ],
              ),
            );
          })
          .values
          .toList();

      double maxAmount = amountPerPeriod.fold(0, (runningMax, current) {
        double bigger = max(current['expenses'], current['income']);
        return bigger > runningMax ? bigger : runningMax;
      });

      return Column(
        children: <Widget>[
          StatTitle(title: 'Periodic'),
          SizedBox(height: 20.0),
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
          SizedBox(height: 10.0),
          AspectRatio(
            aspectRatio: 1.3,
            child: AspectRatio(
              aspectRatio: 1,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: groupData,
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: SideTitles(
                      showTitles: true,
                      margin: 8,
                      getTitles: (value) {
                        // print(value);
                        int numSideTitles = 8;
                        double increment = maxAmount / numSideTitles;
                        int closestPrettyIncrement =
                            ((increment + 250) ~/ 500) * 500.toInt();
                        if (value % closestPrettyIncrement == 0) {
                          if (value == 0) {
                            return '\$0';
                          } else {
                            return '\$${value ~/ 1000}K';
                          }
                        }
                        return '';
                      },
                      getTextStyles: (context, val) =>
                          TextStyle(fontSize: 10.0),
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (index) =>
                          index == _nonEmptyPeriods.length - 1 ? 'Current' : '',
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (_, __, rodData, rodIndex) {
                        return BarTooltipItem(
                          getAmountStr(rodData.y),
                          TextStyle(
                            color: rodData.colors[0],
                          ),
                        );
                      },
                    ),
                    touchExtraThreshold: EdgeInsets.symmetric(horizontal: 8),
                    touchCallback: (response) {
                      if (response.spot != null) {
                        setState(() {
                          touchedGroupIndex =
                              response.spot.touchedBarGroupIndex;
                        });
                      }
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                ),
              ),
            ),
          ),
          if (touchedGroupIndex > -1) ...[
            SizedBox(height: 10.0),
            Center(
              child: Text(
                'Selected period',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(() {
                String startDate = getDateStr(
                    _nonEmptyPeriods[touchedGroupIndex]['startDate']);
                String endDate =
                    getDateStr(_nonEmptyPeriods[touchedGroupIndex]['endDate']);
                return '$startDate - $endDate';
              }()),
            ),
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Income: '),
                    TextSpan(
                        text: getAmountStr(
                            amountPerPeriod[touchedGroupIndex]['income']),
                        style: new TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ),
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Expenses: '),
                    TextSpan(
                        text: getAmountStr(
                            amountPerPeriod[touchedGroupIndex]['expenses']),
                        style: new TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    }
    return Loader();
  }
}
