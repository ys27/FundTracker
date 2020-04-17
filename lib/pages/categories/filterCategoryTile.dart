import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';

class FilterCategoryTile extends StatefulWidget {
  final Category category;
  final int numCategories;

  FilterCategoryTile({this.category, this.numCategories});

  @override
  _FilterCategoryTileState createState() => _FilterCategoryTileState();
}

class _FilterCategoryTileState extends State<FilterCategoryTile> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      key: Key(widget.category.orderIndex.toString()),
      title: Row(
        children: <Widget>[
          Icon(
            IconData(
              widget.category.icon,
              fontFamily: 'MaterialDesignIconFont',
              fontPackage: 'community_material_icon',
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
      },
    );
  }
}
