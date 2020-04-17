import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/categoryTile.dart';
import 'package:fund_tracker/pages/categories/filterCategoryTile.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';

class CategoriesList extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;
  final List<Category> categories;
  final Function refreshList;
  final bool filterMode;

  CategoriesList({
    this.user,
    this.openPage,
    this.categories,
    this.refreshList,
    this.filterMode: false,
  });

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  @override
  Widget build(BuildContext context) {
    if (widget.categories != null) {
      return Container(
        padding: bodyPadding,
        child: widget.filterMode
            ? ListView(
                children: <Widget>[
                      Center(
                        child: FlatButton(
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          child: Text('Reset Filter'),
                          onPressed: () async {
                            setState(() => widget.categories
                                .forEach((cat) => cat.unfiltered = true));
                            final List<Category> allUnfilteredCategories =
                                widget.categories
                                    .map((cat) => cat.setUnfiltered(true))
                                    .toList();
                            await DatabaseWrapper(widget.user.uid)
                                .updateCategories(allUnfilteredCategories);
                          },
                        ),
                      )
                    ] +
                    widget.categories
                        .map(
                          (category) => FilterCategoryTile(
                            category: category,
                            numCategories: widget.categories.length,
                          ),
                        )
                        .toList(),
              )
            : ReorderableListView(
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
                children: widget.categories
                    .map(
                      (category) => Container(
                        key: Key(category.orderIndex.toString()),
                        child: CategoryTile(
                          category: category,
                          numCategories: widget.categories.length,
                          refreshList: () =>
                              widget.refreshList(widget.user.uid),
                        ),
                      ),
                    )
                    .toList(),
              ),
      );
    } else {
      return Loader();
    }
  }

  void _onReorder(oldIndex, newIndex) {
    int startIndex = oldIndex < newIndex ? oldIndex + 1 : newIndex;
    int untilIndex = oldIndex < newIndex ? newIndex - 1 : oldIndex - 1;
    int finalIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    for (int i = startIndex; i <= untilIndex; i++) {
      int newOrderIndex = oldIndex < newIndex ? i - 1 : i + 1;
      DatabaseWrapper(widget.user.uid)
          .updateCategories([widget.categories[i].setOrder(newOrderIndex)]);
    }
    DatabaseWrapper(widget.user.uid)
        .updateCategories([widget.categories[oldIndex].setOrder(finalIndex)]);
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      Category item = widget.categories.removeAt(oldIndex);
      widget.categories.insert(newIndex, item);
    });
  }
}
