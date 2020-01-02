import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/drawer.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final LocalDBService _localDBService = LocalDBService();
  List<Category> _categories;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    if (_categories == null) {
      getCategories(_user.uid);
    }

    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
        ),
        child: _categories != null
            ? ListView(
                children: <Widget>[
                      Center(
                        child: Text(
                          'Categories are also available in preferences.',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                    ] +
                    _categories.map((category) {
                      return CheckboxListTile(
                        title: Text(category.name),
                        value: category.enabled,
                        activeColor: category.name == 'Others'
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        secondary: Icon(
                          IconData(
                            category.icon,
                            fontFamily: 'MaterialIcons',
                          ),
                        ),
                        onChanged: (val) {
                          if (category.name != 'Others') {
                            LocalDBService()
                                .setCategory(category.setEnabled(val));
                            setState(() {});
                          }
                        },
                      );
                    }).toList(),
              )
            : Center(
                child: Text(
                  'There should be pre-populated categories.',
                ),
              ),
      ),
    );
  }

  void getCategories(String uid) {
    final Future<Database> dbFuture = _localDBService.initializeDBs();
    dbFuture.then((db) {
      Future<List<Category>> categoriesFuture =
          _localDBService.getCategories(uid);
      categoriesFuture.then((categories) {
        setState(() => _categories = categories);
      });
    });
  }
}
