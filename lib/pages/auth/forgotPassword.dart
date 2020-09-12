import 'package:flutter/material.dart';
import 'package:fund_tracker/pages/auth/validators.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/shared/styles.dart';

class ForgotPassword extends StatefulWidget {
  final AuthService auth;

  ForgotPassword({this.auth});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _forgotPasswordEmailSent = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final FocusNode _emailFocus = new FocusNode();
  bool _isEmailInFocus = false;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_checkFocus);
  }

  void _checkFocus() {
    setState(() {
      _isEmailInFocus = _emailFocus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Forgot Password?'),
      ),
      body: Container(
        child: ListView(
          padding: formPadding,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              autovalidate: _email.isNotEmpty,
              validator: emailValidator,
              decoration: clearInput(
                labelText: 'Email',
                enabled: _email.isNotEmpty && _isEmailInFocus,
                onPressed: () {
                  setState(() => _email = '');
                  _emailController.safeClear();
                },
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) {
                setState(() => _email = val);
              },
            ),
            SizedBox(height: 10.0),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text(
                'Send password reset email',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                setState(() {
                  _forgotPasswordEmailSent = false;
                  _isLoading = true;
                });
                await widget.auth.sendPasswordResetEmail(_email);
                setState(() {
                  _forgotPasswordEmailSent = true;
                  _isLoading = false;
                });
              },
            ),
            if (_isLoading) ...[Loader()],
            if (_forgotPasswordEmailSent) ...[
              Center(child: Text('Password reset email sent!'))
            ]
          ],
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
