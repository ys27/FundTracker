import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/transactions/viewTransaction.dart';
import 'package:fund_tracker/services/database.dart';
import 'package:provider/provider.dart';

enum MenuItems { Edit, Delete }

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  TransactionTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () => showDialog(
            context: context,
            builder: (context) {
              return ViewTransaction(
                tid: transaction.tid,
                date: transaction.date,
                isExpense: transaction.isExpense,
                payee: transaction.payee,
                amount: transaction.amount,
                category: transaction.category,
              );
            },
          ),
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).accentColor,
          ),
          title: Text(transaction.payee),
          subtitle: Text(
              '${transaction.date.year.toString()}.${transaction.date.month.toString()}.${transaction.date.day.toString()}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}'),
              PopupMenuButton(
                child: Icon(Icons.more_vert),
                onSelected: (val) {
                  if (val == MenuItems.Edit) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ViewTransaction();
                      },
                    );
                  } else if (val == MenuItems.Delete) {
                    DatabaseService(uid: user.uid).deleteTransaction(transaction);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: MenuItems.Edit,
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: MenuItems.Delete,
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
