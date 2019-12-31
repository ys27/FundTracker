import 'package:flutter/material.dart';
import 'package:fund_tracker/pages/auth/authForm.dart';
import 'package:fund_tracker/shared/constants.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthMethod method = AuthMethod.Login;

  void toggleView() {
    setState(() => method =
        (method == AuthMethod.Login ? AuthMethod.Register : AuthMethod.Login));
  }

  @override
  Widget build(BuildContext context) {
    switch (method) {
      case AuthMethod.Login:
      {
        return AuthForm(toggleView: toggleView, method: AuthMethod.Login);
      }
      case AuthMethod.Register:
      {
        return AuthForm(toggleView: toggleView, method: AuthMethod.Register);
      }
      default:
      {
        return Text('Something is wrong with the Authentication Wrapper.');
      }
    }
  }
}
