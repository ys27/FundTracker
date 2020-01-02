import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/preferences/categories.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqlite_api.dart';

import 'library.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _auth = AuthService();
  final LocalDBService _localDBService = LocalDBService();
  User user;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    if (user == null) {
      getUser(_user.uid);
    }

    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user != null ? user.fullname : ''),
            accountEmail: Text(user != null ? user.email : ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user != null ? user.fullname[0] : '',
                style: TextStyle(
                    fontSize: 40.0, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            leading: Icon(Icons.home),
            onTap: () => goHome(context),
          ),
          ListTile(
            title: Text('Categories'),
            leading: Icon(Icons.category),
            onTap: () => openPage(context, Categories()),
          ),
          ListTile(
            title: Text('Preferences'),
            leading: Icon(Icons.tune),
          ),
          ListTile(
            title: Text('Sign Out'),
            leading: Icon(Icons.person),
            onTap: () async {
              Navigator.pop(context);
              await _auth.signOut();
            },
          ),
        ],
      ),
    );
  }

  void getUser(String uid) {
    final Future<Database> dbFuture = _localDBService.initializeDBs();
    dbFuture.then((db) {
      Future<List<User>> usersFuture = _localDBService.findUser(uid);
      usersFuture.then((users) {
        setState(() => user = users.first);
      });
    });
  }
}
