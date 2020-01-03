import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/drawer.dart';
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
      drawer: MainDrawer(),
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
                LocalDBService().removeAllCategories(_user.uid);
                LocalDBService().addDefaultCategories(_user.uid);
              },
            ),
          ],
        ),
      ),
    );
  }
}
