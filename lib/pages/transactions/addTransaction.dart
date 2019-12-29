import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/services/database.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';

class AddTransaction extends StatefulWidget {
  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _formKey = GlobalKey<FormState>();

  DateTime _date = DateTime.now();
  bool _isExpense = true;
  String _payee = '';
  double _amount;
  String _category;
  String noCategories = 'NA';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text('Add'),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                Transaction tx = Transaction(
                    date: _date,
                    isExpense: _isExpense,
                    payee: _payee,
                    amount: _amount,
                    category: _category);
                setState(() => isLoading = true);
                await DatabaseService(uid: user.uid).addTransaction(tx);
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: isLoading
          ? Loader()
          : Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 50.0,
              ),
              child: StreamBuilder<List<Category>>(
                stream: DatabaseService(uid: user.uid).categories,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Category> categories = snapshot.data;
                    return Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Expanded(
                                child: FlatButton(
                                  padding: EdgeInsets.all(15.0),
                                  color: _isExpense
                                      ? Colors.grey[100]
                                      : Theme.of(context).primaryColor,
                                  child: Text(
                                    'Income',
                                    style: TextStyle(
                                        fontWeight: _isExpense
                                            ? FontWeight.normal
                                            : FontWeight.bold),
                                  ),
                                  onPressed: () =>
                                      setState(() => _isExpense = false),
                                ),
                              ),
                              Expanded(
                                child: FlatButton(
                                  padding: EdgeInsets.all(15.0),
                                  color: _isExpense
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[100],
                                  child: Text(
                                    'Expense',
                                    style: TextStyle(
                                        fontWeight: _isExpense
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                  onPressed: () =>
                                      setState(() => _isExpense = true),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                  '${_date.year.toString()}.${_date.month.toString()}.${_date.day.toString()}'),
                              ButtonTheme(
                                minWidth: 0.0,
                                padding: EdgeInsets.all(0.0),
                                child: FlatButton(
                                  child: Icon(Icons.date_range),
                                  onPressed: () async {
                                    DateTime date = await showDatePicker(
                                      context: context,
                                      initialDate: new DateTime.now(),
                                      firstDate: DateTime.now()
                                          .subtract(Duration(days: 365)),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setState(() => _date = date);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Enter a payee or a note.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Payee',
                            ),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              setState(() => _payee = val);
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
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
                              hintText: 'Amount',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              setState(() => _amount = double.parse(val));
                            },
                          ),
                          SizedBox(height: 20.0),
                          DropdownButtonFormField(
                            validator: (val) {
                              if (val == noCategories) {
                                return 'Add categories in preferences.';
                              }
                              return null;
                            },
                            value: _category ??
                                (categories.length > 0
                                    ? categories[0].name
                                    : noCategories),
                            items: categories.length > 0
                                ? categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category.name,
                                      child: Text('${category.name}'),
                                    );
                                  }).toList()
                                : [
                                    DropdownMenuItem(
                                      value: noCategories,
                                      child: Text(noCategories),
                                    )
                                  ],
                            onChanged: (val) {
                              setState(() => _category = val);
                            },
                          ),
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
