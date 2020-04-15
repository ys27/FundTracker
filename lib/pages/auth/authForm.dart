import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';

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

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _fullnameController = TextEditingController();

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
    return Text(isRegister ? 'Sign In' : 'Register');
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
          : Form(
              key: _formKey,
              child: ListView(
                padding: formPadding,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _emailController,
                    autovalidate: _email.isNotEmpty,
                    validator: emailValidator,
                    decoration: clearInput(
                      labelText: 'Email',
                      enabled: _email.isNotEmpty,
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
                  TextFormField(
                    controller: _passwordController,
                    autovalidate: _password.isNotEmpty,
                    validator: passwordValidator,
                    obscureText: _obscurePassword,
                    decoration: clearInput(
                      labelText: 'Password',
                      enabled: _password.isNotEmpty,
                      onPressed: () {
                        setState(() => _password = '');
                        _passwordController.safeClear();
                      },
                      passwordToggle: true,
                      onPasswordTogglePressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      passwordToggleVisible: _obscurePassword,
                    ),
                    onChanged: (val) => setState(() => _password = val),
                  ),
                  isRegister
                      ? TextFormField(
                          controller: _passwordConfirmController,
                          autovalidate: _passwordConfirm.isNotEmpty,
                          validator: (val) =>
                              passwordConfirmValidator(val, _password),
                          obscureText: _obscurePasswordConfirm,
                          decoration: clearInput(
                            labelText: 'Confirm Password',
                            enabled: _passwordConfirm.isNotEmpty,
                            onPressed: () {
                              setState(() => _passwordConfirm = '');
                              _passwordConfirmController.safeClear();
                            },
                            passwordToggle: true,
                            onPasswordTogglePressed: () => setState(
                              () => _obscurePasswordConfirm =
                                  !_obscurePasswordConfirm,
                            ),
                            passwordToggleVisible: _obscurePasswordConfirm,
                          ),
                          onChanged: (val) {
                            setState(() => _passwordConfirm = val);
                          },
                        )
                      : Container(),
                  isRegister
                      ? TextFormField(
                          controller: _fullnameController,
                          autovalidate: _fullname.isNotEmpty,
                          validator: fullNameValidator,
                          textCapitalization: TextCapitalization.words,
                          decoration: clearInput(
                            labelText: 'Full Name',
                            enabled: _fullname.isNotEmpty,
                            onPressed: () {
                              setState(() => _fullname = '');
                              _fullnameController.safeClear();
                            },
                          ),
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
    );
  }
}

String emailValidator(val) {
  if (val.isEmpty) {
    return 'Email is required.';
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

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
