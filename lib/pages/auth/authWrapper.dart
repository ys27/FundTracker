import 'package:flutter/material.dart';
import 'package:fund_tracker/pages/auth/authForm.dart';
import 'package:fund_tracker/shared/constants.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthMethod method = AuthMethod.SignIn;

  void toggleView() {
    setState(() {
      method = (method == AuthMethod.SignIn)
          ? AuthMethod.Register
          : AuthMethod.SignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (method) {
      case AuthMethod.SignIn:
        return AuthForm(toggleView: toggleView, method: AuthMethod.SignIn);
        break;
      case AuthMethod.Register:
        return AuthForm(toggleView: toggleView, method: AuthMethod.Register);
        break;
      default:
        return Text('Error in the AuthWrapper.');
        break;
    }
  }
}
