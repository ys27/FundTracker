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

class TransactionTile extends StatefulWidget {
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
  _TransactionTileState createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  Transaction _currentTransaction;
  Category _category;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaction;
    _category = widget.category;
  }

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
                    hiddenSuggestions: widget.hiddenSuggestions,
                    getTxOrRecTx: () => _currentTransaction,
                  ),
                );
              },
            );
            if (widget.refreshList != null) {
              widget.refreshList();
            } else {
              List<Transaction> newTxs =
                  await DatabaseWrapper(_user.uid).getTransactions();
              Transaction newTx =
                  newTxs.firstWhere((tx) => tx.tid == _currentTransaction.tid);
              Category newCategory = getCategory(widget.categories, newTx.cid);
              setState(() {
                _currentTransaction = newTx;
                _category = newCategory;
              });
            }
          },
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(
              IconData(
                _category.icon,
                fontFamily: 'MaterialDesignIconFont',
                fontPackage: 'community_material_icon',
              ),
              color: _category.iconColor,
            ),
          ),
          title: Text(
            _currentTransaction.payee,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: Text(
            _category.name,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Column(
            children: <Widget>[
              Text(
                '${_currentTransaction.isExpense ? '-' : '+'}\$${formatAmount(_currentTransaction.amount)}',
                style: TextStyle(
                  color:
                      _currentTransaction.isExpense ? Colors.red : Colors.green,
                ),
              ),
              Text(getDateStr(_currentTransaction.date)),
            ],
          ),
        ),
      ),
    );
  }
}
