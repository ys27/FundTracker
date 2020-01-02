import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionTile.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class TransactionsList extends StatefulWidget {
  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  final LocalDBService _localDBService = LocalDBService();
  List<Transaction> _transactions;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    if (_transactions == null) {
      getTransactions(_user.uid);
    }

    if (_transactions == null || _transactions.length == 0) {
      return Center(
        child:
            Text('No transactions available. Add one using the button below.'),
      );
    } else {
      return ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          return TransactionTile(transaction: _transactions[index]);
        },
      );
    }
  }

  void getTransactions(String uid) {
    final Future<Database> dbFuture = _localDBService.initializeDBs();
    dbFuture.then((db) {
      Future<List<Transaction>> transactionsFuture =
          _localDBService.getTransactions(uid);
      transactionsFuture.then((transactions) {
        setState(() => _transactions = transactions);
      });
    });
  }
}
