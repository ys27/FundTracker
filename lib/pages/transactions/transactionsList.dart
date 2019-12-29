import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionTile.dart';
import 'package:provider/provider.dart';

class TransactionsList extends StatefulWidget {
  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<List<Transaction>>(context) ?? [];

    if (transactions.length == 0) {
      return Center(
        child:
            Text('No transactions available. Add one using the button below.'),
      );
    } else {
      return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return TransactionTile(transaction: transactions[index]);
        },
      );
    }
  }
}
