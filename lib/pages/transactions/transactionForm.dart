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
  List<Category> _categories;
  List<Category> _enabledCategories;

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

    if (_categories == null) {
      getCategories(_user.uid);
    } else {
      _enabledCategories =
          _categories.where((category) => category.enabled).toList();
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
                    LocalDBService().deleteTransaction(widget.tx);
                    goHome(context);
                  },
                )
              ]
            : null,
      ),
      body: (_enabledCategories != null && _enabledCategories.isNotEmpty)
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
                      value: _category ??
                          widget.tx.category ??
                          // ListTile(
                          //   leading: CircleAvatar(
                          //     child: Icon(IconData(
                          //       _enabledCategories.first.icon,
                          //       fontFamily: 'MaterialIcons',
                          //     )),
                          //     radius: 25.0,
                          //   ),
                          //   title: Text(_enabledCategories.first.name),
                          // ),
                          _enabledCategories.first.name,
                      items: _enabledCategories.map((category) {
                            return DropdownMenuItem(
                              value: category.name,
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
                              child: Text(category.name),
                            );
                          }).toList() +
                          (_enabledCategories.any((category) =>
                                  widget.tx.category == null ||
                                  category.name == widget.tx.category)
                              ? []
                              : [
                                  DropdownMenuItem(
                                    value: widget.tx.category,
                                    // child: ListTile(
                                    //   leading: CircleAvatar(
                                    //     child: Icon(
                                    //       IconData(
                                    //         _categories
                                    //             .where((cat) =>
                                    //                 cat.name ==
                                    //                 widget.tx.category)
                                    //             .first
                                    //             .icon,
                                    //         fontFamily: 'MaterialIcons',
                                    //       ),
                                    //     ),
                                    //     radius: 25.0,
                                    //   ),
                                    //   title: Text(widget.tx.category),
                                    // ),
                                    child: Text(widget.tx.category),
                                  )
                                ]),
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
                                _enabledCategories.first.name,
                            uid: _user.uid,
                          );

                          setState(() => isLoading = true);
                          isEditMode
                              ? LocalDBService().updateTransaction(tx)
                              : LocalDBService().addTransaction(tx);
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
        setState(() => _categories = categories);
      });
    });
  }
}
