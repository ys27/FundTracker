import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PeriodForm extends StatefulWidget {
  final Period period;

  PeriodForm({this.period});

  @override
  _PeriodFormState createState() => _PeriodFormState();
}

class _PeriodFormState extends State<PeriodForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationValueController = TextEditingController();

  final FocusNode _nameFocus = new FocusNode();
  final FocusNode _durationValueFocus = new FocusNode();

  bool _isNameInFocus = false;
  bool _isDurationValueInFocus = false;

  String _name;
  DateTime _startDate;
  String _durationValue;
  DateUnit _durationUnit;
  bool _isDefault;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _name = widget.period.name ?? '';
    _startDate = widget.period.startDate;
    _durationValue = widget.period.durationValue != null
        ? widget.period.durationValue.toString()
        : '';
    _durationUnit = widget.period.durationUnit;
    _isDefault =
        widget.period.isDefault != null ? widget.period.isDefault : false;

    _nameController.text = widget.period.name;
    _durationValueController.text = widget.period.durationValue != null
        ? widget.period.durationValue.toString()
        : '';

    _nameFocus.addListener(_checkFocus);
    _durationValueFocus.addListener(_checkFocus);
  }

  void _checkFocus() {
    setState(() {
      _isNameInFocus = _nameFocus.hasFocus;
      _isDurationValueInFocus = _durationValueFocus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseAuthentication.User>(context);
    final isEditMode = !widget.period.equalTo(Period.empty());

    return Scaffold(
      appBar: AppBar(
        title: title(isEditMode),
        actions: isEditMode
            ? <Widget>[
                DeleteIcon(
                  context,
                  itemDesc: 'custom period',
                  deleteFunction: () =>
                      DatabaseWrapper(_user.uid).deletePeriods([widget.period]),
                  syncFunction: SyncService(_user.uid).syncPeriods,
                )
              ]
            : null,
      ),
      body: isLoading
          ? Loader()
          : Form(
              key: _formKey,
              child: ListView(
                padding: formPadding,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  DatePicker(
                    context,
                    leading: 'Start Date: ',
                    trailing: '${getDateStr(_startDate)}',
                    updateDateState: (date) =>
                        setState(() => _startDate = date),
                    openDate: DateTime.now(),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    autovalidate: _name.isNotEmpty,
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Enter a name for this period.';
                      }
                      return null;
                    },
                    decoration: clearInput(
                      labelText: 'Name',
                      enabled: _name.isNotEmpty && _isNameInFocus,
                      onPressed: () {
                        setState(() => _name = '');
                        _nameController.safeClear();
                      },
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (val) {
                      setState(() => _name = val);
                    },
                  ),
                  TextFormField(
                    controller: _durationValueController,
                    focusNode: _durationValueFocus,
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
                    decoration: clearInput(
                      labelText: 'Duration',
                      enabled:
                          _durationValue.isNotEmpty && _isDurationValueInFocus,
                      onPressed: () {
                        setState(() => _durationValue = '');
                        _durationValueController.safeClear();
                      },
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() => _durationValue = val);
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
                      setState(() => _durationUnit = val);
                    },
                    value: _durationUnit,
                    isExpanded: true,
                  ),
                  SizedBox(height: 10.0),
                  SwitchListTile(
                    title: Text('Set to default (allowed: 1)'),
                    value: _isDefault,
                    onChanged: (val) {
                      setState(() => _isDefault = val);
                    },
                  ),
                  SizedBox(height: 10.0),
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
                          name: _name,
                          startDate: _startDate,
                          durationValue: _durationValue != ''
                              ? int.parse(_durationValue)
                              : widget.period.durationValue,
                          durationUnit: _durationUnit,
                          isDefault: _isDefault,
                          uid: _user.uid,
                        );
                        setState(() => isLoading = true);
                        isEditMode
                            ? await DatabaseWrapper(_user.uid)
                                .updatePeriods([period])
                            : await DatabaseWrapper(_user.uid)
                                .addPeriods([period]);
                        SyncService(_user.uid).syncPeriods();
                        if (period.isDefault) {
                          await DatabaseWrapper(_user.uid)
                              .setRemainingNotDefault(period);
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

  Widget title(bool isEditMode) {
    return Text(isEditMode ? 'Edit Period' : 'Add Period');
  }
}

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
