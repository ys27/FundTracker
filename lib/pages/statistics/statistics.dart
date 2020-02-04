import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/balance.dart';
import 'package:fund_tracker/pages/statistics/categorical.dart';
import 'package:fund_tracker/pages/statistics/topExpenses.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';

class Statistics extends StatefulWidget {
  final List<Transaction> allTransactions;
  final Period currentPeriod;
  final Preferences prefs;

  Statistics(this.allTransactions, this.currentPeriod, this.prefs);

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  bool _showAllTimeStats = false;
  bool _showPreferredStats = false;
  bool _showPeriodStats = true;

  String _visiblePrefs = '';

  Widget _body = Center(
    child: Text('No statistics available. Requires at least one transaction.'),
  );

  List<Transaction> _transactions;
  List<Transaction> _prevTransactions = [];
  List<Map<String, dynamic>> _dividedTransactions = [];
  int _daysLeft;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (widget.allTransactions != null &&
        widget.currentPeriod != null &&
        widget.prefs != null &&
        widget.allTransactions.length > 0) {
      _dividedTransactions = divideTransactionsIntoPeriods(
          widget.allTransactions, widget.currentPeriod);

      if (widget.prefs.isLimitDaysEnabled) {
        _visiblePrefs = '${widget.prefs.limitDays} days';
      } else if (widget.prefs.isLimitPeriodsEnabled) {
        _visiblePrefs = '${widget.prefs.limitPeriods} periods';
      } else if (widget.prefs.isLimitByDateEnabled) {
        _visiblePrefs = '~ ${getDateStr(widget.prefs.limitByDate)}';
      }

      if (_showAllTimeStats) {
        _transactions = widget.allTransactions;
      }

      if (_showPreferredStats) {
        if (widget.allTransactions.length > 0 &&
                widget.prefs.isLimitDaysEnabled ||
            widget.prefs.isLimitByDateEnabled) {
          _transactions =
              filterTransactionsByLimit(widget.allTransactions, widget.prefs);
        } else {
          _transactions = filterPeriodsWithLimit(
                  _dividedTransactions, widget.prefs.limitPeriods)
              .map<List<Transaction>>((map) => map['transactions'])
              .expand((x) => x)
              .toList();
        }
      }

      if (_showPeriodStats) {
        List<Map<String, dynamic>> _periodFilteredTransactions =
            findCurrentAndPreviousPeriods(_dividedTransactions);
        _daysLeft = _periodFilteredTransactions.length > 0
            ? _periodFilteredTransactions[0]['endDate']
                .difference(DateTime.now())
                .inDays
            : 0;
        _transactions = _periodFilteredTransactions.length > 0
            ? _periodFilteredTransactions[0]['transactions']
            : [];
        _prevTransactions = _periodFilteredTransactions.length > 1
            ? _periodFilteredTransactions[1]['transactions']
            : [];
      }

      _body = ListView(
        controller: _scrollController,
        padding: bodyPadding,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.all(15.0),
                  color: _showAllTimeStats
                      ? Theme.of(context).primaryColor
                      : Colors.grey[100],
                  child: Text(
                    'All-Time',
                    style: TextStyle(
                        fontWeight: _showAllTimeStats
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _showAllTimeStats ? Colors.white : Colors.black),
                  ),
                  onPressed: () => setState(() {
                    _showAllTimeStats = true;
                    _showPreferredStats = false;
                    _showPeriodStats = false;
                  }),
                ),
              ),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.all(15.0),
                  color: _showPreferredStats
                      ? Theme.of(context).primaryColor
                      : Colors.grey[100],
                  child: Text(
                    _visiblePrefs,
                    style: TextStyle(
                        fontWeight: _showPreferredStats
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color:
                            _showPreferredStats ? Colors.white : Colors.black),
                  ),
                  onPressed: () => setState(() {
                    _showPreferredStats = true;
                    _showAllTimeStats = false;
                    _showPeriodStats = false;
                  }),
                ),
              ),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.all(15.0),
                  color: _showPeriodStats
                      ? Theme.of(context).primaryColor
                      : Colors.grey[100],
                  child: Text(
                    'Period',
                    style: TextStyle(
                        fontWeight: _showPeriodStats
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _showPeriodStats ? Colors.white : Colors.black),
                  ),
                  onPressed: () => setState(() {
                    _showPeriodStats = true;
                    _showAllTimeStats = false;
                    _showPreferredStats = false;
                  }),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Balance(
              _transactions, _prevTransactions, _showPeriodStats, _daysLeft),
          SizedBox(height: 20.0),
          Categorical(_transactions.where((tx) => tx.isExpense).toList()),
          SizedBox(height: 20.0),
          TopExpenses(
            _transactions.where((tx) => tx.isExpense).toList(),
            _transactions
                .where((tx) => !tx.isExpense)
                .fold(0.0, (a, b) => a + b.amount),
            _transactions
                .where((tx) => tx.isExpense)
                .fold(0.0, (a, b) => a + b.amount),
            _scrollController,
          ),
        ],
      );
    }

    return _body;
  }
}
