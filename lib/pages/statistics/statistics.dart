import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/balance.dart';
import 'package:fund_tracker/pages/statistics/categorical.dart';
import 'package:fund_tracker/pages/statistics/topExpenses.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:provider/provider.dart';

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  bool _showAllTimeStats = false;
  bool _showPreferredStats = false;
  bool _showPeriodStats = true;

  String _visiblePrefs = '';

  @override
  Widget build(BuildContext context) {
    final List<Transaction> _allTransactions =
        Provider.of<List<Transaction>>(context);
    final Period _currentPeriod = Provider.of<Period>(context);
    final Preferences _prefs = Provider.of<Preferences>(context);

    List<Transaction> _transactions;
    List<Transaction> _prevTransactions = [];

    ScrollController _scrollController = ScrollController();

    List<Map<String, dynamic>> _dividedTransactions = [];

    if (_allTransactions != null && _currentPeriod != null && _prefs != null) {
      if (_allTransactions.length > 0) {
        _dividedTransactions =
            divideTransactionsIntoPeriods(_allTransactions, _currentPeriod);
      }

      if (_prefs.isLimitDaysEnabled) {
        _visiblePrefs = '${_prefs.limitDays} days';
      } else if (_prefs.isLimitPeriodsEnabled) {
        _visiblePrefs = '${_prefs.limitPeriods} periods';
      } else if (_prefs.isLimitByDateEnabled) {
        _visiblePrefs = '~ ${getDate(_prefs.limitByDate)}';
      }

      if (_showAllTimeStats) {
        _transactions = _allTransactions;
      }

      if (_showPreferredStats) {
        if (_allTransactions.length > 0 && _prefs.isLimitDaysEnabled ||
            _prefs.isLimitByDateEnabled) {
          _transactions = filterTransactionsByLimit(_allTransactions, _prefs);
        } else {
          _transactions =
              filterTransactionsByPeriods(_dividedTransactions, _prefs)
                  .map<List<Transaction>>((map) => map['transactions'])
                  .expand((x) => x)
                  .toList();
        }
      }

      if (_showPeriodStats) {
        _transactions = filterTransactionsByPeriods(
          _dividedTransactions,
          _prefs.setPreference('limitPeriods', 1),
        )
            .map<List<Transaction>>((map) => map['transactions'])
            .expand((x) => x)
            .toList();

        List<Map<String, dynamic>> _periodFilteredTransactions =
            filterTransactionsByPeriods(
          _dividedTransactions,
          _prefs.setPreference('limitPeriods', 2),
        );

        _prevTransactions = _periodFilteredTransactions
            .sublist(1, min(2, _periodFilteredTransactions.length))
            .map<List<Transaction>>((map) => map['transactions'])
            .expand((x) => x)
            .toList();
      }
    }

    Widget _transactionsSelection = Row(
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
                  fontWeight:
                      _showAllTimeStats ? FontWeight.bold : FontWeight.normal,
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
                  fontWeight:
                      _showPreferredStats ? FontWeight.bold : FontWeight.normal,
                  color: _showPreferredStats ? Colors.white : Colors.black),
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
                  fontWeight:
                      _showPeriodStats ? FontWeight.bold : FontWeight.normal,
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
    );

    return (_allTransactions != null &&
            _prefs != null &&
            _allTransactions.length > 0)
        ? ListView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 10.0,
            ),
            children: <Widget>[
              _transactionsSelection,
              SizedBox(height: 20.0),
              Balance(_transactions, _prevTransactions, _showPeriodStats),
              SizedBox(height: 20.0),
              Categorical(_transactions),
              SizedBox(height: 20.0),
              TopExpenses(_transactions, _scrollController),
            ],
          )
        : Center(
            child: Text(
                'No transactions available. Add one in the page to the left.'),
          );
  }
}
