import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/categories/categoriesList.dart';
import 'package:fund_tracker/pages/periods/periodsList.dart';
import 'package:fund_tracker/pages/preferences/preferencesForm.dart';
import 'package:fund_tracker/pages/recurringTransactions/recurringTransactionsList.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  MainDrawer(this.user, this.openPage);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _auth = AuthService();
  User userInfo;

  @override
  void initState() {
    super.initState();
    DatabaseWrapper(widget.user.uid).getUser().then((user) {
      setState(() => userInfo = user);
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
                  fontSize: 40.0,
                  color: Theme.of(context).primaryColor,
                ),
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
            onTap: () => widget.openPage(
              CategoriesList(widget.user, widget.openPage),
            ),
          ),
          ListTile(
            title: Text('Periods'),
            leading: Icon(Icons.date_range),
            onTap: () => widget.openPage(
              StreamProvider<List<Period>>(
                create: (_) => DatabaseWrapper(widget.user.uid).getPeriods(),
                child: PeriodsList(widget.user, widget.openPage),
              ),
            ),
          ),
          ListTile(
            title: Text('Recurring Transactions'),
            leading: Icon(Icons.history),
            onTap: () => widget.openPage(
              StreamProvider<List<RecurringTransaction>>(
                create: (_) =>
                    DatabaseWrapper(widget.user.uid).getRecurringTransactions(),
                child: RecurringTransactionsList(widget.user, widget.openPage),
              ),
            ),
          ),
          ListTile(
            title: Text('Preferences'),
            leading: Icon(Icons.tune),
            onTap: () => widget.openPage(
              StreamProvider<Preferences>(
                create: (_) =>
                    DatabaseWrapper(widget.user.uid).getPreferences(),
                child: PreferencesForm(widget.user, widget.openPage),
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
        ],
      ),
    );
  }
}
