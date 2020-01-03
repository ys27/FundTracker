import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/preferences/categoriesRegistry.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:provider/provider.dart';

enum MenuItems { Edit, Delete }

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  TransactionTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () => openPage(
            context,
            TransactionForm(
              Transaction(
                tid: transaction.tid,
                date: transaction.date,
                isExpense: transaction.isExpense,
                payee: transaction.payee,
                amount: transaction.amount,
                category: transaction.category,
                uid: _user.uid,
              ),
            ),
          ),
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            foregroundColor: Colors.black,
            child: Icon(IconData(
                CATEGORIES
                    .where((category) {
                      return category['name'] == transaction.category;
                    })
                    .toList()
                    .first['icon'],
                fontFamily: 'MaterialIcons')),
          ),
          title: Text(transaction.payee),
          subtitle: Text(
              '${transaction.date.year.toString()}.${transaction.date.month.toString()}.${transaction.date.day.toString()}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}'),
              SizedBox(width: 5.0),
              PopupMenuButton(
                child: Icon(Icons.more_vert),
                onSelected: (val) async {
                  Transaction tx = Transaction(
                    tid: transaction.tid,
                    date: transaction.date,
                    isExpense: transaction.isExpense,
                    payee: transaction.payee,
                    amount: transaction.amount,
                    category: transaction.category,
                    uid: _user.uid,
                  );
                  if (val == MenuItems.Edit) {
                    openPage(context, TransactionForm(tx));
                  } else if (val == MenuItems.Delete) {
                    LocalDBService().deleteTransaction(tx);
                    goHome(context);
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
