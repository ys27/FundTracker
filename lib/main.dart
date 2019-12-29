import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/wrapper.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:provider/provider.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        theme: ThemeData(
          primaryColor: Colors.red[900],
          accentColor: Colors.redAccent[700],
          fontFamily: 'Andika',
        ),
      ),
    );
  }
}
