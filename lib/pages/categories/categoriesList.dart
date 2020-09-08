import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/categoryForm.dart';
import 'package:fund_tracker/pages/categories/categoryTile.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';

class CategoriesList extends StatefulWidget {
  final FirebaseAuthentication.User user;
  final Function openPage;

  CategoriesList({this.user, this.openPage});

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  List<Category> _categories;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  void dispose() {
    SyncService(widget.user.uid).syncCategories();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _categories != null
        ? Scaffold(
            drawer: MainDrawer(user: widget.user, openPage: widget.openPage),
            appBar: AppBar(
              title: Text('Categories'),
            ),
            body: Container(
              padding: bodyPadding,
              child: ReorderableListView(
                header: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Hold and drag to change the order.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
                onReorder: _onReorder,
                children: _categories
                    .map(
                      (category) => Container(
                        key: Key(category.orderIndex.toString()),
                        child: CategoryTile(
                          category: category,
                          numCategories: _categories.length,
                          refreshList: () => retrieveNewData(widget.user.uid),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            floatingActionButton: FloatingButton(
              context,
              page: CategoryForm(
                category: Category.empty(_categories.length),
                numExistingCategories: _categories.length,
              ),
              callback: () => retrieveNewData(widget.user.uid),
            ),
          )
        : Loader();
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

  void retrieveNewData(String uid) async {
    List<Category> categories = await DatabaseWrapper(uid).getCategories();
    setState(() => _categories = categories);
  }
}
