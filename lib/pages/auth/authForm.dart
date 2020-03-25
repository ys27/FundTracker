import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';

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
  String _fullname = '';
  String _error = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  Widget title(bool isRegister) {
    return Text(
      isRegister ? 'Register' : 'Sign In',
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }

  Widget authToggleText(bool isRegister) {
    return Text(isRegister ? 'Back' : 'Register');
  }

  InputDecoration showPasswordToggle(String label, bool isVisible) {
    return InputDecoration(
      labelText: label,
      suffix: ButtonTheme(
        minWidth: 10.0,
        child: IconButton(
          icon: _obscurePassword
              ? Icon(CommunityMaterialIcons.eye_off)
              : Icon(CommunityMaterialIcons.eye),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRegister = widget.method == AuthMethod.Register;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: title(isRegister),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: authToggleText(isRegister),
            onPressed: () {
              widget.toggleView();
            },
          )
        ],
      ),
      body: _isLoading
          ? Loader()
          : Container(
              padding: formPadding,
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: _email,
                      autovalidate: _email.isNotEmpty,
                      validator: emailValidator,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => setState(() => _email = val),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: _password,
                      autovalidate: _password.isNotEmpty,
                      validator: passwordValidator,
                      obscureText: _obscurePassword,
                      decoration:
                          showPasswordToggle('Password', _obscurePassword),
                      onChanged: (val) => setState(() => _password = val),
                    ),
                    isRegister ? SizedBox(height: 10.0) : Container(),
                    isRegister
                        ? TextFormField(
                            autovalidate: _passwordConfirm.isNotEmpty,
                            validator: (val) {
                              return passwordConfirmValidator(val, _password);
                            },
                            obscureText: _obscurePasswordConfirm,
                            decoration: showPasswordToggle(
                              'Confirm Password',
                              _obscurePasswordConfirm,
                            ),
                            onChanged: (val) {
                              setState(() => _passwordConfirm = val);
                            },
                          )
                        : Container(),
                    SizedBox(height: 10.0),
                    isRegister
                        ? TextFormField(
                            autovalidate: _fullname.isNotEmpty,
                            validator: fullNameValidator,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(labelText: 'Full Name'),
                            onChanged: (val) => setState(() => _fullname = val),
                          )
                        : Container(),
                    SizedBox(height: 10.0),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: title(isRegister),
                      onPressed: () async {
                        setState(() => _error = '');
                        if (_formKey.currentState.validate()) {
                          setState(() => _isLoading = true);
                          dynamic _user = isRegister
                              ? await _auth.register(_email, _password)
                              : await _auth.signIn(_email, _password);
                          if (_user is String) {
                            setState(() {
                              _isLoading = false;
                              _error = _user;
                            });
                          } else if (isRegister) {
                            DatabaseWrapper(_user.uid).addUser(
                              User(
                                uid: _user.uid,
                                email: _email,
                                fullname: _fullname,
                              ),
                            );
                            DatabaseWrapper(_user.uid).addDefaultCategories();
                            DatabaseWrapper(_user.uid).addDefaultPreferences();
                          } else if (!isRegister) {
                            await SyncService(_user.uid).syncToLocal();
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

String emailValidator(val) {
  if (val.isEmpty) {
    return 'An email is required.';
  }
  if (!RegExp(
          r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(val)) {
    return 'Not a valid email address format.';
  }
  return null;
}

String passwordValidator(val) {
  if (val.length < 6) {
    return 'The password must be 6 or more characters.';
  }
  return null;
}

String passwordConfirmValidator(val, password) {
  if (val.isEmpty) {
    return 'This is a required field.';
  }
  if (val != password) {
    return 'The passwords do not match.';
  }
  return null;
}

String fullNameValidator(val) {
  if (val.isEmpty) {
    return 'This is a required field.';
  }
  return null;
}
