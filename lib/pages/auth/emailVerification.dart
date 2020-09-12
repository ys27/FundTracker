import 'package:flutter/material.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/shared/styles.dart';

class EmailVerification extends StatefulWidget {
  final AuthService auth;

  EmailVerification({this.auth});

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  bool _emailVerificationSent = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Container(
        child: ListView(
          padding: formPadding,
          children: <Widget>[
            Center(child: Text('Please verify your email')),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text(
                'Resend email verification',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                setState(() {
                  _emailVerificationSent = false;
                  _isLoading = true;
                });
                await widget.auth.sendEmailVerification();
                setState(() {
                  _emailVerificationSent = true;
                  _isLoading = false;
                });
              },
            ),
            if (_isLoading) ...[Loader()],
            if (_emailVerificationSent) ...[
              Center(child: Text('New email verification sent!'))
            ]
          ],
        ),
      ),
    );
  }
}
