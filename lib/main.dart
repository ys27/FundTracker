import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/services/background.dart';
import 'package:fund_tracker/wrapper.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(App());

  BackgroundFetch.registerHeadlessTask(
    BackgroundService.backgroundFetchHeadlessTask,
  );
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    BackgroundService.initBackgroundService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>(
      create: (_) => AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        theme: ThemeData(
          primaryColor: Colors.red[900],
          accentColor: Colors.blueGrey,
          fontFamily: 'Andika',
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
