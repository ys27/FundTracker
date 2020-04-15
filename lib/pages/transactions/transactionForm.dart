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
import 'package:fund_tracker/shared/widgets.dart';
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

  DateTime _nextDate;
  String _frequencyValue = '';
  DateUnit _frequencyUnit;

  DateTime _date;

  bool _isExpense;
  String _payee = '';
  double _amount;
  String _cid;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final dynamic currentTxOrRecTx = widget.getTxOrRecTx();
    _payeeController.text = currentTxOrRecTx.payee ?? '';
    _amountController.text = currentTxOrRecTx.amount != null
        ? currentTxOrRecTx.amount.toStringAsFixed(2)
        : null;
    _frequencyValueController.text = currentTxOrRecTx is RecurringTransaction
        ? (currentTxOrRecTx.frequencyValue != null
            ? currentTxOrRecTx.frequencyValue.toString()
            : '')
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final dynamic currentTxOrRecTx = widget.getTxOrRecTx();
    final bool isRecurringTxMode = currentTxOrRecTx is RecurringTransaction;
    final bool isEditMode = isRecurringTxMode
        ? currentTxOrRecTx.rid != null
        : currentTxOrRecTx.tid != null;
    final List<Transaction> _transactions =
        Provider.of<List<Transaction>>(context);
    final List<Category> _categories = Provider.of<List<Category>>(context);

    Widget _body = Loader();

    if (_transactions != null && _categories != null) {
      final List<Category> _enabledCategories =
          _categories.where((category) => category.enabled).toList();
      final Category _correspondingCategory =
          getCategory(_categories, currentTxOrRecTx.cid);

      _body = Container(
        padding: formPadding,
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
                  SizedBox(height: 10.0),
                  tabSelector(context, [
                    {
                      'enabled': _isExpense != null
                          ? !_isExpense
                          : !currentTxOrRecTx.isExpense,
                      'title': 'Income',
                      'onPressed': () => setState(() => _isExpense = false),
                    },
                    {
                      'enabled': _isExpense ?? currentTxOrRecTx.isExpense,
                      'title': 'Expense',
                      'onPressed': () => setState(() => _isExpense = true),
                    },
                  ]),
                  SizedBox(height: 10.0),
                  datePicker(
                    context,
                    leading: isRecurringTxMode
                        ? 'Next Date:                         '
                        : getDateStr(_date ?? currentTxOrRecTx.date),
                    trailing: isRecurringTxMode
                        ? '${getDateStr(_nextDate ?? currentTxOrRecTx.nextDate)}'
                        : '',
                    updateDateState: (date) => setState(() {
                      if (isRecurringTxMode) {
                        _nextDate = getDateNotTime(date);
                      } else {
                        _date = date;
                      }
                    }),
                    openDate: DateTime.now(),
                    firstDate: isRecurringTxMode
                        ? getDateNotTime(DateTime.now())
                        : null,
                  ),
                ] +
                (isRecurringTxMode
                    ? <Widget>[]
                    : <Widget>[
                        SizedBox(height: 10.0),
                        timePicker(
                          context,
                          getTimeStr(_date ?? currentTxOrRecTx.date),
                          '',
                          (time) => setState(
                            () {
                              DateTime oldDateTime =
                                  (_date ?? currentTxOrRecTx.date);
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
                      ]) +
                <Widget>[
                  SizedBox(height: 10.0),
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
                      decoration: clearInput(
                        labelText: 'Payee',
                        enabled: _payee.isNotEmpty,
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
                          (tx) => tx.payee
                              .toLowerCase()
                              .startsWith(query.toLowerCase()),
                        )
                            .forEach((tx) {
                          final String suggestion = '${tx.payee}::${tx.cid}';
                          final int suggestionIndex =
                              suggestionsWithCount.indexWhere(
                                  (map) => map['suggestion'] == suggestion);
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
                      final List<String> splitSuggestion =
                          suggestion.split('::');
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
                      final List<String> splitSuggestion =
                          suggestion.split('::');
                      final String suggestionPayee = splitSuggestion[0];
                      final String suggestionCid = splitSuggestion[1];

                      _payeeController.text = suggestionPayee;
                      setState(() {
                        _payee = suggestionPayee;
                        _cid = suggestionCid;
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _amountController,
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
                    decoration: clearInput(
                      labelText: 'Amount',
                      enabled: _amount != null,
                      onPressed: () {
                        setState(() => _amount = null);
                        _amountController.safeClear();
                      },
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        _amount = val == '' ? null : double.parse(val);
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: DropdownButton<String>(
                      items: _enabledCategories.map((category) {
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
                          }).toList() +
                          (_correspondingCategory == null ||
                                  _enabledCategories.any((category) =>
                                      category.cid ==
                                      _correspondingCategory.cid)
                              ? []
                              : [
                                  DropdownMenuItem(
                                    value: _correspondingCategory.cid,
                                    child: Row(
                                      children: <Widget>[
                                        () {
                                          return Icon(
                                            IconData(
                                              _correspondingCategory.icon,
                                              fontFamily:
                                                  'MaterialDesignIconFont',
                                              fontPackage:
                                                  'community_material_icon',
                                            ),
                                            color: _correspondingCategory
                                                .iconColor,
                                          );
                                        }(),
                                        SizedBox(width: 10.0),
                                        Text(_correspondingCategory.name),
                                      ],
                                    ),
                                  )
                                ]),
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
                ] +
                (isRecurringTxMode
                    ? <Widget>[
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: _frequencyValueController,
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
                          decoration: clearInput(
                            labelText: 'Frequency',
                            enabled: _frequencyValue.isNotEmpty,
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
                          value:
                              _frequencyUnit ?? currentTxOrRecTx.frequencyUnit,
                          isExpanded: true,
                        ),
                      ]
                    : <Widget>[]) +
                <Widget>[
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
                            rid: currentTxOrRecTx.rid ?? Uuid().v1(),
                            nextDate: _nextDate ?? currentTxOrRecTx.nextDate,
                            frequencyValue: _frequencyValue != ''
                                ? int.parse(_frequencyValue)
                                : currentTxOrRecTx.frequencyValue,
                            frequencyUnit: _frequencyUnit ??
                                currentTxOrRecTx.frequencyUnit,
                            isExpense: _isExpense ?? currentTxOrRecTx.isExpense,
                            payee: _payee ?? currentTxOrRecTx.payee,
                            amount: _amount ?? currentTxOrRecTx.amount,
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
                          RecurringTransactionsService
                              .checkRecurringTransactions(_user.uid);
                          SyncService(_user.uid).syncRecurringTransactions();
                        } else {
                          Transaction tx = Transaction(
                            tid: currentTxOrRecTx.tid ?? Uuid().v1(),
                            date: _date ?? currentTxOrRecTx.date,
                            isExpense: _isExpense ?? currentTxOrRecTx.isExpense,
                            payee: _payee ?? currentTxOrRecTx.payee,
                            amount: _amount ?? currentTxOrRecTx.amount,
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
                ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: title(isRecurringTxMode, isEditMode),
        actions: isEditMode
            ? <Widget>[
                deleteIcon(
                  context,
                  isRecurringTxMode ? 'recurring transaction' : 'transaction',
                  () async => isRecurringTxMode
                      ? await DatabaseWrapper(_user.uid)
                          .deleteRecurringTransactions([currentTxOrRecTx])
                      : await DatabaseWrapper(_user.uid)
                          .deleteTransactions([currentTxOrRecTx]),
                  () => isRecurringTxMode
                      ? SyncService(_user.uid).syncRecurringTransactions()
                      : SyncService(_user.uid).syncTransactions(),
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
