import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';

class PeriodForm extends StatefulWidget {
  final Period period;

  PeriodForm(this.period);

  @override
  _PeriodFormState createState() => _PeriodFormState();
}

class _PeriodFormState extends State<PeriodForm> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  DateTime _startDate;
  int _durationValue;
  DurationUnit _durationUnit;
  bool _isDefault;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final isEditMode = widget.period.pid != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Period' : 'Add Period'),
        actions: isEditMode
            ? <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  child: Icon(Icons.delete),
                  onPressed: () async {
                    setState(() => isLoading = true);
                    DatabaseWrapper(_user.uid).deletePeriod(widget.period);
                    Navigator.pop(context);
                  },
                )
              ]
            : null,
      ),
      body: isLoading
          ? Loader()
          : Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 50.0,
              ),
              child: Form(
                key: _formKey,
                child: Container(),
                // child: ListView(
                //   children: <Widget>[
                //     SizedBox(height: 20.0),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                //       children: <Widget>[
                //         Expanded(
                //           child: FlatButton(
                //             padding: EdgeInsets.all(15.0),
                //             color: (_isExpense ?? widget.period.isExpense)
                //                 ? Colors.grey[100]
                //                 : Theme.of(context).primaryColor,
                //             child: Text(
                //               'Income',
                //               style: TextStyle(
                //                   fontWeight:
                //                       (_isExpense ?? widget.period.isExpense)
                //                           ? FontWeight.normal
                //                           : FontWeight.bold,
                //                   color: (_isExpense ?? widget.period.isExpense)
                //                       ? Colors.black
                //                       : Colors.white),
                //             ),
                //             onPressed: () => setState(() => _isExpense = false),
                //           ),
                //         ),
                //         Expanded(
                //           child: FlatButton(
                //             padding: EdgeInsets.all(15.0),
                //             color: (_isExpense ?? widget.period.isExpense)
                //                 ? Theme.of(context).primaryColor
                //                 : Colors.grey[100],
                //             child: Text(
                //               'Expense',
                //               style: TextStyle(
                //                 fontWeight:
                //                     (_isExpense ?? widget.period.isExpense)
                //                         ? FontWeight.bold
                //                         : FontWeight.normal,
                //                 color: (_isExpense ?? widget.period.isExpense)
                //                     ? Colors.white
                //                     : Colors.black,
                //               ),
                //             ),
                //             onPressed: () => setState(() => _isExpense = true),
                //           ),
                //         )
                //       ],
                //     ),
                //     SizedBox(height: 20.0),
                //     FlatButton(
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Text(
                //               '${(_date ?? widget.period.date).year.toString()}.${(_date ?? widget.period.date).month.toString()}.${(_date ?? widget.period.date).day.toString()}'),
                //           Icon(Icons.date_range),
                //         ],
                //       ),
                //       onPressed: () async {
                //         DateTime date = await showDatePicker(
                //           context: context,
                //           initialDate: new DateTime.now(),
                //           firstDate: DateTime.now().subtract(
                //             Duration(days: 365),
                //           ),
                //           lastDate: DateTime.now().add(
                //             Duration(days: 365),
                //           ),
                //         );
                //         if (date != null) {
                //           setState(() => _date = date);
                //         }
                //       },
                //     ),
                //     SizedBox(height: 20.0),
                //     TextFormField(
                //       initialValue: widget.period.payee,
                //       validator: (val) {
                //         if (val.isEmpty) {
                //           return 'Enter a payee or a note.';
                //         }
                //         return null;
                //       },
                //       decoration: InputDecoration(
                //         labelText: 'Payee',
                //       ),
                //       textCapitalization: TextCapitalization.words,
                //       onChanged: (val) {
                //         setState(() => _payee = val);
                //       },
                //     ),
                //     SizedBox(height: 20.0),
                //     TextFormField(
                //       initialValue: widget.period.amount != null
                //           ? widget.period.amount.toStringAsFixed(2)
                //           : null,
                //       autovalidate: _amount != null,
                //       validator: (val) {
                //         if (val.isEmpty) {
                //           return 'Please enter an amount.';
                //         }
                //         if (val.indexOf('.') > 0 &&
                //             val.split('.')[1].length > 2) {
                //           return 'At most 2 decimal places allowed.';
                //         }
                //         return null;
                //       },
                //       decoration: InputDecoration(
                //         labelText: 'Amount',
                //       ),
                //       keyboardType: TextInputType.number,
                //       onChanged: (val) {
                //         setState(() => _amount = double.parse(val));
                //       },
                //     ),
                //     SizedBox(height: 20.0),
                //     RaisedButton(
                //       color: Theme.of(context).primaryColor,
                //       child: Text(
                //         isEditMode ? 'Save' : 'Add',
                //         style: TextStyle(color: Colors.white),
                //       ),
                //       onPressed: () async {
                //         if (_formKey.currentState.validate()) {
                //           Transaction tx = Transaction(
                //             tid: widget.period.tid ?? new Uuid().v1(),
                //             date: _date ?? widget.period.date,
                //             isExpense: _isExpense ?? widget.period.isExpense,
                //             payee: _payee ?? widget.period.payee,
                //             amount: _amount ?? widget.period.amount,
                //             category: _category ??
                //                 widget.period.category ??
                //                 _enabledCategories.first.name,
                //             uid: _user.uid,
                //           );

                //           setState(() => isLoading = true);
                //           isEditMode
                //               ? DatabaseWrapper(_user.uid).updateTransaction(tx)
                //               : DatabaseWrapper(_user.uid).addTransaction(tx);
                //           goHome(context);
                //         }
                //       },
                //     )
                //   ],
                // ),
              ),
            ),
    );
  }
}
