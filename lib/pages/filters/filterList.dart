import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication
    show User;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/pages/filters/filterTile.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/shared/library.dart';

class FilterList extends StatefulWidget {
  final FirebaseAuthentication.User user;
  final Function openPage;

  FilterList({this.user, this.openPage});

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  List<Category> _categories;
  Preferences _prefs;

  List<bool> _initialState;

  bool _isModified = false;
  bool _isAllEnabled;
  bool _incomeUnfiltered;
  bool _expensesUnfiltered;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid, initial: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_categories != null && _prefs != null) {
      Map<String, dynamic> _incomeMap = {
        'name': 'Income',
        'icon': CommunityMaterialIcons.currency_usd,
        'iconColor': Colors.green,
        'unfiltered': _incomeUnfiltered ?? _prefs.incomeUnfiltered,
        'setUnfilteredState': (val) => _incomeUnfiltered = val,
      };

      Map<String, dynamic> _expensesMap = {
        'name': 'Expenses',
        'icon': CommunityMaterialIcons.currency_usd,
        'iconColor': Colors.red,
        'unfiltered': _expensesUnfiltered ?? _prefs.expensesUnfiltered,
        'setUnfilteredState': (val) => _expensesUnfiltered = val,
      };

      return Scaffold(
        appBar: AppBar(
          title: Text('Filter'),
          actions: <Widget>[
            if (_isModified) ...[
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
            ]
          ],
        ),
        body: ListView(children: <Widget>[
          SizedBox(height: 10.0),
          Center(
            child: FlatButton(
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              child: Text(_isAllEnabled ? 'Disable All' : 'Enable All'),
              onPressed: () async {
                setState(() {
                  _categories.forEach((cat) => cat.unfiltered = !_isAllEnabled);
                  _incomeUnfiltered = !_isAllEnabled;
                  _expensesUnfiltered = !_isAllEnabled;
                });
                _setModified();
              },
            ),
          ),
          FilterTile(otherMap: _incomeMap, setModified: _setModified),
          FilterTile(otherMap: _expensesMap, setModified: _setModified),
          Divider(
            color: Colors.grey,
          ),
          ..._categories
              .map(
                (category) => FilterTile(
                  category: category,
                  numCategories: _categories.length,
                  setModified: _setModified,
                ),
              )
              .toList()
        ]),
      );
    }

    return Loader();
  }

  void _setModified() {
    List<bool> currentState = [
      _incomeUnfiltered ?? _prefs.incomeUnfiltered,
      _expensesUnfiltered ?? _prefs.expensesUnfiltered,
      ..._categories.map((cat) => cat.unfiltered),
    ];
    setState(() {
      _isModified = !listEquals(currentState, _initialState);
      _isAllEnabled =
          currentState.where((state) => state).length == currentState.length;
    });
  }

  void retrieveNewData(String uid, {bool initial}) async {
    List<dynamic> data = await Future.wait([
      DatabaseWrapper(uid).getCategories(),
      DatabaseWrapper(uid).getPreferences(),
    ]);

    setState(() {
      _categories = data[0];
      _prefs = data[1];
    });

    if (initial) {
      _initialState = [
        _prefs.incomeUnfiltered,
        _prefs.expensesUnfiltered,
        ..._categories.map((cat) => cat.unfiltered),
      ];
      _isAllEnabled =
          _initialState.where((state) => state).length == _initialState.length;
    }
  }
}
