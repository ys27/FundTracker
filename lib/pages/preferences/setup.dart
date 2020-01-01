import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/preferences/categories.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';

class Setup extends StatefulWidget {
  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final _formKey = GlobalKey<FormState>();

  String _fullname = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Setup'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text('Continue'),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                User user =
                    User(uid: _user.uid, fullname: _fullname, email: _user.email);
                setState(() => isLoading = true);
                await FireDBService(uid: _user.uid).addUser(user);
              }
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
              child: ListView(
                children: <Widget>[
                  Center(
                    child: Text(
                      'Fund Tracker Setup',
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        TextFormField(
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Enter your name.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (val) {
                            setState(() {
                              _fullname = val;
                            });
                          },
                        ),
                        SizedBox(height: 20.0),
                        FlatButton(
                          child: ListTile(
                            title: Text('Set Categories'),
                            trailing: Icon(Icons.arrow_right),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Categories();
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
