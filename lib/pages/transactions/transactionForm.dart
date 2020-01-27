import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Transaction tx;

  TransactionForm(this.tx);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();

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
    final List<Category> _categories = Provider.of<List<Category>>(context);
    final List<Category> _enabledCategories = _categories != null
        ? _categories.where((category) => category.enabled).toList()
        : [];

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
                    DatabaseWrapper(_user.uid).deleteTransaction(widget.tx);
                    // goHome(context);
                    Navigator.pop(context);
                  },
                )
              ]
            : null,
      ),
      body: (_enabledCategories != null &&
              _enabledCategories.isNotEmpty &&
              !isLoading)
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
                          Text(getDate(_date ?? widget.tx.date)),
                          Icon(Icons.date_range),
                        ],
                      ),
                      onPressed: () async {
                        DateTime date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
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
                          : '',
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
                    Center(
                      child: DropdownButton<String>(
                        items: _enabledCategories.map((category) {
                              return DropdownMenuItem(
                                value: category.name,
                                child: Row(children: <Widget>[
                                  Icon(IconData(
                                    category.icon,
                                    fontFamily: 'MaterialIcons',
                                  )),
                                  SizedBox(width: 10),
                                  Text(
                                    category.name,
                                  ),
                                ]),
                              );
                            }).toList() +
                            (_enabledCategories.any((category) =>
                                    widget.tx.category == null ||
                                    category.name == widget.tx.category)
                                ? []
                                : [
                                    DropdownMenuItem(
                                      value: widget.tx.category,
                                      child: Row(children: <Widget>[
                                        Icon(IconData(
                                          _categories
                                              .where((cat) =>
                                                  cat.name ==
                                                  widget.tx.category)
                                              .first
                                              .icon,
                                          fontFamily: 'MaterialIcons',
                                        )),
                                        SizedBox(width: 10),
                                        Text(
                                          widget.tx.category,
                                        ),
                                      ]),
                                    )
                                  ]),
                        onChanged: (val) {
                          setState(() => _category = val);
                        },
                        value: _category ??
                            widget.tx.category ??
                            _enabledCategories.first.name,
                        isExpanded: true,
                      ),
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
                            tid: widget.tx.tid ?? Uuid().v1(),
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
                              ? DatabaseWrapper(_user.uid).updateTransaction(tx)
                              : DatabaseWrapper(_user.uid).addTransaction(tx);
                          Navigator.pop(context);
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
}
