import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/auth/emailVerification.dart';
import 'package:fund_tracker/pages/auth/forgotPassword.dart';
import 'package:fund_tracker/pages/auth/validators.dart';
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

  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();
  final FocusNode _passwordConfirmFocus = new FocusNode();
  final FocusNode _fullnameFocus = new FocusNode();

  bool _isEmailInFocus = false;
  bool _isPasswordInFocus = false;
  bool _isPasswordConfirmInFocus = false;
  bool _isFullnameInFocus = false;

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
  void initState() {
    super.initState();
    _emailFocus.addListener(_checkFocus);
    _passwordFocus.addListener(_checkFocus);
    _passwordConfirmFocus.addListener(_checkFocus);
    _fullnameFocus.addListener(_checkFocus);
  }

  void _checkFocus() {
    setState(() {
      _isEmailInFocus = _emailFocus.hasFocus;
      _isPasswordInFocus = _passwordFocus.hasFocus;
      _isPasswordConfirmInFocus = _passwordConfirmFocus.hasFocus;
      _isFullnameInFocus = _fullnameFocus.hasFocus;
    });
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
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    autovalidate: _password.isNotEmpty,
                    validator: passwordValidator,
                    obscureText: _obscurePassword,
                    decoration: clearInput(
                      labelText: 'Password',
                      enabled: _password.isNotEmpty && _isPasswordInFocus,
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
                  if (isRegister) ...[
                    TextFormField(
                      controller: _passwordConfirmController,
                      focusNode: _passwordConfirmFocus,
                      autovalidate: _passwordConfirm.isNotEmpty,
                      validator: (val) =>
                          passwordConfirmValidator(val, _password),
                      obscureText: _obscurePasswordConfirm,
                      decoration: clearInput(
                        labelText: 'Confirm Password',
                        enabled: _passwordConfirm.isNotEmpty &&
                            _isPasswordConfirmInFocus,
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
                    ),
                    TextFormField(
                      controller: _fullnameController,
                      focusNode: _fullnameFocus,
                      autovalidate: _fullname.isNotEmpty,
                      validator: fullNameValidator,
                      textCapitalization: TextCapitalization.words,
                      decoration: clearInput(
                        labelText: 'Full Name',
                        enabled: _fullname.isNotEmpty && _isFullnameInFocus,
                        onPressed: () {
                          setState(() => _fullname = '');
                          _fullnameController.safeClear();
                        },
                      ),
                      onChanged: (val) => setState(() => _fullname = val),
                    )
                  ],
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
                            _error = _user;
                            _isLoading = false;
                          });
                        } else {
                          if (!isRegister) {
                            if (_user == null) {
                              await showEmailVerificationDialog(context, _auth);
                            } else {
                              await SyncService(_user.uid).syncToLocal();
                            }
                          } else {
                            await Future.wait([
                              DatabaseWrapper(_user.uid).addUser(
                                User(
                                  uid: _user.uid,
                                  email: _email,
                                  fullname: _fullname,
                                ),
                              ),
                              DatabaseWrapper(_user.uid).addDefaultCategories(),
                              DatabaseWrapper(_user.uid)
                                  .addDefaultPreferences(),
                            ]);
                            await showEmailVerificationDialog(context, _auth);
                            widget.toggleView();
                          }
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
                  FlatButton(
                    child: Text('Forgot password?'),
                    onPressed: () async {
                      await showForgotPasswordDialog(context, _auth);
                    },
                  )
                ],
              ),
            ),
    );
  }

  Future showEmailVerificationDialog(
      BuildContext context, AuthService auth) async {
    await showDialog(
      context: context,
      builder: (context) {
        return EmailVerification(
          auth: auth,
        );
      },
    );
    setState(() => _isLoading = false);
  }

  Future showForgotPasswordDialog(
      BuildContext context, AuthService auth) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ForgotPassword(
          auth: auth,
        );
      },
    );
    setState(() => _isLoading = false);
  }
}

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
