import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/recurringTransactions.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Function getTxOrRecTx;

  TransactionForm({this.getTxOrRecTx});

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _payeeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _frequencyValueController =
      TextEditingController();
  final TextEditingController _occurrenceValueController =
      TextEditingController();

  final FocusNode _payeeFocus = new FocusNode();
  final FocusNode _amountFocus = new FocusNode();
  final FocusNode _frequencyValueFocus = new FocusNode();
  final FocusNode _occurrenceValueFocus = new FocusNode();

  bool _isPayeeInFocus = false;
  bool _isAmountInFocus = false;
  bool _isFrequencyValueInFocus = false;
  bool _isOccurrenceValueInFocus = false;

  DateTime _nextDate;
  DateTime _endDate;
  String _occurrenceValue;
  String _frequencyValue;
  DateUnit _frequencyUnit;

  DateTime _date;

  bool _isExpense;
  String _payee;
  String _amount;
  String _cid;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final dynamic givenTxOrRecTx = widget.getTxOrRecTx();

    if (givenTxOrRecTx is RecurringTransaction) {
      _nextDate = givenTxOrRecTx.nextDate;
      _endDate = givenTxOrRecTx.endDate;
      _occurrenceValue = givenTxOrRecTx.occurrenceValue != null
          ? givenTxOrRecTx.occurrenceValue.toString()
          : '';
      _frequencyValue = givenTxOrRecTx.frequencyValue != null
          ? givenTxOrRecTx.frequencyValue.toString()
          : '';
      _frequencyUnit = givenTxOrRecTx.frequencyUnit;
    }
    if (givenTxOrRecTx is Transaction) {
      _date = givenTxOrRecTx.date;
    }

    _isExpense = givenTxOrRecTx.isExpense;
    _payee = givenTxOrRecTx.payee ?? '';
    _amount =
        givenTxOrRecTx.amount != null ? givenTxOrRecTx.amount.toString() : '';
    _cid = givenTxOrRecTx.cid;

    _payeeController.text = givenTxOrRecTx.payee ?? '';
    _amountController.text = givenTxOrRecTx.amount != null
        ? givenTxOrRecTx.amount.toStringAsFixed(2)
        : null;
    _frequencyValueController.text = givenTxOrRecTx is RecurringTransaction
        ? (givenTxOrRecTx.frequencyValue != null
            ? givenTxOrRecTx.frequencyValue.toString()
            : '')
        : '';
    _occurrenceValueController.text = givenTxOrRecTx is RecurringTransaction
        ? (givenTxOrRecTx.occurrenceValue != null
            ? givenTxOrRecTx.occurrenceValue.toString()
            : '')
        : '';

    _payeeFocus.addListener(_checkFocus);
    _amountFocus.addListener(_checkFocus);
    _frequencyValueFocus.addListener(_checkFocus);
    _occurrenceValueFocus.addListener(_checkFocus);
  }

  void _checkFocus() {
    setState(() {
      _isPayeeInFocus = _payeeFocus.hasFocus;
      _isAmountInFocus = _amountFocus.hasFocus;
      _isFrequencyValueInFocus = _frequencyValueFocus.hasFocus;
      _isOccurrenceValueInFocus = _occurrenceValueFocus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final dynamic givenTxOrRecTx = widget.getTxOrRecTx();
    final bool isRecurringTxMode = givenTxOrRecTx is RecurringTransaction;
    final bool isEditMode = isRecurringTxMode
        ? givenTxOrRecTx.rid != null
        : givenTxOrRecTx.tid != null;
    final List<Transaction> _transactions =
        Provider.of<List<Transaction>>(context);
    final List<Category> _categories = Provider.of<List<Category>>(context);

    Widget _body = Loader();

    if (_transactions != null && _categories != null) {
      final List<Category> _enabledCategories =
          _categories.where((category) => category.enabled).toList();
      final Category _correspondingCategory =
          getCategory(_categories, givenTxOrRecTx.cid);

      _body = Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: <Widget>[
            SizedBox(height: 10.0),
            TabSelector(
              context,
              tabs: [
                {
                  'enabled': !_isExpense,
                  'title': 'Income',
                  'onPressed': () => setState(() => _isExpense = false),
                },
                {
                  'enabled': _isExpense,
                  'title': 'Expense',
                  'onPressed': () => setState(() => _isExpense = true),
                },
              ],
            ),
            SizedBox(height: 10.0),
            DatePicker(
              context,
              leading: isRecurringTxMode
                  ? 'Next Date:                         '
                  : getDateStr(_date),
              trailing: isRecurringTxMode ? '${getDateStr(_nextDate)}' : '',
              updateDateState: (date) => setState(() {
                if (isRecurringTxMode) {
                  _nextDate = getDateNotTime(date);
                } else {
                  _date = date;
                }
              }),
              openDate: DateTime.now(),
              firstDate:
                  isRecurringTxMode ? getDateNotTime(DateTime.now()) : null,
            ),
            if (!isRecurringTxMode) ...[
              TimePicker(
                context,
                leading: getTimeStr(_date),
                updateTimeState: (time) => setState(
                  () {
                    DateTime oldDateTime = _date;
                    DateTime newDateTime = DateTime(
                      oldDateTime.year,
                      oldDateTime.month,
                      oldDateTime.day,
                      time.hour,
                      time.minute,
                    );
                    _date = newDateTime;
                  },
                ),
              ),
            ],
            TypeAheadFormField(
              autovalidate: _payee.isNotEmpty,
              validator: (val) {
                if (val.isEmpty) {
                  return 'Enter a payee or a note.';
                } else if (val.length > 30) {
                  return 'Max 30 characters.';
                }
                return null;
              },
              textFieldConfiguration: TextFieldConfiguration(
                controller: _payeeController,
                focusNode: _payeeFocus,
                decoration: clearInput(
                  labelText: 'Payee',
                  enabled: _payee.isNotEmpty && _isPayeeInFocus,
                  onPressed: () {
                    setState(() => _payee = '');
                    _payeeController.safeClear();
                  },
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (val) {
                  setState(() => _payee = val);
                },
              ),
              suggestionsCallback: (query) {
                if (query == '') {
                  return null;
                } else {
                  List<Map<String, dynamic>> suggestionsWithCount = [];

                  _transactions
                      .where(
                    (tx) =>
                        tx.payee.toLowerCase().startsWith(query.toLowerCase()),
                  )
                      .forEach((tx) {
                    final String suggestion = '${tx.payee}::${tx.cid}';
                    final int suggestionIndex = suggestionsWithCount
                        .indexWhere((map) => map['suggestion'] == suggestion);
                    if (suggestionIndex != -1) {
                      suggestionsWithCount[suggestionIndex]['count']++;
                    } else {
                      suggestionsWithCount.add({
                        'suggestion': '${tx.payee}::${tx.cid}',
                        'count': 1,
                      });
                    }
                  });
                  suggestionsWithCount
                      .sort((a, b) => b['count'].compareTo(a['count']));
                  final List<String> suggestions =
                      suggestionsWithCount.map((map) {
                    final String suggestion = map['suggestion'];
                    return suggestion;
                  }).toList();
                  if (suggestions.length > 0) {
                    return suggestions;
                  } else {
                    return null;
                  }
                }
              },
              itemBuilder: (context, suggestion) {
                final List<String> splitSuggestion = suggestion.split('::');
                final String suggestionPayee = splitSuggestion[0];
                final String suggestionCid = splitSuggestion[1];
                final Category category =
                    getCategory(_categories, suggestionCid);
                return ListTile(
                  leading: Icon(
                    IconData(
                      category.icon,
                      fontFamily: 'MaterialDesignIconFont',
                      fontPackage: 'community_material_icon',
                    ),
                    color: category.iconColor,
                  ),
                  title: Text(suggestionPayee),
                  subtitle: Text(category.name),
                );
              },
              onSuggestionSelected: (suggestion) {
                final List<String> splitSuggestion = suggestion.split('::');
                final String suggestionPayee = splitSuggestion[0];
                final String suggestionCid = splitSuggestion[1];

                _payeeController.text = suggestionPayee;
                setState(() {
                  _payee = suggestionPayee;
                  _cid = suggestionCid;
                });
              },
            ),
            TextFormField(
              controller: _amountController,
              focusNode: _amountFocus,
              autovalidate: _amount.isNotEmpty,
              validator: (val) {
                if (val.isEmpty) {
                  return 'Please enter an amount.';
                }
                if (val.indexOf('.') > 0 && val.split('.')[1].length > 2) {
                  return 'At most 2 decimal places allowed.';
                }
                return null;
              },
              decoration: clearInput(
                labelText: 'Amount',
                enabled: _amount.isNotEmpty && _isAmountInFocus,
                onPressed: () {
                  setState(() => _amount = '');
                  _amountController.safeClear();
                },
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  _amount = val;
                });
              },
            ),
            SizedBox(height: 10.0),
            Center(
              child: DropdownButton<String>(
                items: [
                  ..._enabledCategories.map((category) {
                    return DropdownMenuItem(
                      value: category.cid,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            IconData(
                              category.icon,
                              fontFamily: 'MaterialDesignIconFont',
                              fontPackage: 'community_material_icon',
                            ),
                            color: category.iconColor,
                          ),
                          SizedBox(width: 10.0),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  if (_correspondingCategory != null &&
                      _enabledCategories
                              .where((category) =>
                                  category.cid == _correspondingCategory.cid)
                              .length ==
                          0) ...[
                    DropdownMenuItem(
                      value: _correspondingCategory.cid,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            IconData(
                              _correspondingCategory.icon,
                              fontFamily: 'MaterialDesignIconFont',
                              fontPackage: 'community_material_icon',
                            ),
                            color: _correspondingCategory.iconColor,
                          ),
                          SizedBox(width: 10.0),
                          Text(_correspondingCategory.name),
                        ],
                      ),
                    )
                  ]
                ],
                onChanged: (val) {
                  setState(() => _cid = val);
                },
                value: _cid ??
                    (_correspondingCategory != null
                        ? _correspondingCategory.cid
                        : _enabledCategories.first.cid),
                isExpanded: true,
              ),
            ),
            if (isRecurringTxMode) ...[
              TextFormField(
                controller: _frequencyValueController,
                focusNode: _frequencyValueFocus,
                autovalidate: _frequencyValue.isNotEmpty,
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Enter a value.';
                  } else if (val.contains('.')) {
                    return 'This value must be an integer.';
                  } else if (int.parse(val) <= 0) {
                    return 'This value must be greater than 0';
                  }
                  return null;
                },
                decoration: clearInput(
                  labelText: 'Frequency',
                  enabled:
                      _frequencyValue.isNotEmpty && _isFrequencyValueInFocus,
                  onPressed: () {
                    setState(() => _frequencyValue = '');
                    _frequencyValueController.safeClear();
                  },
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() => _frequencyValue = val);
                },
              ),
              SizedBox(height: 10.0),
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
                value: _frequencyUnit,
                isExpanded: true,
              ),
              SizedBox(height: 10.0),
              Center(child: Text('End Condition (optional)')),
              TextFormField(
                controller: _occurrenceValueController,
                focusNode: _occurrenceValueFocus,
                autovalidate: _occurrenceValue.isNotEmpty,
                validator: (val) {
                  if (val.isEmpty) {
                    return null;
                  }
                  if (val.contains('.')) {
                    return 'This value must be an integer.';
                  } else if (int.parse(val) <= 0) {
                    return 'This value must be greater than 0';
                  }
                  return null;
                },
                decoration: clearInput(
                  labelText: 'How many times?',
                  enabled:
                      _occurrenceValue.isNotEmpty && _isOccurrenceValueInFocus,
                  onPressed: () {
                    setState(() => _occurrenceValue = '');
                    _occurrenceValueController.safeClear();
                  },
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    _endDate = null;
                    _occurrenceValue = val;
                  });
                },
              ),
              DatePicker(
                context,
                leading: 'End Date:                          ',
                trailing: '${getDateStr(_endDate)}',
                updateDateState: (date) {
                  setState(() {
                    _endDate = getDateNotTime(date);
                    _occurrenceValue = '';
                  });
                  _occurrenceValueController.safeClear();
                },
                openDate: DateTime.now(),
                firstDate: getDateNotTime(DateTime.now()),
              ),
            ],
            SizedBox(height: 10.0),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text(
                isEditMode ? 'Save' : 'Add',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  setState(() => isLoading = true);

                  if (isRecurringTxMode) {
                    RecurringTransaction recTx = RecurringTransaction(
                      rid: givenTxOrRecTx.rid ?? Uuid().v1(),
                      nextDate: _nextDate,
                      endDate: _endDate,
                      occurrenceValue: _occurrenceValue != ''
                          ? int.parse(_occurrenceValue)
                          : null,
                      frequencyValue: int.parse(_frequencyValue),
                      frequencyUnit: _frequencyUnit,
                      isExpense: _isExpense,
                      payee: _payee,
                      amount: double.parse(_amount),
                      cid: _cid ??
                          (_correspondingCategory != null
                              ? _correspondingCategory.cid
                              : _enabledCategories.first.cid),
                      uid: _user.uid,
                    );
                    isEditMode
                        ? DatabaseWrapper(_user.uid)
                            .updateRecurringTransactions([recTx])
                        : DatabaseWrapper(_user.uid)
                            .addRecurringTransactions([recTx]);
                    RecurringTransactionsService.checkRecurringTransactions(
                        _user.uid);
                    SyncService(_user.uid).syncRecurringTransactions();
                  } else {
                    Transaction tx = Transaction(
                      tid: givenTxOrRecTx.tid ?? Uuid().v1(),
                      date: _date,
                      isExpense: _isExpense,
                      payee: _payee,
                      amount: double.parse(_amount),
                      cid: _cid ??
                          (_correspondingCategory != null
                              ? _correspondingCategory.cid
                              : _enabledCategories.first.cid),
                      uid: _user.uid,
                    );
                    isEditMode
                        ? await DatabaseWrapper(_user.uid)
                            .updateTransactions([tx])
                        : await DatabaseWrapper(_user.uid)
                            .addTransactions([tx]);
                    SyncService(_user.uid).syncTransactions();
                  }

                  Navigator.pop(context);
                }
              },
            ),
            if (isRecurringTxMode) ...[
              SizedBox(height: 10.0),
              RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  'Reset End Conditions',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  setState(() {
                    _endDate = givenTxOrRecTx.endDate;
                    _occurrenceValue = givenTxOrRecTx.occurrenceValue != null
                        ? givenTxOrRecTx.occurrenceValue.toString()
                        : '';
                  });
                  _occurrenceValueController.text =
                      givenTxOrRecTx.occurrenceValue != null
                          ? givenTxOrRecTx.occurrenceValue.toString()
                          : '';
                },
              ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: title(isRecurringTxMode, isEditMode),
        actions: isEditMode
            ? <Widget>[
                DeleteIcon(
                  context,
                  itemDesc: isRecurringTxMode
                      ? 'recurring transaction'
                      : 'transaction',
                  deleteFunction: () async => isRecurringTxMode
                      ? await DatabaseWrapper(_user.uid)
                          .deleteRecurringTransactions([givenTxOrRecTx])
                      : await DatabaseWrapper(_user.uid)
                          .deleteTransactions([givenTxOrRecTx]),
                  syncFunction: isRecurringTxMode
                      ? SyncService(_user.uid).syncRecurringTransactions
                      : SyncService(_user.uid).syncTransactions,
                ),
              ]
            : null,
      ),
      body: _body,
    );
  }

  Widget title(bool isRecurringTxMode, bool isEditMode) {
    final String recurring = isRecurringTxMode ? 'Recurring ' : '';
    return Text(isEditMode
        ? 'Edit ${recurring}Transaction'
        : 'Add ${recurring}Transaction');
  }
}

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
