import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/statistics.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:fund_tracker/shared/mainDrawer.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _dividedTransactions = [];
  List<Transaction> _filteredTransactions = [];
  Widget _body = Loader();
  final _pages = ['Records', 'Statistics'];
  PageController _pageController =
      PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    List<Transaction> _transactions = Provider.of<List<Transaction>>(context);
    final Period _currentPeriod = Provider.of<Period>(context);
    final Preferences _prefs = Provider.of<Preferences>(context);

    if (_transactions != null &&
        _transactions.length > 0 &&
        _currentPeriod != null &&
        _prefs != null) {
      _filteredTransactions = filterTransactionsByLimit(_transactions, _prefs);
      _dividedTransactions =
          divideTransactionsIntoPeriods(_filteredTransactions, _currentPeriod);
      if (_prefs.isLimitPeriodsEnabled) {
        _dividedTransactions =
            filterTransactionsByPeriods(_dividedTransactions, _prefs);
      }
      _body = PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: <Widget>[
          TransactionsList(_dividedTransactions),
          Statistics(_filteredTransactions, _dividedTransactions),
        ],
      );
    }

    return Scaffold(
      drawer: MainDrawer(_user),
      appBar: AppBar(
        title: Text(_pages[_selectedIndex]),
      ),
      body: _body,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  return StreamProvider<List<Category>>(
                    create: (_) => DatabaseWrapper(_user.uid).getCategories(),
                    child: TransactionForm(Transaction.empty()),
                  );
                },
              ),
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            title: Text('Records'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.equalizer),
            title: Text('Statistics'),
          )
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
          _pageController.jumpToPage(index);
          // _pageController.animateToPage(
          //   index,
          //   duration: Duration(milliseconds: 1),
          //   curve: Curves.linear,
          // );
        }),
      ),
    );
  }
}
