import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  TransactionTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).accentColor,
          ),
          title: Text(transaction.payee),
          subtitle: Text(
              '${transaction.date.year.toString()}.${transaction.date.month.toString()}.${transaction.date.day.toString()}'),
          trailing: Text('${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}
