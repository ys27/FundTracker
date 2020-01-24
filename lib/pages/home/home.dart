import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/statistics.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/mainDrawer.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    List<Map<String, dynamic>> tabItems = [
      {
        'name': 'Records',
        'widget': MultiProvider(
          providers: [
            StreamProvider<List<Transaction>>(
              create: (_) => DatabaseWrapper(_user.uid).getTransactions(),
            ),
            StreamProvider<Period>(
              create: (_) => DatabaseWrapper(_user.uid).getDefaultPeriod(),
            ),
          ],
          child: TransactionsList(),
        ),
      },
      {
        'name': 'Statistics',
        'widget': Statistics(),
      }
    ];

    return Scaffold(
      drawer: MainDrawer(_user),
      appBar: AppBar(
        title: Text(tabItems[_selectedIndex]['name']),
      ),
      body: tabItems[_selectedIndex]['widget'],
      floatingActionButton: FloatingActionButton(
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
      ),
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
        onTap: (val) => setState(() => _selectedIndex = val),
      ),
    );
  }
}
