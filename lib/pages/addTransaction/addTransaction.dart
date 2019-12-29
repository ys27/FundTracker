import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
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

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<List<Category>>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text('Add'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                print(_date);
                print(_isExpense);
                print(_payee);
                print(_amount);
                print(_category);
              }
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 50.0,
        ),
        child: Form(
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
                      onPressed: () => setState(() => _isExpense = false),
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
                      onPressed: () => setState(() => _isExpense = true),
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
                          firstDate:
                              DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
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
                  if (val.indexOf('.') > 0 && val.split('.')[1].length > 2) {
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
                value: _category ??
                    (categories != null ? categories[0].name : 'Categories'),
                items: categories != null
                    ? categories.map((category) {
                        return DropdownMenuItem(
                          value: category.name,
                          child: Text('${category.name}'),
                        );
                      }).toList()
                    : null,
                onChanged: (val) {
                  setState(() => _category = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
