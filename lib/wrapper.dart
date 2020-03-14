import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/pages/auth/authWrapper.dart';
import 'package:fund_tracker/pages/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dynamic _user = Provider.of<FirebaseUser>(context);

    if (_user != null) {
      return Home(_user);
    } else {
      return AuthWrapper();
    }
  }
}
