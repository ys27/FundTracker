import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/auth/auth.dart';
import 'package:fund_tracker/pages/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);

    if (user == null) {
      return Auth();
    } else {
      return Home();
    }
  }
}
