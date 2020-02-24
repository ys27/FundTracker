import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/recurringTransactions.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RecurringTransactionForm extends StatefulWidget {
  final RecurringTransaction recTx;

  RecurringTransactionForm(this.recTx);

  @override
  _RecurringTransactionFormState createState() =>
      _RecurringTransactionFormState();
}

class _RecurringTransactionFormState extends State<RecurringTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  DateTime _nextDate;
  String _frequencyValue = '';
  DateUnit _frequencyUnit;
  bool _isExpense;
  String _payee;
  double _amount;
  String _category;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final isEditMode = !widget.recTx.equalTo(RecurringTransaction.empty());
    final List<Category> _categories = Provider.of<List<Category>>(context);
    final List<Category> _enabledCategories = _categories != null
        ? _categories.where((category) => category.enabled).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: title(isEditMode),
        actions: isEditMode
            ? <Widget>[
                deleteIcon(
                  context,
                  'recurring transaction',
                  () => DatabaseWrapper(_user.uid)
                      .deleteRecurringTransactions([widget.recTx]),
                  () => SyncService(_user.uid).syncRecurringTransactions(),
                )
              ]
            : null,
      ),
      body: (_enabledCategories != null &&
              _enabledCategories.isNotEmpty &&
              !isLoading)
          ? Container(
              padding: formPadding,
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        isExpenseSelector(
                          context,
                          _isExpense != null
                              ? !_isExpense
                              : !widget.recTx.isExpense,
                          'Income',
                          () => setState(() => _isExpense = false),
                        ),
                        isExpenseSelector(
                          context,
                          _isExpense ?? widget.recTx.isExpense,
                          'Expense',
                          () => setState(() => _isExpense = true),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    datePicker(
                      context,
                      'Next Date:                         ',
                      '${getDateStr(_nextDate ?? widget.recTx.nextDate)}',
                      (date) => setState(
                        () => _nextDate = getDateNotTime(date),
                      ),
                      DateTime.now(),
                      firstDate: getDateNotTime(DateTime.now()),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: widget.recTx.payee,
                      autovalidate: _payee != null,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter a payee or a note.';
                        } else if (val.length > 30) {
                          return 'Max 30 characters.';
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
                      initialValue: widget.recTx.amount != null
                          ? widget.recTx.amount.toStringAsFixed(2)
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
                                  Icon(
                                    IconData(
                                      category.icon,
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    color: categoriesRegistry.singleWhere(
                                        (cat) =>
                                            cat['name'] ==
                                            category.name)['color'],
                                  ),
                                  SizedBox(width: 10.0),
                                  Text(
                                    category.name,
                                  ),
                                ]),
                              );
                            }).toList() +
                            (_enabledCategories.any((category) =>
                                    widget.recTx.category == null ||
                                    category.name == widget.recTx.category)
                                ? []
                                : [
                                    DropdownMenuItem(
                                      value: widget.recTx.category,
                                      child: Row(children: <Widget>[
                                        Icon(
                                            IconData(
                                              _categories
                                                  .singleWhere(
                                                    (cat) =>
                                                        cat.name ==
                                                        widget.recTx.category,
                                                  )
                                                  .icon,
                                              fontFamily: 'MaterialIcons',
                                            ),
                                            color: categoriesRegistry
                                                .singleWhere((cat) =>
                                                    cat['name'] ==
                                                    widget.recTx
                                                        .category)['color']),
                                        SizedBox(width: 10.0),
                                        Text(
                                          widget.recTx.category,
                                        ),
                                      ]),
                                    )
                                  ]),
                        onChanged: (val) {
                          setState(() => _category = val);
                        },
                        value: _category ??
                            widget.recTx.category ??
                            _enabledCategories.first.name,
                        isExpanded: true,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: widget.recTx.frequencyValue != null
                          ? widget.recTx.frequencyValue.toString()
                          : '',
                      autovalidate: _frequencyValue.isNotEmpty,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter a value for the frequency.';
                        } else if (val.contains('.')) {
                          return 'This value must be an integer.';
                        } else if (int.parse(val) <= 0) {
                          return 'This value must be greater than 0';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Frequency',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() => _frequencyValue = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    DropdownButton<DateUnit>(
                      items: DateUnit.values.map((unit) {
                        return DropdownMenuItem<DateUnit>(
                          value: unit,
                          child: Text(unit.toString().split('.')[1]),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _frequencyUnit = val);
                      },
                      value: _frequencyUnit ?? widget.recTx.frequencyUnit,
                      isExpanded: true,
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
                          RecurringTransaction recTx = RecurringTransaction(
                            rid: widget.recTx.rid ?? Uuid().v1(),
                            nextDate: _nextDate ?? widget.recTx.nextDate,
                            frequencyValue: _frequencyValue != ''
                                ? int.parse(_frequencyValue)
                                : widget.recTx.frequencyValue,
                            frequencyUnit:
                                _frequencyUnit ?? widget.recTx.frequencyUnit,
                            isExpense: _isExpense ?? widget.recTx.isExpense,
                            payee: _payee ?? widget.recTx.payee,
                            amount: _amount ?? widget.recTx.amount,
                            category: _category ??
                                widget.recTx.category ??
                                _enabledCategories.first.name,
                            uid: _user.uid,
                          );

                          setState(() => isLoading = true);
                          isEditMode
                              ? DatabaseWrapper(_user.uid)
                                  .updateRecurringTransactions([recTx])
                              : DatabaseWrapper(_user.uid)
                                  .addRecurringTransactions([recTx]);
                          RecurringTransactionsService
                              .checkRecurringTransactions(_user.uid);
                          SyncService(_user.uid).syncRecurringTransactions();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : Loader(),
    );
  }

  Widget title(bool isEditMode) {
    return Text(isEditMode
        ? 'Edit Recurring Transaction'
        : 'Add Recurring Transaction');
  }
}
