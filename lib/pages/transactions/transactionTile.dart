import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';

enum MenuItems { Edit, Delete }

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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}'),
              PopupMenuButton(
                child: Icon(Icons.more_vert),
                onSelected: (val) {
                  print(val);
                  if (val == MenuItems.Edit) {

                  } else if (val == MenuItems.Delete) {
                    
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
