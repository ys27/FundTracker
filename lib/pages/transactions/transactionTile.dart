import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication
    show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/suggestion.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:provider/provider.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final List<Category> categories;
  final List<Suggestion> hiddenSuggestions;
final Function refreshList;

  TransactionTile({
    this.transaction,
    this.category,
    this.categories,
    this.hiddenSuggestions,
    this.refreshList,
  });

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseAuthentication.User>(context);

    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return MultiProvider(
                  providers: [
                    FutureProvider<List<Transaction>>.value(
                        initialData: [],
                        value: DatabaseWrapper(_user.uid).getTransactions()),
                    FutureProvider<List<Category>>.value(
                        initialData: [],
                        value: DatabaseWrapper(_user.uid).getCategories()),
                  ],
                  child: TransactionForm(
                    hiddenSuggestions: hiddenSuggestions,
                    getTxOrRecTx: () => transaction,
                  ),
                );
              },
            );
            refreshList();
          },
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(
              IconData(
                category.icon,
                fontFamily: 'MaterialDesignIconFont',
                fontPackage: 'community_material_icon',
              ),
              color: category.iconColor,
            ),
          ),
          title: Text(
            transaction.payee,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: Text(
            category.name,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Column(
            children: <Widget>[
              Text(
                '${transaction.isExpense ? '-' : '+'}\$${formatAmount(transaction.amount)}',
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
