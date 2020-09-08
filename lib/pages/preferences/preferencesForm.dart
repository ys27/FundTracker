import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';

class PreferencesForm extends StatefulWidget {
  final FirebaseAuthentication.User user;
  final Function openPage;

  PreferencesForm({this.user, this.openPage});

  @override
  _PreferencesFormState createState() => _PreferencesFormState();
}

class _PreferencesFormState extends State<PreferencesForm> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  final FocusNode _limitFocus = new FocusNode();

  bool _isLimitInFocus = false;

  String _limit = '';
  String _limitDays = '';
  String _limitPeriods = '';
  DateTime _limitByDate;
  bool _isLimitDaysEnabled;
  bool _isLimitPeriodsEnabled;
  bool _isLimitByDateEnabled;
  bool _isDefaultTabAllTime = false;
  bool _isDefaultTabPeriod = false;
  bool _isDefaultTabCustom = false;
  bool _isOnlyExpenses;
  bool _wasUpdated = false;
  bool _isModified = false;

  Preferences _prefs;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);

    _limitFocus.addListener(_checkFocus);
  }

  void _checkFocus() {
    setState(() {
      _isLimitInFocus = _limitFocus.hasFocus;
    });
  }

  @override
  void dispose() {
    SyncService(widget.user.uid).syncPreferences();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Loader();

    if (_prefs != null) {
      _isLimitDaysEnabled = _isLimitDaysEnabled ?? _prefs.isLimitDaysEnabled;
      _isLimitPeriodsEnabled =
          _isLimitPeriodsEnabled ?? _prefs.isLimitPeriodsEnabled;
      _isLimitByDateEnabled =
          _isLimitByDateEnabled ?? _prefs.isLimitByDateEnabled;
      _isOnlyExpenses = _isOnlyExpenses ?? _prefs.isOnlyExpenses;

      if (!_isDefaultTabAllTime &&
          !_isDefaultTabPeriod &&
          !_isDefaultTabCustom) {
        if (_prefs.defaultCustomLimitTab == LimitTab.AllTime) {
          _isDefaultTabAllTime = true;
        } else if (_prefs.defaultCustomLimitTab == LimitTab.Period) {
          _isDefaultTabPeriod = true;
        } else if (_prefs.defaultCustomLimitTab == LimitTab.Custom) {
          _isDefaultTabCustom = true;
        } else {
          _isDefaultTabPeriod = true;
        }
      }

      _body = Container(
        padding: bodyPadding,
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 10.0),
              Center(
                child: Text('Custom Range For Statistics'),
              ),
              SizedBox(height: 10.0),
              TabSelector(
                context,
                tabs: [
                  {
                    'enabled': _isLimitDaysEnabled,
                    'title': 'Days',
                    'onPressed': () => setState(() {
                          _isModified = true;
                          _isLimitDaysEnabled = true;
                          _isLimitPeriodsEnabled = false;
                          _isLimitByDateEnabled = false;
                        }),
                  },
                  {
                    'enabled': _isLimitPeriodsEnabled,
                    'title': 'Periods',
                    'onPressed': () => setState(() {
                          _isModified = true;
                          _isLimitDaysEnabled = false;
                          _isLimitPeriodsEnabled = true;
                          _isLimitByDateEnabled = false;
                        }),
                  },
                  {
                    'enabled': _isLimitByDateEnabled,
                    'title': 'Start Date',
                    'onPressed': () => setState(() {
                          _isModified = true;
                          _isLimitDaysEnabled = false;
                          _isLimitPeriodsEnabled = false;
                          _isLimitByDateEnabled = true;
                        }),
                  },
                ],
              ),
              _isLimitByDateEnabled
                  ? Column(
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        DatePicker(
                          context,
                          leading:
                              getDateStr(_limitByDate ?? _prefs.limitByDate),
                          updateDateState: (date) => setState(() {
                            _isModified = true;
                            _limitByDate = getDateNotTime(date);
                          }),
                          openDate: DateTime.now(),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    )
                  : TextFormField(
                      controller: _limitController,
                      focusNode: _limitFocus,
                      autovalidate: _isLimitDaysEnabled
                          ? _limitDays.isNotEmpty
                          : _limitPeriods.isNotEmpty,
                      validator: (val) {
                        if (val.isNotEmpty) {
                          if (val.contains('.')) {
                            return 'This value must be an integer.';
                          } else if (int.parse(val) <= 0) {
                            return 'This value must be greater than 0';
                          }
                        }
                        return null;
                      },
                      decoration: clearInput(
                        labelText:
                            'Current Value: ${_isLimitDaysEnabled ? _prefs.limitDays : _prefs.limitPeriods}',
                        enabled: _limit.isNotEmpty && _isLimitInFocus,
                        onPressed: () {
                          setState(() => _limit = '');
                          _limitController.safeClear();
                        },
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() {
                          _isModified = true;
                          _limit = val;
                          if (_isLimitDaysEnabled) {
                            _limitDays = val;
                          } else {
                            _limitPeriods = val;
                          }
                        });
                      },
                    ),
              SizedBox(height: 30.0),
              Center(
                child: Text('Default Tab For Statistics'),
              ),
              SizedBox(height: 10.0),
              TabSelector(
                context,
                tabs: [
                  {
                    'enabled': _isDefaultTabAllTime,
                    'title': 'All-Time',
                    'onPressed': () => setState(() {
                          _isModified = true;
                          _isDefaultTabAllTime = true;
                          _isDefaultTabPeriod = false;
                          _isDefaultTabCustom = false;
                        }),
                  },
                  {
                    'enabled': _isDefaultTabPeriod,
                    'title': 'Period',
                    'onPressed': () => setState(() {
                          _isModified = true;
                          _isDefaultTabAllTime = false;
                          _isDefaultTabPeriod = true;
                          _isDefaultTabCustom = false;
                        }),
                  },
                  {
                    'enabled': _isDefaultTabCustom,
                    'title': 'Custom',
                    'onPressed': () => setState(() {
                          _isModified = true;
                          _isDefaultTabAllTime = false;
                          _isDefaultTabPeriod = false;
                          _isDefaultTabCustom = true;
                        }),
                  },
                ],
              ),
              SizedBox(height: 10.0),
              SwitchListTile(
                title: Text('Only expenses (default)'),
                value: _isOnlyExpenses,
                onChanged: (val) {
                  setState(() {
                    _isModified = true;
                    _isOnlyExpenses = val;
                  });
                },
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                color:
                    _isModified ? Theme.of(context).primaryColor : Colors.grey,
                child: Text('Save',
                    style: TextStyle(
                        color: _isModified ? Colors.white : Colors.grey[400])),
                onPressed: () async {
                  if (_isModified) {
                    if (_formKey.currentState.validate()) {
                      int limitDays = _limitDays != '' && _isLimitDaysEnabled
                          ? int.parse(_limitDays)
                          : _prefs.limitDays;
                      int limitPeriods =
                          _limitPeriods != '' && _isLimitPeriodsEnabled
                              ? int.parse(_limitPeriods)
                              : _prefs.limitPeriods;
                      DateTime limitByDate =
                          _limitByDate != null && _isLimitByDateEnabled
                              ? _limitByDate
                              : _prefs.limitByDate;

                      LimitTab defaultTab = LimitTab.Period;
                      if (_isDefaultTabAllTime) {
                        defaultTab = LimitTab.AllTime;
                      } else if (_isDefaultTabPeriod) {
                        defaultTab = LimitTab.Period;
                      } else if (_isDefaultTabCustom) {
                        defaultTab = LimitTab.Custom;
                      }

                      Preferences prefs = Preferences(
                        pid: widget.user.uid,
                        limitDays:
                            _isLimitDaysEnabled ? limitDays : _prefs.limitDays,
                        isLimitDaysEnabled: _isLimitDaysEnabled,
                        limitPeriods: _isLimitPeriodsEnabled
                            ? limitPeriods
                            : _prefs.limitPeriods,
                        isLimitPeriodsEnabled: _isLimitPeriodsEnabled,
                        limitByDate: _isLimitByDateEnabled
                            ? limitByDate
                            : _prefs.limitByDate,
                        isLimitByDateEnabled: _isLimitByDateEnabled,
                        defaultCustomLimitTab: defaultTab,
                        incomeUnfiltered: _prefs.incomeUnfiltered,
                        expensesUnfiltered: _prefs.expensesUnfiltered,
                        isOnlyExpenses: _isOnlyExpenses,
                      );
                      DatabaseWrapper(widget.user.uid).updatePreferences(prefs);
                      retrieveNewData(widget.user.uid);
                      setState(() => _isModified = false);
                    }
                  }
                },
              ),
              SizedBox(height: 10.0),
              _wasUpdated ? Center(child: Text('Updated!')) : Container(),
              SizedBox(height: 60.0),
              // RaisedButton(
              //   child: Text('Reset Categories'),
              //   onPressed: () async {
              //     bool hasBeenConfirmed = await showDialog(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return Alert('This will reset your categories.');
              //           },
              //         ) ??
              //         false;
              //     if (hasBeenConfirmed) {
              //       DatabaseWrapper(widget.user.uid).resetCategories();
              //     }
              //   },
              // ),
              // SizedBox(height: 10.0),
              RaisedButton(
                child: Text('Reset Preferences'),
                onPressed: () async {
                  bool hasBeenConfirmed = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Alert('This will reset your preferences.');
                        },
                      ) ??
                      false;
                  if (hasBeenConfirmed) {
                    await DatabaseWrapper(widget.user.uid).resetPreferences();
                    setState(() {
                      _isLimitDaysEnabled = null;
                      _isLimitPeriodsEnabled = null;
                      _isLimitByDateEnabled = null;
                    });
                  }
                },
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: MainDrawer(user: widget.user, openPage: widget.openPage),
      appBar: AppBar(title: Text('Preferences')),
      body: _body,
    );
  }

  void retrieveNewData(String uid) async {
    Preferences prefs = await DatabaseWrapper(uid).getPreferences();
    setState(() {
      _prefs = prefs;
    });
  }
}

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
