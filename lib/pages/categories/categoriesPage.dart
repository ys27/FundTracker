import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/categoriesList.dart';
import 'package:fund_tracker/pages/categories/categoryForm.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/components.dart';

class CategoriesPage extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  CategoriesPage({this.user, this.openPage});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
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
            body: CategoriesList(
              user: widget.user,
              openPage: widget.openPage,
              categories: _categories,
              refreshList: retrieveNewData,
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

  void retrieveNewData(String uid) {
    DatabaseWrapper(uid).getCategories().then((categories) {
      setState(() => _categories = List<Category>.from(categories));
    });
  }
}
