import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/statistics/statistics.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/shared/drawer.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Widget> tabItems = [TransactionsList(), Statistics()];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return StreamProvider<List<Transaction>>.value(
      value: FireDBService(uid: user.uid).transactions,
      child: Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: Text('Records'),
        ),
        body: tabItems[_selectedIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return TransactionForm(
                tid: null,
                date: DateTime.now(),
                isExpense: true,
                payee: '',
                amount: null,
                category: null,
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
      ),
    );
  }
}
