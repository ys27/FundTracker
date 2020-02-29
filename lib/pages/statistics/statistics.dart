import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/balance.dart';
import 'package:fund_tracker/pages/statistics/categories.dart';
import 'package:fund_tracker/pages/statistics/topExpenses.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';

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

  Widget _limitCustomizer;

  List<Transaction> _transactions;
  List<Map<String, dynamic>> _dividedTransactions = [];
  int _daysLeft;
  DateTime _customLimitByDate;
  Map<String, dynamic> _customPeriod;
  bool _showStatistics = true;

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
      } else if (widget.prefs.isLimitByDateEnabled) {
        _visiblePrefs = _customLimitByDate != null
            ? '~ ${getDateStr(_customLimitByDate)}'
            : '~ ${getDateStr(widget.prefs.limitByDate)}';
      } else if (widget.prefs.isLimitPeriodsEnabled) {
        _visiblePrefs = '${widget.prefs.limitPeriods} periods';
      }

      if (_showAllTimeStats) {
        _transactions = widget.allTransactions;
        _limitCustomizer = SizedBox(height: 48.0);
      }

      if (_showPreferredStats) {
        if (widget.allTransactions.length > 0 &&
                widget.prefs.isLimitDaysEnabled ||
            widget.prefs.isLimitByDateEnabled) {
          Preferences customPrefs = Preferences(
            pid: widget.prefs.pid,
            limitDays: widget.prefs.limitDays,
            isLimitDaysEnabled: widget.prefs.isLimitDaysEnabled,
            limitPeriods: widget.prefs.limitPeriods,
            isLimitPeriodsEnabled: widget.prefs.isLimitPeriodsEnabled,
            limitByDate: widget.prefs.limitByDate,
            isLimitByDateEnabled: widget.prefs.isLimitByDateEnabled,
          );
          if (_customLimitByDate != null) {
            customPrefs =
                customPrefs.setPreference('limitByDate', _customLimitByDate);
          }
          _transactions =
              filterTransactionsByLimit(widget.allTransactions, customPrefs);
        } else {
          _transactions = filterPeriodsWithLimit(
                  _dividedTransactions, widget.prefs.limitPeriods)
              .map<List<Transaction>>((map) => map['transactions'])
              .expand((x) => x)
              .toList();
        }
        _limitCustomizer = datePicker(
          context,
          getDateStr(widget.prefs.limitByDate),
          '',
          (date) => setState(() => _customLimitByDate = getDateNotTime(date)),
          widget.prefs.limitByDate,
        );
        if (_customLimitByDate != null &&
            _customLimitByDate.isAfter(widget.allTransactions.first.date)) {
          _showStatistics = false;
        } else {
          _showStatistics = true;
        }
      }

      if (_showPeriodStats) {
        Map<String, dynamic> _currentPeriodTransactions =
            findCurrentPeriod(_dividedTransactions);
        if (_customPeriod != null) {
          _transactions = _customPeriod['transactions'];
          if (_customPeriod['startDate'] ==
              _currentPeriodTransactions['startDate']) {
            _customPeriod = null;
          }
        }
        if (_customPeriod == null) {
          if (_currentPeriodTransactions.containsKey('transactions')) {
            _daysLeft = _currentPeriodTransactions['endDate']
                .difference(DateTime.now())
                .inDays;
            _transactions = _currentPeriodTransactions['transactions'];
          } else {
            _daysLeft = 0;
            _transactions = [];
          }
        }

        _limitCustomizer = DropdownButton<Map<String, dynamic>>(
          items: _dividedTransactions.map((map) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: map,
              child: Center(
                child: Text(
                  '${getDateStr(map['startDate'])} - ${getDateStr(map['endDate'])}',
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _customPeriod = val);
          },
          hint: Center(
            child: Text(
              _customPeriod != null
                  ? '${getDateStr(_customPeriod['startDate'])} - ${getDateStr(_customPeriod['endDate'])}'
                  : '${getDateStr(_currentPeriodTransactions['startDate'])} - ${getDateStr(_currentPeriodTransactions['endDate'])}',
            ),
          ),
          isExpanded: true,
        );
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
          _limitCustomizer,
          _showStatistics
              ? Balance(
                  _transactions,
                  _customPeriod == null ? _showPeriodStats : false,
                  _daysLeft,
                )
              : Center(
                  child: Text('No transactions available after this date.'),
                ),
          _showStatistics ? SizedBox(height: 20.0) : Container(),
          _showStatistics
              ? Categories(_transactions.where((tx) => tx.isExpense).toList())
              : Container(),
          _showStatistics ? SizedBox(height: 20.0) : Container(),
          _showStatistics
              ? TopExpenses(
                  _transactions.where((tx) => tx.isExpense).toList(),
                  _transactions
                      .where((tx) => !tx.isExpense)
                      .fold(0.0, (a, b) => a + b.amount),
                  _transactions
                      .where((tx) => tx.isExpense)
                      .fold(0.0, (a, b) => a + b.amount),
                  _scrollController,
                )
              : Container(),
        ],
      );
    }

    return _body;
  }
}
