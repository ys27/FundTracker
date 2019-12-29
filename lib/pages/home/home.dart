import 'package:flutter/material.dart';
import 'package:fund_tracker/services/auth.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fund Tracker'),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () async {
              await _auth.logOut();
            },
            label: Text('Log out'),
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Center(
        child: Text('Fun'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
