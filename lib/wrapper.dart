import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/userInfo.dart';
import 'package:fund_tracker/pages/auth/authWrapper.dart';
import 'package:fund_tracker/pages/home/home.dart';
import 'package:fund_tracker/pages/preferences/setup.dart';
import 'package:fund_tracker/services/database.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    if (user == null) {
      return AuthWrapper();
    } else {
      return StreamBuilder<UserInfo>(
        stream: DatabaseService(uid: user.uid).userInfo,
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
