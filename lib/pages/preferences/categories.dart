import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: StreamBuilder<List<Category>>(
          stream: FireDBService(uid: _user.uid).categories,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Category> categories = snapshot.data;
              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 10.0,
                ),
                child: ListView(
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
                      categories.map((category) {
                        return CheckboxListTile(
                          title: Text(category.name),
                          value: category.enabled,
                          secondary: Icon(
                            IconData(
                              category.icon,
                              fontFamily: 'MaterialIcons',
                            ),
                          ),
                          onChanged: (val) {
                            FireDBService(uid: _user.uid).setCategory(category.cid, val);
                          },
                        );
                      }).toList(),
                ),
              );
            } else {
              return Loader();
            }
          }),
    );
  }
}
