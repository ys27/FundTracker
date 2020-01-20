import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/drawer.dart';
import 'package:provider/provider.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final List<Category> _categories = Provider.of<List<Category>>(context);

    return Scaffold(
      drawer: StreamProvider<User>.value(
        value: LocalDBService().findUser(_user.uid),
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
        ),
        child: _categories != null
            ? ReorderableListView(
                header: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Hold and drag on a category to a different order.',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
                onReorder: (oldIndex, newIndex) {
                  int startIndex =
                      oldIndex < newIndex ? oldIndex + 1 : newIndex;
                  int untilIndex =
                      oldIndex < newIndex ? newIndex - 1 : oldIndex - 1;
                  int finalIndex = oldIndex < newIndex ? newIndex -1 : newIndex;
                  for (int i = startIndex; i <= untilIndex; i++) {
                    int newOrderIndex = oldIndex < newIndex ? i - 1 : i + 1;
                    LocalDBService()
                        .setCategory(_categories[i].setOrder(newOrderIndex));
                  }
                  LocalDBService()
                      .setCategory(_categories[oldIndex].setOrder(finalIndex));
                },
                children: _categories.map((category) {
                  return CheckboxListTile(
                    key: Key(category.orderIndex.toString()),
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
                        LocalDBService().setCategory(category.setEnabled(val));
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
}
