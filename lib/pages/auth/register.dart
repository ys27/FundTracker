import 'package:flutter/material.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/database.dart';
import 'package:fund_tracker/shared/loader.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Register'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text('Back'),
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
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'An email is required.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Email',
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
                        hintText: 'Password',
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
                    TextFormField(
                      initialValue: passwordConfirm,
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
                        hintText: 'Confirm Password',
                        suffix: FlatButton(
                          child: Text('Show'),
                          onPressed: () => setState(() =>
                              obscurePasswordConfirm = !obscurePasswordConfirm),
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
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        setState(() => error = '');
                        if (_formKey.currentState.validate()) {
                          setState(() => isLoading = true);
                          dynamic registration =
                              await _auth.register(email, password);
                          if (registration is String) {
                            setState(() {
                              isLoading = false;
                              error = registration;
                            });
                          } else {
                            DatabaseService(uid: registration.uid)
                                .addDefaultCategories();
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
