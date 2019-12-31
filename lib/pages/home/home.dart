import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/shared/drawer.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
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
        body: TransactionsList(),
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
      ),
    );
  }
}
