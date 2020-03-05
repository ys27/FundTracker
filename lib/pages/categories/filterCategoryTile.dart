import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:provider/provider.dart';

class FilterCategoryTile extends StatefulWidget {
  final Category category;
  final int numCategories;

  FilterCategoryTile(
    this.category, {
    this.numCategories,
  });

  @override
  _FilterCategoryTileState createState() => _FilterCategoryTileState();
}

class _FilterCategoryTileState extends State<FilterCategoryTile> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    return CheckboxListTile(
      key: Key(widget.category.orderIndex.toString()),
      title: Row(
        children: <Widget>[
          Icon(
            IconData(
              widget.category.icon,
              fontFamily: 'MaterialIcons',
            ),
            color: widget.category.iconColor,
          ),
          SizedBox(width: 25.0),
          Text(widget.category.name),
        ],
      ),
      value: widget.category.unfiltered,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (val) async {
        setState(() => widget.category.unfiltered = val);
        await DatabaseWrapper(_user.uid)
            .updateCategories([widget.category.setUnfiltered(val)]);
      },
    );
  }
}
