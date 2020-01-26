import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:fund_tracker/shared/mainDrawer.dart';
import 'package:provider/provider.dart';

class PreferencesForm extends StatefulWidget {
  @override
  _PreferencesFormState createState() => _PreferencesFormState();
}

class _PreferencesFormState extends State<PreferencesForm> {
  final _formKey = GlobalKey<FormState>();

  String _limitDays = '';
  String _limitPeriods = '';
  bool _isLimitDaysEnabled;
  bool _isLimitPeriodsEnabled;
  bool _wasUpdated = false;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final _prefs = Provider.of<Preferences>(context);

    return Scaffold(
      drawer: MainDrawer(_user),
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: _prefs == null
          ? Loader()
          : Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 10.0,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    SwitchListTile(
                        title: Text('Limit # of days shown on Records'),
                        subtitle: Text('Current value: ${_prefs.limitDays}'),
                        value: _isLimitDaysEnabled ?? _prefs.isLimitDaysEnabled,
                        onChanged: (val) {
                          setState(() {
                            _isLimitDaysEnabled = val;
                            if (_isLimitDaysEnabled && _isLimitPeriodsEnabled) {
                              _isLimitPeriodsEnabled = false;
                            }
                          });
                        }),
                    TextFormField(
                      initialValue: _prefs.limitDays.toString(),
                      autovalidate: _limitDays.isNotEmpty,
                      validator: checkIfInteger,
                      decoration: InputDecoration(
                        labelText: '# days of visible transactions',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() => _limitDays = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    SwitchListTile(
                        title: Text('Limit # of periods shown on Records'),
                        subtitle: Text('Current value: ${_prefs.limitPeriods}'),
                        value: _isLimitPeriodsEnabled ??
                            _prefs.isLimitPeriodsEnabled,
                        onChanged: (val) {
                          setState(() {
                            _isLimitPeriodsEnabled = val;
                            if (_isLimitPeriodsEnabled && _isLimitDaysEnabled) {
                              _isLimitDaysEnabled = false;
                            }
                          });
                        }),
                    TextFormField(
                      initialValue: _prefs.limitPeriods.toString(),
                      autovalidate: _limitPeriods.isNotEmpty,
                      validator: checkIfInteger,
                      decoration: InputDecoration(
                        labelText: '# periods of visible transactions',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() => _limitPeriods = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child:
                          Text('Save', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          Preferences prefs = Preferences(
                            pid: _user.uid,
                            limitDays: _limitDays != ''
                                ? int.parse(_limitDays)
                                : _prefs.limitDays,
                            isLimitDaysEnabled: _isLimitDaysEnabled ??
                                _prefs.isLimitDaysEnabled,
                            limitPeriods: _limitPeriods != ''
                                ? int.parse(_limitPeriods)
                                : _prefs.limitPeriods,
                            isLimitPeriodsEnabled: _isLimitPeriodsEnabled ??
                                _prefs.isLimitPeriodsEnabled,
                          );
                          DatabaseWrapper(_user.uid).updatePreferences(prefs);
                          displayUpdated();
                        }
                      },
                    ),
                    SizedBox(height: 20.0),
                    _wasUpdated ? Center(child: Text('Updated!')) : Container(),
                    SizedBox(height: 60.0),
                    RaisedButton(
                      child: Text('Reset Categories'),
                      onPressed: () {
                        DatabaseWrapper(_user.uid).resetCategories();
                      },
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      child: Text('Reset Preferences'),
                      onPressed: () {
                        DatabaseWrapper(_user.uid).resetPreferences();
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void displayUpdated() {
    setState(() => _wasUpdated = true);
    Future.delayed(
      Duration(seconds: 1),
      () => setState(() => _wasUpdated = false),
    );
  }
}
