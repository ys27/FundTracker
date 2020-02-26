import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';

class Categories extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  Categories(this.user, this.openPage);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Category> _categories;

  @override
  void initState() {
    super.initState();
    DatabaseWrapper(widget.user.uid).getCategories().first.then((categories) {
      setState(() => _categories = List<Category>.from(categories));
    });
  }

  @override
  void dispose() {
    SyncService(widget.user.uid).syncCategories();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Loader();
    if (_categories != null) {
      _body = Container(
        padding: bodyPadding,
        child: ReorderableListView(
          header: Column(
            children: <Widget>[
              Center(
                child: Text(
                  'Hold and drag on a category to a different order.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
          onReorder: _onReorder,
          children:
              _categories.map((category) => categoryTile(category)).toList(),
        ),
      );
    }

    return Scaffold(
      drawer: MainDrawer(widget.user, widget.openPage),
      appBar: AppBar(title: Text('Categories')),
      body: _body,
    );
  }

  Widget categoryTile(category) {
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
        color: categoriesRegistry.singleWhere((cat) {
          return cat['name'] == category.name;
        })['color'],
      ),
      onChanged: (val) {
        if (category.name != 'Others') {
          setState(() => category.enabled = val);
          DatabaseWrapper(widget.user.uid)
              .updateCategories([category.setEnabled(val)]);
        }
      },
    );
  }

  void _onReorder(oldIndex, newIndex) {
    int startIndex = oldIndex < newIndex ? oldIndex + 1 : newIndex;
    int untilIndex = oldIndex < newIndex ? newIndex - 1 : oldIndex - 1;
    int finalIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    for (int i = startIndex; i <= untilIndex; i++) {
      int newOrderIndex = oldIndex < newIndex ? i - 1 : i + 1;
      DatabaseWrapper(widget.user.uid)
          .updateCategories([_categories[i].setOrder(newOrderIndex)]);
    }
    DatabaseWrapper(widget.user.uid)
        .updateCategories([_categories[oldIndex].setOrder(finalIndex)]);
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      Category item = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, item);
    });
  }
}
