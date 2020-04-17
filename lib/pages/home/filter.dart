import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/categoriesList.dart';
import 'package:fund_tracker/pages/categories/categoryForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/components.dart';

class Filter extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  Filter({this.user, this.openPage});

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  List<Category> _categories;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return _categories != null
        ? Scaffold(
            appBar: AppBar(
              title: Text('Filter Categories'),
            ),
            body: CategoriesList(
              user: widget.user,
              openPage: widget.openPage,
              categories: _categories,
              refreshList: retrieveNewData,
              filterMode: true,
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
