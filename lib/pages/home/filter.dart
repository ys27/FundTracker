import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/pages/categories/filterCategoryTile.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/shared/library.dart';

class Filter extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  Filter({this.user, this.openPage});

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  List<Category> _categories;
  Preferences _prefs;

  bool _incomeUnfiltered;
  bool _expensesUnfiltered;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return (_categories != null && _prefs != null)
        ? Scaffold(
            appBar: AppBar(
              title: Text('Filter'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(CommunityMaterialIcons.check),
                  onPressed: () async {
                    List<Category> updatedCategories = _categories
                        .map((cat) => cat.setUnfiltered(cat.unfiltered))
                        .toList();
                    await DatabaseWrapper(widget.user.uid)
                        .updateCategories(updatedCategories);
                    await DatabaseWrapper(widget.user.uid).updatePreferences(
                      _prefs
                          .setPreference('incomeUnfiltered',
                              _incomeUnfiltered ?? _prefs.incomeUnfiltered)
                          .setPreference('expensesUnfiltered',
                              _expensesUnfiltered ?? _prefs.expensesUnfiltered),
                    );
                    goHome(context);
                  },
                ),
              ],
            ),
            body: ListView(
              children: <Widget>[
                    SizedBox(height: 10.0),
                    Center(
                      child: FlatButton(
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        child: Text('Enable All'),
                        onPressed: () async {
                          setState(() {
                            _categories.forEach((cat) => cat.unfiltered = true);
                            _incomeUnfiltered = true;
                            _expensesUnfiltered = true;
                          });
                          final List<Category> allCategoriesUnfiltered =
                              _categories
                                  .map((cat) => cat.setUnfiltered(true))
                                  .toList();
                          await DatabaseWrapper(widget.user.uid)
                              .updateCategories(allCategoriesUnfiltered);
                          await DatabaseWrapper(widget.user.uid)
                              .updatePreferences(
                            _prefs
                                .setPreference('incomeUnfiltered', true)
                                .setPreference('expensesUnfiltered', true),
                          );
                        },
                      ),
                    ),
                    CheckboxListTile(
                      key: Key('income'),
                      title: Row(
                        children: <Widget>[
                          Icon(
                            CommunityMaterialIcons.currency_usd,
                            color: Colors.green,
                          ),
                          SizedBox(width: 25.0),
                          Text('Income'),
                        ],
                      ),
                      value: _incomeUnfiltered ?? _prefs.incomeUnfiltered,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) async {
                        setState(() => _incomeUnfiltered = val);
                      },
                    ),
                    CheckboxListTile(
                      key: Key('expenses'),
                      title: Row(
                        children: <Widget>[
                          Icon(
                            CommunityMaterialIcons.currency_usd,
                            color: Colors.red,
                          ),
                          SizedBox(width: 25.0),
                          Text('Expenses'),
                        ],
                      ),
                      value: _expensesUnfiltered ?? _prefs.expensesUnfiltered,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) async {
                        setState(() => _expensesUnfiltered = val);
                      },
                    ),
                    Divider(
                      color: Colors.grey,
                    )
                  ] +
                  _categories
                      .map(
                        (category) => FilterCategoryTile(
                          category: category,
                          numCategories: _categories.length,
                        ),
                      )
                      .toList(),
            ),
          )
        : Loader();
  }

  void retrieveNewData(String uid) async {
    List<Category> categories = await DatabaseWrapper(uid).getCategories();
    Preferences prefs = await DatabaseWrapper(uid).getPreferences();

    setState(() {
      _categories = categories;
      _prefs = prefs;
    });
  }
}
