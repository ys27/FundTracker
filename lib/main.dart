import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/wrapper.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: StreamProvider<FirebaseAuthentication.User>(
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
      ),
    );
  }
}
