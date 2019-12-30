import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/services/database.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: StreamBuilder<List<Category>>(
          stream: DatabaseService(uid: user.uid).categories,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Category> categories = snapshot.data;
              return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 10.0,
                  ),
                  child: ListView(
                    children: categories.map((category) {
                      return CheckboxListTile(
                        title: Text(category.name),
                        value: category.enabled,
                        secondary: Icon(IconData(category.icon,
                            fontFamily: 'MaterialIcons')),
                        onChanged: (val) {
                          setState(() => category.enabled = val);
                          print(category.enabled);
                          // DatabaseService(uid: user.uid).updateCategory
                        },
                      );
                    }).toList(),
                  ));
            } else {
              return Loader();
            }
          }),
    );
  }
}
