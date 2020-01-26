import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
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
                    TextFormField(
                      initialValue: _prefs.limitDays.toString(),
                      autovalidate: _limitDays.isNotEmpty,
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
                        labelText: '# days of visible transactions',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() => _limitDays = val);
                      },
                    ),
                    Text('Current Value: ${_prefs.limitDays}'),
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
                          );
                          DatabaseWrapper(_user.uid).updatePreferences(prefs);
                          displayUpdated();
                        }
                      },
                    ),
                    SizedBox(height: 60.0),
                    RaisedButton(
                      child: Text('Reset Categories'),
                      onPressed: () {
                        DatabaseWrapper(_user.uid).resetCategories();
                        displayUpdated();
                      },
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      child: Text('Reset Preferences'),
                      onPressed: () {
                        DatabaseWrapper(_user.uid).resetPreferences();
                        displayUpdated();
                      },
                    ),
                    SizedBox(height: 20.0),
                    _wasUpdated ? Center(child: Text('Updated!')) : Container(),
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
