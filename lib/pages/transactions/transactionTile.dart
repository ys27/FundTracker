import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:provider/provider.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  TransactionTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    Map<String, dynamic> _category = categoriesRegistry
        .singleWhere((category) => category['name'] == transaction.category);

    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () => showDialog(
            context: context,
            builder: (context) {
              return StreamProvider<List<Category>>(
                create: (_) => DatabaseWrapper(_user.uid).getCategories(),
                child: TransactionForm(
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
              );
            },
          ),
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(
              IconData(
                _category['icon'],
                fontFamily: 'MaterialIcons',
              ),
              color: _category['color'],
            ),
          ),
          title: Text(transaction.payee),
          subtitle: Text(transaction.category),
          trailing: Column(
            children: <Widget>[
              Text(
                '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.isExpense ? Colors.red : Colors.green,
                ),
              ),
              Text(getDateStr(transaction.date)),
            ],
          ),
        ),
      ),
    );
  }
}
