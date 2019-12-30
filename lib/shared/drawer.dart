import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/userInfo.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/database.dart';
import 'package:provider/provider.dart';

import 'loader.dart';

class MainDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return Drawer(
      child: ListView(
        children: <Widget>[
          StreamBuilder<UserInfo>(
              stream: DatabaseService(uid: user.uid).userInfo,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserInfo userInfo = snapshot.data;
                  return UserAccountsDrawerHeader(
                    accountName: Text(userInfo.fullname),
                    accountEmail: Text(userInfo.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(userInfo.fullname[0],
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
            title: Text('Records'),
            leading: Icon(Icons.receipt),
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
