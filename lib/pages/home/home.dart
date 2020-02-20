import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/statistics.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/background.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final FirebaseUser user;

  Home(this.user);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Transaction> _transactions;
  Period _currentPeriod;
  Preferences _prefs;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
    BackgroundService.initBackgroundService(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _pages = [
      {
        'name': 'Records',
        'widget': TransactionsList(
          _transactions,
          _currentPeriod,
          _prefs,
          () => retrieveNewData(widget.user.uid),
        ),
        'addButton': addFloatingButton(
          context,
          StreamProvider<List<Category>>(
            create: (_) => DatabaseWrapper(widget.user.uid).getCategories(),
            child: TransactionForm(Transaction.empty()),
          ),
          () => retrieveNewData(widget.user.uid),
        ),
      },
      {
        'name': 'Statistics',
        'widget': Statistics(_transactions, _currentPeriod, _prefs),
      }
    ];

    return Scaffold(
      drawer: MainDrawer(widget.user),
      appBar: AppBar(
        title: Text(_pages[_selectedIndex]['name']),
      ),
      body: _pages[_selectedIndex]['widget'],
      floatingActionButton: _pages[_selectedIndex]['addButton'],
      bottomNavigationBar: transactionsAndStatistics(),
    );
  }

  Widget transactionsAndStatistics() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
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
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
    );
  }

  void retrieveNewData(String uid) {
    DatabaseWrapper(uid)
        .getTransactions()
        .first
        .then((transactions) => setState(() => _transactions = transactions));

    DatabaseWrapper(uid)
        .getDefaultPeriod()
        .first
        .then((period) => setState(() => _currentPeriod = period));

    DatabaseWrapper(uid)
        .getPreferences()
        .first
        .then((prefs) => setState(() => _prefs = prefs));
  }
}
