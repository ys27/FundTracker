import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';

class TransactionForm extends StatefulWidget {
  final String tid;
  final DateTime date;
  final bool isExpense;
  final String payee;
  final double amount;
  final String category;

  TransactionForm({
    this.tid,
    this.date,
    this.isExpense,
    this.payee,
    this.amount,
    this.category,
  });

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

  String _noCategories = 'NA';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);
    final isEditMode = widget.tid != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        actions: isEditMode
            ? <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  child: Icon(Icons.delete),
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    await FireDBService(uid: user.uid)
                        .deleteTransaction(widget.tid);
                    Navigator.pop(context);
                  },
                )
              ]
            : null,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 50.0,
        ),
        child: StreamBuilder<List<Category>>(
          stream: FireDBService(uid: user.uid).categories,
          builder: (context, snapshot) {
            if (snapshot.hasData && !_isLoading) {
              List<Category> categories = snapshot.data;
              return Form(
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
                            color: (_isExpense ?? widget.isExpense)
                                ? Colors.grey[100]
                                : Theme.of(context).primaryColor,
                            child: Text(
                              'Income',
                              style: TextStyle(
                                  fontWeight: (_isExpense ?? widget.isExpense)
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: (_isExpense ?? widget.isExpense)
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            onPressed: () => setState(() => _isExpense = false),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.all(15.0),
                            color: (_isExpense ?? widget.isExpense)
                                ? Theme.of(context).primaryColor
                                : Colors.grey[100],
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                fontWeight: (_isExpense ?? widget.isExpense)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: (_isExpense ?? widget.isExpense)
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
                              '${(_date ?? widget.date).year.toString()}.${(_date ?? widget.date).month.toString()}.${(_date ?? widget.date).day.toString()}'),
                          Icon(Icons.date_range),
                        ],
                      ),
                      onPressed: () async {
                        DateTime date = await showDatePicker(
                          context: context,
                          initialDate: new DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _date = date);
                        }
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: widget.payee,
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
                      initialValue: widget.amount != null
                          ? widget.amount.toStringAsFixed(2)
                          : null,
                      autovalidate: _amount.toString().isNotEmpty,
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
                        if (val == _noCategories) {
                          return 'Add categories in preferences.';
                        }
                        return null;
                      },
                      value: (_category ?? widget.category) ??
                          (categories.length > 0
                              ?
                              // ListTile(
                              //     leading: CircleAvatar(
                              //       child: Icon(IconData(
                              //         categories[0].icon,
                              //         fontFamily: 'MaterialIcons',
                              //       )),
                              //       radius: 25.0,
                              //     ),
                              //     title: Text(categories[0].name),
                              //   )
                              categories[0].name
                              : _noCategories),
                      items: categories.length > 0
                          ? categories.map((category) {
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
                            }).toList()
                          : [
                              DropdownMenuItem(
                                value: _noCategories,
                                child: Text(_noCategories),
                              )
                            ],
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
                              tid: widget.tid,
                              date: _date ?? widget.date,
                              isExpense: _isExpense ?? widget.isExpense,
                              payee: _payee ?? widget.payee,
                              amount: _amount ?? widget.amount,
                              category: _category ?? widget.category);
                          setState(() => _isLoading = true);
                          isEditMode
                              ? await FireDBService(uid: user.uid)
                                  .updateTransaction(tx)
                              : await FireDBService(uid: user.uid)
                                  .addTransaction(tx);
                          Navigator.pop(context);
                        }
                      },
                    )
                  ],
                ),
              );
            } else {
              return Loader();
            }
          },
        ),
      ),
    );
  }
}
