import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';

class CategoriesList extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;
  final bool filterMode;

  CategoriesList(this.user, this.openPage, {this.filterMode: false});

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
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
    if (!widget.filterMode) {
      SyncService(widget.user.uid).syncCategories();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Loader();
    if (_categories != null) {
      _body = Container(
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
                            setState(() => _categories
                                .forEach((cat) => cat.unfiltered = true));
                            final List<Category> allUnfilteredCategories =
                                _categories
                                    .map((cat) => cat.setUnfiltered(true))
                                    .toList();
                            await DatabaseWrapper(widget.user.uid)
                                .updateCategories(allUnfilteredCategories);
                          },
                        ),
                      )
                    ] +
                    _categories
                        .map((category) => categoryTile(category))
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
                children: _categories
                    .map((category) => categoryTile(category))
                    .toList(),
              ),
      );
    }

    return Scaffold(
      drawer:
          widget.filterMode ? null : MainDrawer(widget.user, widget.openPage),
      appBar: AppBar(
          title: Text(widget.filterMode ? 'Filter Categories' : 'Categories')),
      body: _body,
    );
  }

  Widget categoryTile(category) {
    return CheckboxListTile(
      key: Key(category.orderIndex.toString()),
      title: Text(category.name),
      value: widget.filterMode ? category.unfiltered : category.enabled,
      activeColor: (category.name == 'Others' && !widget.filterMode
          ? Colors.grey
          : Theme.of(context).primaryColor),
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
        if (!widget.filterMode && category.name != 'Others') {
          setState(() => category.enabled = val);
          DatabaseWrapper(widget.user.uid)
              .updateCategories([category.setEnabled(val)]);
        } else if (widget.filterMode) {
          setState(() => category.unfiltered = val);
          DatabaseWrapper(widget.user.uid)
              .updateCategories([category.setUnfiltered(val)]);
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
