import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/categories/categories.dart';
import 'package:fund_tracker/pages/periods/periods.dart';
import 'package:fund_tracker/pages/preferences/preferencesForm.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';

import 'library.dart';

class MainDrawer extends StatefulWidget {
  final FirebaseUser user;

  MainDrawer(this.user);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _auth = AuthService();
  User userInfo;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    DatabaseWrapper(widget.user.uid).findUser().first.then(
          (user) => setState(() {
            userInfo = user;
          }),
        );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() => isConnected = true);
        }
      } on SocketException catch (_) {
        setState(() => isConnected = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: () => Navigator.popUntil(
              context,
              ModalRoute.withName(Navigator.defaultRouteName),
            ),
          ),
          ListTile(
            title: Text('Categories'),
            leading: Icon(Icons.category),
            onTap: () => openPage(
              context,
              Categories(widget.user),
            ),
          ),
          ListTile(
            title: Text('Periods'),
            leading: Icon(Icons.date_range),
            onTap: () => openPage(
              context,
              StreamProvider<List<Period>>(
                create: (_) => DatabaseWrapper(widget.user.uid).getPeriods(),
                child: Periods(widget.user),
              ),
            ),
          ),
          ListTile(
            title: Text('Preferences'),
            leading: Icon(Icons.tune),
            onTap: () => openPage(
              context,
              StreamProvider<Preferences>(
                create: (_) =>
                    DatabaseWrapper(widget.user.uid).getPreferences(),
                child: PreferencesForm(),
              ),
            ),
          ),
          ListTile(
            title: Text('Sign Out'),
            leading: Icon(Icons.person),
            onTap: () async {
              bool hasBeenConfirmed = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Alert('You will be signed out.');
                    },
                  ) ??
                  false;
              if (hasBeenConfirmed) {
                goHome(context);
                _auth.signOut();
              }
            },
          ),
          isConnected
              ? ListTile(
                  title: Text('Sync'),
                  leading: Icon(Icons.sync),
                  onTap: () {
                    SyncService(widget.user.uid).syncAll();
                  },
                )
              : ListTile(
                  title: Text('Sync Unavailable'),
                  leading: Icon(Icons.sync_problem),
                  onTap: () {},
                ),
        ],
      ),
    );
  }
}
