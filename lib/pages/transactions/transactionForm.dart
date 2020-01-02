import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Transaction tx;

  TransactionForm(this.tx);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalDBService _localDBService = LocalDBService();
  List<Category> enabledCategories;

  DateTime _date;
  bool _isExpense;
  String _payee;
  double _amount;
  String _category;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final isEditMode = widget.tx.tid != null;

    if (enabledCategories == null) {
      getCategories(_user.uid);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        actions: isEditMode
            ? <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  child: Icon(Icons.delete),
                  onPressed: () async {
                    setState(() => isLoading = true);
                    await LocalDBService()
                        .deleteTransaction(widget.tx);
                    goHome(context);
                  },
                )
              ]
            : null,
      ),
      body: (enabledCategories != null)
          ? Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 50.0,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.all(15.0),
                            color: (_isExpense ?? widget.tx.isExpense)
                                ? Colors.grey[100]
                                : Theme.of(context).primaryColor,
                            child: Text(
                              'Income',
                              style: TextStyle(
                                  fontWeight:
                                      (_isExpense ?? widget.tx.isExpense)
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                  color: (_isExpense ?? widget.tx.isExpense)
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            onPressed: () => setState(() => _isExpense = false),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.all(15.0),
                            color: (_isExpense ?? widget.tx.isExpense)
                                ? Theme.of(context).primaryColor
                                : Colors.grey[100],
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                fontWeight: (_isExpense ?? widget.tx.isExpense)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: (_isExpense ?? widget.tx.isExpense)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            onPressed: () => setState(() => _isExpense = true),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20.0),
                    FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              '${(_date ?? widget.tx.date).year.toString()}.${(_date ?? widget.tx.date).month.toString()}.${(_date ?? widget.tx.date).day.toString()}'),
                          Icon(Icons.date_range),
                        ],
                      ),
                      onPressed: () async {
                        DateTime date = await showDatePicker(
                          context: context,
                          initialDate: new DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() => _date = date);
                        }
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: widget.tx.payee,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter a payee or a note.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Payee',
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (val) {
                        setState(() => _payee = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: widget.tx.amount != null
                          ? widget.tx.amount.toStringAsFixed(2)
                          : null,
                      autovalidate: _amount != null,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please enter an amount.';
                        }
                        if (val.indexOf('.') > 0 &&
                            val.split('.')[1].length > 2) {
                          return 'At most 2 decimal places allowed.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Amount',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() => _amount = double.parse(val));
                      },
                    ),
                    SizedBox(height: 20.0),
                    DropdownButtonFormField(
                      validator: (val) {
                        return null;
                      },
                      value: _category ??
                          widget.tx.category ??
                          // ListTile(
                          //     leading: CircleAvatar(
                          //       child: Icon(IconData(
                          //         enabledCategories.first.icon,
                          //         fontFamily: 'MaterialIcons',
                          //       )),
                          //       radius: 25.0,
                          //     ),
                          //     title: Text(categories[0].name),
                          //   )
                          enabledCategories.first.name,
                      items: enabledCategories.map((category) {
                        return DropdownMenuItem(
                          value: category.name,
                          child: Text(category.name),
                          // child: ListTile(
                          //   leading: CircleAvatar(
                          //     child: Icon(IconData(
                          //       category.icon,
                          //       fontFamily: 'MaterialIcons',
                          //     )),
                          //     radius: 25.0,
                          //   ),
                          //   title: Text(category.name),
                          // ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _category = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        isEditMode ? 'Save' : 'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          Transaction tx = Transaction(
                            tid: widget.tx.tid ?? new Uuid().v1(),
                            date: _date ?? widget.tx.date,
                            isExpense: _isExpense ?? widget.tx.isExpense,
                            payee: _payee ?? widget.tx.payee,
                            amount: _amount ?? widget.tx.amount,
                            category: _category ??
                                widget.tx.category ??
                                enabledCategories.first.name,
                            uid: _user.uid,
                          );

                          setState(() => isLoading = true);
                          isEditMode
                              ? await LocalDBService()
                                  .updateTransaction(tx)
                              : await LocalDBService()
                                  .addTransaction(tx);
                          goHome(context);
                        }
                      },
                    )
                  ],
                ),
              ),
            )
          : Loader(),
    );
  }

  void getCategories(String uid) {
    final Future<Database> dbFuture = _localDBService.initializeDBs();
    dbFuture.then((db) {
      Future<List<Category>> usersFuture = _localDBService.getCategories(uid);
      usersFuture.then((categories) {
        setState(() => enabledCategories =
            categories.where((category) => category.enabled).toList());
      });
    });
  }
}
