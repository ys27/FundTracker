import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/barTile.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';

class Balance extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Transaction> prevTransactions;
  final bool showPeriodStats;
  final int daysLeft;

  Balance(this.transactions, this.prevTransactions, this.showPeriodStats,
      this.daysLeft);

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  @override
  Widget build(BuildContext context) {
    final Map<String, double> balancesList = {
      'income': filterAndGetTotalAmounts(
        widget.transactions,
        filterOnlyExpenses: false,
      ),
      'expenses': filterAndGetTotalAmounts(
        widget.transactions,
        filterOnlyExpenses: true,
      ),
    };
    final Map<String, double> prevBalancesList = {
      'income': filterAndGetTotalAmounts(
        widget.prevTransactions,
        filterOnlyExpenses: false,
      ),
      'expenses': filterAndGetTotalAmounts(
        widget.prevTransactions,
        filterOnlyExpenses: true,
      ),
    };
    final double balance = balancesList['income'] - balancesList['expenses'];
    final double prevBalance =
        prevBalancesList['income'] - prevBalancesList['expenses'];

    final Map<String, dynamic> relativePercentages =
        getRelativePercentages(balancesList);

    return Column(
      children: <Widget>[
        statTitle(
          title: 'Balance',
          alignment: MainAxisAlignment.spaceBetween,
          appendWidget: widget.showPeriodStats
              ? Text(
                  getPrevStr(balance, prevBalance),
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
              : null,
        ),
        Center(
          child: Text(
            getAmountStr(balance),
            style: TextStyle(fontSize: 25.0),
          ),
        ),
        widget.showPeriodStats
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[Text('${widget.daysLeft} days remaining')],
              )
            : SizedBox(height: 23.0),
        SizedBox(height: 10.0),
        BarTile(
          title: 'Income',
          amount: balancesList['income'],
          midLine: widget.showPeriodStats
              ? getPrevStr(balancesList['income'], prevBalancesList['income'])
              : null,
          percentage: relativePercentages['income'],
          color: Colors.green[800],
        ),
        BarTile(
          title: 'Expenses',
          amount: balancesList['expenses'],
          midLine: widget.showPeriodStats
              ? getPrevStr(
                  balancesList['expenses'], prevBalancesList['expenses'])
              : null,
          percentage: relativePercentages['expenses'],
          color: Colors.red[800],
        ),
      ],
    );
  }
}

String getPrevStr(double current, double previous) {
  double percentage = 100 * current / previous;
  if (percentage.isNaN) {
    return 'No available data this period';
  }
  String percentageStr = percentage < 0
      ? percentage.toStringAsFixed(2)
      : '+${percentage.toStringAsFixed(2)}';
  return '$percentageStr% (vs prev. ${getAmountStr(previous)})';
}
