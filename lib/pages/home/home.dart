import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/addTransaction.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/database.dart';
import 'package:fund_tracker/shared/drawer.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return StreamProvider<List<Transaction>>.value(
      value: DatabaseService(uid: user.uid).transactions,
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
              return AddTransaction();
            },
          ),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
