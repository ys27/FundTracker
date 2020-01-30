import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/pages/auth/authWrapper.dart';
import 'package:fund_tracker/pages/home/home.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';

import 'models/period.dart';
import 'models/preferences.dart';
import 'models/transaction.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dynamic _user = Provider.of<FirebaseUser>(context) ?? -1;

    if (_user == null) {
      return Loader();
    } else if (_user == -1) {
      return AuthWrapper();
    } else {
      return StreamProvider<List<Transaction>>(
        create: (_) => DatabaseWrapper(_user.uid).getTransactions(),
        child: StreamProvider<Period>(
          create: (_) => DatabaseWrapper(_user.uid).getDefaultPeriod(),
          child: StreamProvider<Preferences>(
            create: (_) => DatabaseWrapper(_user.uid).getPreferences(),
            child: Home(),
          ),
        ),
      );
    }
  }
}
