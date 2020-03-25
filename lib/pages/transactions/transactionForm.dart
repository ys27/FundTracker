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
  final Transaction tx;
  final RecurringTransaction recTx;

  TransactionForm({this.tx, this.recTx});

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();

  DateTime _nextDate;
  String _frequencyValue = '';
  DateUnit _frequencyUnit;

  DateTime _date;

  bool _isExpense;
  String _payee;
  double _amount;
  String _cid;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final bool isRecurringTxMode = widget.recTx != null;
    final dynamic currentTxOrRecTx =
        isRecurringTxMode ? widget.recTx : widget.tx;
    _typeAheadController.text = currentTxOrRecTx.payee;
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final bool isRecurringTxMode = widget.recTx != null;
    final dynamic currentTxOrRecTx =
        isRecurringTxMode ? widget.recTx : widget.tx;
    final bool isEditMode = isRecurringTxMode
        ? !widget.recTx.equalTo(RecurringTransaction.empty())
        : widget.tx.tid != null;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      isExpenseSelector(
                        context,
                        _isExpense != null
                            ? !_isExpense
                            : !currentTxOrRecTx.isExpense,
                        'Income',
                        () => setState(() => _isExpense = false),
                      ),
                      isExpenseSelector(
                        context,
                        _isExpense ?? currentTxOrRecTx.isExpense,
                        'Expense',
                        () => setState(() => _isExpense = true),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  datePicker(
                    context,
                    isRecurringTxMode
                        ? 'Next Date:                         '
                        : getDateStr(_date ?? currentTxOrRecTx.date),
                    isRecurringTxMode
                        ? '${getDateStr(_nextDate ?? widget.recTx.nextDate)}'
                        : '',
                    (date) => setState(() {
                      if (isRecurringTxMode) {
                        _nextDate = getDateNotTime(date);
                      } else {
                        _date = date;
                      }
                    }),
                    DateTime.now(),
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
                    autovalidate: _payee != null,
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Enter a payee or a note.';
                      } else if (val.length > 30) {
                        return 'Max 30 characters.';
                      }
                      return null;
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _typeAheadController,
                      decoration: InputDecoration(
                        labelText: 'Payee',
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
                        final List<String> suggestions = _transactions
                            .where(
                              (tx) => tx.payee
                                  .toLowerCase()
                                  .startsWith(query.toLowerCase()),
                            )
                            .map((tx) => '${tx.payee}::${tx.cid}')
                            .toSet()
                            .toList();
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

                      _typeAheadController.text = suggestionPayee;
                      setState(() {
                        _payee = suggestionPayee;
                        _cid = suggestionCid;
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    initialValue: currentTxOrRecTx.amount != null
                        ? currentTxOrRecTx.amount.toStringAsFixed(2)
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
                          value: _frequencyUnit ?? widget.recTx.frequencyUnit,
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
                            tid: widget.tx.tid ?? Uuid().v1(),
                            date: _date ?? widget.tx.date,
                            isExpense: _isExpense ?? widget.tx.isExpense,
                            payee: _payee ?? widget.tx.payee,
                            amount: _amount ?? widget.tx.amount,
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
                          .deleteRecurringTransactions([widget.recTx])
                      : await DatabaseWrapper(_user.uid)
                          .deleteTransactions([widget.tx]),
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
