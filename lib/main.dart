import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication
    show User;
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
        initialData: null,
        create: (_) => AuthService().user,
        child: MaterialApp(
          home: Wrapper(),
          theme: ThemeData(
            primaryColor: Colors.red[900],
            accentColor: Colors.blueGrey,
            colorScheme: ColorScheme(
              primary: Colors.black,
              primaryVariant: Colors.black,
              onPrimary: Colors.white,
              secondary: Colors.red[900] ?? Colors.red,
              secondaryVariant: Colors.red[900] ?? Colors.red,
              onSecondary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              background: Colors.white,
              onBackground: Colors.black,
              error: Colors.red[900] ?? Colors.red,
              onError: Colors.white,
              brightness: Brightness.light,
            ),
            fontFamily: 'Andika',
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
