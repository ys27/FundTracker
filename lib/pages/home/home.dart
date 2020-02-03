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

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _pages = [
      {
        'name': 'Records',
        'widget': provideTxPeriodPrefs(TransactionsList()),
        'addButton': addFloatingButton(
          context,
          StreamProvider<List<Category>>(
            create: (_) => DatabaseWrapper(widget.user.uid).getCategories(),
            child: TransactionForm(Transaction.empty()),
          ),
        ),
      },
      {
        'name': 'Statistics',
        'widget': provideTxPeriodPrefs(Statistics()),
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

  MultiProvider provideTxPeriodPrefs(Widget page) {
    return MultiProvider(
      providers: [
        StreamProvider<List<Transaction>>(
          create: (_) => DatabaseWrapper(widget.user.uid).getTransactions(),
        ),
        StreamProvider<Period>(
          create: (_) => DatabaseWrapper(widget.user.uid).getDefaultPeriod(),
          catchError: (_, __) => Period.monthly(),
        ),
        StreamProvider<Preferences>(
          create: (_) => DatabaseWrapper(widget.user.uid).getPreferences(),
        ),
      ],
      child: page,
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
}
