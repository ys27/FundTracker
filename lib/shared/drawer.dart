import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/preferences/categories.dart';
import 'package:fund_tracker/pages/preferences/preferences.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:provider/provider.dart';

import 'library.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final User userInfo = Provider.of<User>(context);

    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userInfo != null ? userInfo.fullname : ''),
            accountEmail: Text(userInfo != null ? userInfo.email : ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userInfo != null ? userInfo.fullname[0] : '',
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
            onTap: () => openPage(
              context,
              StreamProvider<List<Category>>.value(
                value: LocalDBService().getCategories(userInfo.uid),
                child: Categories(),
              ),
            ),
          ),
          ListTile(
            title: Text('Preferences'),
            leading: Icon(Icons.tune),
            onTap: () => openPage(context, Preferences()),
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
}
