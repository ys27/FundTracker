import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
  String _durationValue = '';
  DateUnit _durationUnit;
  bool _isDefault;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final isEditMode = !widget.period.equalTo(Period.empty());

    return Scaffold(
      appBar: AppBar(
        title: title(isEditMode),
        actions: isEditMode
            ? <Widget>[
                deleteIcon(
                  context,
                  'custom period',
                  () =>
                      DatabaseWrapper(_user.uid).deletePeriods([widget.period]),
                  () => SyncService(_user.uid).syncPeriods(),
                )
              ]
            : null,
      ),
      body: isLoading
          ? Loader()
          : Container(
              padding: formPadding,
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    datePicker(
                      context,
                      'Start Date:                         ',
                      '${getDateStr(_startDate ?? widget.period.startDate)}',
                      (date) => setState(() => _startDate = date),
                      DateTime.now(),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: widget.period.name,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter a name for this period.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (val) {
                        setState(() => _name = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: widget.period.durationValue != null
                          ? widget.period.durationValue.toString()
                          : '',
                      autovalidate: _durationValue.isNotEmpty,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter a value for the duration.';
                        } else if (val.contains('.')) {
                          return 'This value must be an integer.';
                        } else if (int.parse(val) <= 0) {
                          return 'This value must be greater than 0';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Duration',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() => _durationValue = val);
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
                        setState(() => _durationUnit = val);
                      },
                      value: _durationUnit ?? widget.period.durationUnit,
                      isExpanded: true,
                    ),
                    SizedBox(height: 20.0),
                    SwitchListTile(
                        title: Text('Set to default (allowed: 1)'),
                        value: _isDefault ?? widget.period.isDefault,
                        onChanged: (val) {
                          setState(() => _isDefault = val);
                        }),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        isEditMode ? 'Save' : 'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          Period period = Period(
                            pid: widget.period.pid ?? Uuid().v1(),
                            name: _name ?? widget.period.name,
                            startDate: _startDate ?? widget.period.startDate,
                            durationValue: _durationValue != ''
                                ? int.parse(_durationValue)
                                : widget.period.durationValue,
                            durationUnit:
                                _durationUnit ?? widget.period.durationUnit,
                            isDefault: _isDefault ?? widget.period.isDefault,
                            uid: _user.uid,
                          );

                          setState(() => isLoading = true);
                          isEditMode
                              ? DatabaseWrapper(_user.uid)
                                  .updatePeriods([period])
                              : DatabaseWrapper(_user.uid).addPeriods([period]);
                          SyncService(_user.uid).syncPeriods();
                          if (period.isDefault) {
                            DatabaseWrapper(_user.uid)
                                .setRemainingNotDefault(period);
                          }
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget title(bool isEditMode) {
    return Text(isEditMode ? 'Edit Period' : 'Add Period');
  }
}
