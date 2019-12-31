import 'package:flutter/material.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/loader.dart';

class AuthForm extends StatefulWidget {
  final Function toggleView;
  final AuthMethod method;

  AuthForm({this.toggleView, this.method});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String passwordConfirm = '';
  String error = '';
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscurePasswordConfirm = true;

  @override
  Widget build(BuildContext context) {
    bool isLogin = widget.method == AuthMethod.Login;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text(isLogin ? 'Register' : 'Back'),
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
                      autovalidate: email.isNotEmpty,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'An email is required.';
                        }
                        if (!RegExp(
                                r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                            .hasMatch(val)) {
                          return 'Not a valid email address format.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: password,
                      autovalidate: password.isNotEmpty,
                      validator: (val) {
                        if (val.length < 6) {
                          return 'The password must be 6 or more characters.';
                        }
                        return null;
                      },
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffix: ButtonTheme(
                          minWidth: 10.0,
                          child: FlatButton(
                            child: Text('Show'),
                            onPressed: () => setState(
                                () => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    isLogin ? Container() : SizedBox(height: 20.0),
                    isLogin
                        ? Container()
                        : TextFormField(
                            initialValue: passwordConfirm,
                            autovalidate: passwordConfirm.isNotEmpty,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'This is a required field.';
                              }
                              if (val != password) {
                                return 'The passwords do not match.';
                              }
                              return null;
                            },
                            obscureText: obscurePasswordConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              suffix: ButtonTheme(
                                minWidth: 10.0,
                                child: FlatButton(
                                  child: Text('Show'),
                                  onPressed: () => setState(() =>
                                      obscurePasswordConfirm =
                                          !obscurePasswordConfirm),
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() => passwordConfirm = val);
                            },
                          ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        isLogin ? 'Log In' : 'Register',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        setState(() => error = '');
                        if (_formKey.currentState.validate()) {
                          setState(() => isLoading = true);
                          dynamic result = isLogin
                              ? await _auth.logIn(email, password)
                              : await _auth.register(email, password);
                          if (result is String) {
                            setState(() {
                              isLoading = false;
                              error = result;
                            });
                          } else if (!isLogin) {
                            FireDBService(uid: result.uid)
                                .addDefaultCategories();
                          }
                        }
                      },
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
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
