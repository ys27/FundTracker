import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:provider/provider.dart';

import 'loader.dart';

class MainDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    return Drawer(
      child: ListView(
        children: <Widget>[
          StreamBuilder<User>(
              stream: FireDBService(uid: _user.uid).user,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  User user = snapshot.data;
                  return UserAccountsDrawerHeader(
                    accountName: Text(user.fullname),
                    accountEmail: Text(user.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(user.fullname[0],
                          style: TextStyle(
                              fontSize: 40.0,
                              color: Theme.of(context).primaryColor)),
                    ),
                  );
                } else {
                  return Loader();
                }
              }),
          ListTile(
            title: Text('Home'),
            leading: Icon(Icons.home),
          ),
          ListTile(
            title: Text('Preferences'),
            leading: Icon(Icons.tune),
          ),
          ListTile(
            title: Text('Log out'),
            leading: Icon(Icons.person),
            onTap: () async {
              Navigator.pop(context);
              await _auth.logOut();
            },
          ),
        ],
      ),
    );
  }
}
