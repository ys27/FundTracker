import 'package:flutter/material.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/shared/loader.dart';

class Login extends StatefulWidget {
  final Function toggleView;

  Login({this.toggleView});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Login'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text('Register'),
            onPressed: () {
              widget.toggleView();
            },
          )
        ],
      ),
      body: isLoading
          ? Loader()
          : Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 50.0,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: email,
                      // autofocus: true,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'An email is required.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email'
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: password,
                      validator: (val) {
                        if (val.length < 6) {
                          return 'The password must be 6 or more characters.';
                        }
                        return null;
                      },
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffix: FlatButton(
                          child: Text('Show'),
                          onPressed: () => setState(
                              () => obscurePassword = !obscurePassword),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        setState(() => error = '');
                        if (_formKey.currentState.validate()) {
                          setState(() => isLoading = true);
                          dynamic login = await _auth.logIn(email, password);
                          setState(() => isLoading = false);
                          if (login is String) {
                            setState(() => error = login);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}