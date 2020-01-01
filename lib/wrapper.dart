import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/auth/authWrapper.dart';
import 'package:fund_tracker/pages/home/home.dart';
import 'package:fund_tracker/pages/preferences/setup.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    if (_user == null) {
      return AuthWrapper();
    } else {
      return StreamBuilder<User>(
        stream: FireDBService(uid: _user.uid).user,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Home();
          } else {
            return Setup();
          }
        },
      );
    }
  }
}
