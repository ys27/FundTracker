import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/statistics/statistics.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/drawer.dart';
import 'package:fund_tracker/shared/library.dart';
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
    List<Widget> tabItems = [
      StreamProvider<List<Transaction>>.value(
        value: LocalDBService().getTransactions(_user.uid),
        child: TransactionsList(),
      ),
      Statistics()
    ];

    return Scaffold(
      drawer: StreamProvider<User>.value(
        value: LocalDBService().findUser(_user.uid),
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: Text('Records'),
      ),
      body: tabItems[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => openPage(
          context,
          StreamProvider<List<Category>>.value(
            value: LocalDBService().getCategories(_user.uid),
            child: TransactionForm(Transaction.empty()),
          ),
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
