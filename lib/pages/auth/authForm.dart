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

  String _email = '';
  String _password = '';
  String _passwordConfirm = '';
  String _error = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

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
      body: _isLoading
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
                      initialValue: _email,
                      autovalidate: _email.isNotEmpty,
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
                        setState(() => _email = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: _password,
                      autovalidate: _password.isNotEmpty,
                      validator: (val) {
                        if (val.length < 6) {
                          return 'The password must be 6 or more characters.';
                        }
                        return null;
                      },
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffix: ButtonTheme(
                          minWidth: 10.0,
                          child: FlatButton(
                            child: _obscurePassword ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _password = val);
                      },
                    ),
                    isLogin ? Container() : SizedBox(height: 20.0),
                    isLogin
                        ? Container()
                        : TextFormField(
                            initialValue: _passwordConfirm,
                            autovalidate: _passwordConfirm.isNotEmpty,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'This is a required field.';
                              }
                              if (val != _password) {
                                return 'The passwords do not match.';
                              }
                              return null;
                            },
                            obscureText: _obscurePasswordConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              suffix: ButtonTheme(
                                minWidth: 10.0,
                                child: FlatButton(
                                  child: _obscurePasswordConfirm ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _obscurePasswordConfirm =
                                          !_obscurePasswordConfirm),
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() => _passwordConfirm = val);
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
                        setState(() => _error = '');
                        if (_formKey.currentState.validate()) {
                          setState(() => _isLoading = true);
                          dynamic result = isLogin
                              ? await _auth.logIn(_email, _password)
                              : await _auth.register(_email, _password);
                          if (result is String) {
                            setState(() {
                              _isLoading = false;
                              _error = result;
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
                      _error,
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
