import 'package:flutter/material.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/balance.dart';
import 'package:fund_tracker/pages/statistics/categorical.dart';
import 'package:fund_tracker/pages/statistics/topExpenses.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:provider/provider.dart';

class Statistics extends StatefulWidget {
  final List<Transaction> filteredTransactions;
  final List<Map<String, dynamic>> dividedTransactions;

  Statistics(this.filteredTransactions, this.dividedTransactions);

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
    List<Transaction> _transactions;
    List<Transaction> _allTransactions =
        Provider.of<List<Transaction>>(context);
    Preferences _prefs = Provider.of<Preferences>(context);

    if (_allTransactions != null && _prefs != null) {
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
        if (_prefs.isLimitDaysEnabled || _prefs.isLimitByDateEnabled) {
          _transactions = widget.filteredTransactions;
        } else {
          _transactions =
              filterTransactionsByPeriods(widget.dividedTransactions, _prefs)
                  .map<List<Transaction>>((map) => map['transactions'])
                  .expand((x) => x)
                  .toList();
        }
      }

      if (_showPeriodStats) {
        _transactions = filterTransactionsByPeriods(
          widget.dividedTransactions,
          _prefs.setPreference('limitPeriods', 1),
        )
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

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 10.0,
      ),
      children: <Widget>[
        _transactionsSelection,
        SizedBox(height: 20.0),
        Balance(_transactions),
        SizedBox(height: 20.0),
        Categorical(_transactions),
        SizedBox(height: 20.0),
        TopExpenses(_transactions),
      ],
    );
  }
}
