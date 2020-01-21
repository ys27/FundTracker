import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/mainDrawer.dart';
import 'package:provider/provider.dart';

class Preferences extends StatefulWidget {
  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    return Scaffold(
      drawer: MainDrawer(_user),
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
        ),
        child: ListView(
          children: <Widget>[
            RaisedButton(
              child: Text('Reset Categories'),
              onPressed: () {
                DatabaseWrapper(_user.uid, DatabaseType.Local).removeAllCategories();
                DatabaseWrapper(_user.uid, DatabaseType.Local).addDefaultCategories();
              },
            ),
          ],
        ),
      ),
    );
  }
}
