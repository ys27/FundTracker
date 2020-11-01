import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication
    show User;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/plannedTransaction.dart';
import 'package:fund_tracker/models/suggestion.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/plannedTransactions.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final List<Suggestion> hiddenSuggestions;
  final Function getTxOrRecTx;

  TransactionForm({this.hiddenSuggestions, this.getTxOrRecTx});

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
  bool _addSuggestion;

  bool _suggestionUsed;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final dynamic givenTxOrRecTx = widget.getTxOrRecTx();

    if (givenTxOrRecTx is PlannedTransaction) {
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
    _addSuggestion = widget.hiddenSuggestions
            .where((suggestion) =>
                suggestion.payee == _payee && suggestion.cid == _cid)
            .length ==
        0;

    _payeeController.text = givenTxOrRecTx.payee ?? '';
    _amountController.text = givenTxOrRecTx.amount != null
        ? givenTxOrRecTx.amount.toStringAsFixed(2)
        : null;
    _frequencyValueController.text = givenTxOrRecTx is PlannedTransaction
        ? (givenTxOrRecTx.frequencyValue != null
            ? givenTxOrRecTx.frequencyValue.toString()
            : '')
        : '';
    _occurrenceValueController.text = givenTxOrRecTx is PlannedTransaction
        ? (givenTxOrRecTx.occurrenceValue != null
            ? givenTxOrRecTx.occurrenceValue.toString()
            : '')
        : '';

    _payeeFocus.addListener(_checkFocus);
    _amountFocus.addListener(_checkFocus);
    _frequencyValueFocus.addListener(_checkFocus);
    _occurrenceValueFocus.addListener(_checkFocus);

    _suggestionUsed = false;
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
    final _user = Provider.of<FirebaseAuthentication.User>(context);
    final dynamic givenTxOrRecTx = widget.getTxOrRecTx();
    final bool isPlannedTxMode = givenTxOrRecTx is PlannedTransaction;
    final bool isEditMode = isPlannedTxMode
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
              leading: isPlannedTxMode ? 'Next Date: ' : getDateStr(_date),
              trailing: isPlannedTxMode ? '${getDateStr(_nextDate)}' : '',
              updateDateState: (date) => setState(() {
                if (isPlannedTxMode) {
                  _nextDate = getDateNotTime(date);
                } else {
                  _date = date;
                }
              }),
              openDate: DateTime.now(),
              firstDate:
                  isPlannedTxMode ? getDateNotTime(DateTime.now()) : null,
            ),
            if (!isPlannedTxMode) ...[
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
                    setState(() {
                      _payee = '';
                      _suggestionUsed = false;
                    });
                    _payeeController.safeClear();
                  },
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (val) {
                  setState(() {
                    _payee = val;
                    _suggestionUsed = false;
                  });
                },
              ),
              suggestionsCallback: (query) {
                if (query == '') {
                  return null;
                } else {
                  List<Map<String, dynamic>> suggestions = getSuggestions(
                    _transactions
                        .where(
                          (tx) => tx.payee
                              .toLowerCase()
                              .startsWith(query.toLowerCase()),
                        )
                        .toList(),
                    _user.uid,
                  );

                  suggestions.removeWhere((map) {
                    return widget.hiddenSuggestions
                            .where((hidden) =>
                                hidden.equalTo(map['suggestion'] as Suggestion))
                            .length >
                        0;
                  });

                  suggestions.sort((a, b) => b['count'].compareTo(a['count']));

                  final List<String> suggestionStrings = suggestions
                      .map((map) => map['suggestion'].sid as String)
                      .toList();

                  return suggestionStrings.length > 0
                      ? suggestionStrings
                      : null;
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
                  _suggestionUsed = true;
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
                  setState(() {
                    _cid = val;
                    _suggestionUsed = false;
                  });
                },
                value: _cid ??
                    (_correspondingCategory != null
                        ? _correspondingCategory.cid
                        : _enabledCategories.first.cid),
                isExpanded: true,
              ),
            ),
            if (isPlannedTxMode) ...[
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
                leading: 'End Date: ',
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
            if (!isEditMode && !_suggestionUsed || isEditMode) ...[
              SwitchListTile(
                title: Text('Add suggestion'),
                value: _addSuggestion,
                onChanged: (val) {
                  setState(() => _addSuggestion = val);
                },
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
                  String cid = _cid ??
                      (_correspondingCategory != null
                          ? _correspondingCategory.cid
                          : _enabledCategories.first.cid);
                  if (isPlannedTxMode) {
                    PlannedTransaction plannedTx = PlannedTransaction(
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
                      cid: cid,
                      uid: _user.uid,
                    );
                    isEditMode
                        ? DatabaseWrapper(_user.uid)
                            .updatePlannedTransactions([plannedTx])
                        : DatabaseWrapper(_user.uid)
                            .addPlannedTransactions([plannedTx]);
                    PlannedTransactionsService.checkPlannedTransactions(
                        _user.uid);
                    SyncService(_user.uid).syncPlannedTransactions();
                  } else {
                    Transaction tx = Transaction(
                      tid: givenTxOrRecTx.tid ?? Uuid().v1(),
                      date: _date,
                      isExpense: _isExpense,
                      payee: _payee,
                      amount: double.parse(_amount),
                      cid: cid,
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
                  if (!isEditMode && !_suggestionUsed || isEditMode) {
                    Suggestion suggestionToAdd = Suggestion(
                      sid: '$_payee::$cid',
                      payee: _payee,
                      cid: cid,
                      uid: _user.uid,
                    );
                    if (!_addSuggestion) {
                      await DatabaseWrapper(_user.uid).addHiddenSuggestions(
                        [suggestionToAdd],
                      );
                    } else if (widget.hiddenSuggestions
                            .where((hidden) => hidden.equalTo(suggestionToAdd))
                            .length >
                        0) {
                      await DatabaseWrapper(_user.uid).deleteHiddenSuggestions(
                        [suggestionToAdd],
                      );
                    }
                  }
                }
              },
            ),
            if (isPlannedTxMode) ...[
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
        title: title(isPlannedTxMode, isEditMode),
        actions: isEditMode
            ? <Widget>[
                DeleteIcon(
                  context,
                  itemDesc:
                      isPlannedTxMode ? 'planned transaction' : 'transaction',
                  deleteFunction: () async => isPlannedTxMode
                      ? await DatabaseWrapper(_user.uid)
                          .deletePlannedTransactions([givenTxOrRecTx])
                      : await DatabaseWrapper(_user.uid)
                          .deleteTransactions([givenTxOrRecTx]),
                  syncFunction: isPlannedTxMode
                      ? SyncService(_user.uid).syncPlannedTransactions
                      : SyncService(_user.uid).syncTransactions,
                ),
              ]
            : null,
      ),
      body: _body,
    );
  }

  Widget title(bool isPlannedTxMode, bool isEditMode) {
    final String planned = isPlannedTxMode ? 'Planned ' : '';
    return Text(isEditMode
        ? 'Edit ${planned}Transaction'
        : 'Add ${planned}Transaction');
  }
}

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
